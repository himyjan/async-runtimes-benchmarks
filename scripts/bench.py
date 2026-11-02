#!/usr/bin/env python3
"""Measure peak RSS (memory) and elapsed time of a single benchmark command.

Usage:
    python3 scripts/bench.py --lang <name> --cmd <command>... [--cwd <dir>] \
        [--iterations 3] [--timeout 900]

Prints a single JSON object to stdout with an aggregate summary plus per-iteration
details. Designed to be called from CI; each language job writes its own JSON file
so parallel matrix jobs never collide.

Memory measurement:
  Linux: reads /proc/<pid>/status VmHWM (high-water mark / peak RSS) for the
         root process AND all descendant processes (recursive /proc scan).
         This ensures process-based languages (Bash, Lua, Forth, etc.) whose
         tasks are separate OS processes have their children's memory counted.
  macOS: reads `ps -o rss=` for the root process only (no /proc).
"""
import argparse
import json
import os
import signal
import statistics
import subprocess
import sys
import time


def read_rss(pid: int):
    """Return peak RSS in bytes for a single PID, or None.

    Linux: /proc/<pid>/status VmHWM (high-water mark, i.e. peak RSS so far).
    macOS: `ps -o rss= -p <pid>` (kilobytes), sampled each call.
    """
    try:
        with open(f"/proc/{pid}/status", "rb") as f:
            for line in f:
                if line.startswith(b"VmHWM:"):
                    parts = line.split()
                    if len(parts) >= 2:
                        return int(parts[1]) * 1024  # kB -> bytes
    except Exception:
        pass
    try:
        out = subprocess.check_output(
            ["ps", "-o", "rss=", "-p", str(pid)], stderr=subprocess.DEVNULL
        )
        val = out.strip()
        if val:
            return int(val) * 1024  # ps reports kB
    except Exception:
        pass
    return None


def build_ppid_map():
    """Build a mapping of parent PID -> list of child PIDs by scanning /proc.

    Returns an empty dict on non-Linux systems or on error.
    """
    children = {}
    try:
        for pid_dir in os.listdir("/proc"):
            if not pid_dir.isdigit():
                continue
            try:
                with open(f"/proc/{pid_dir}/stat", "rb") as f:
                    data = f.read()
                # /proc/pid/stat: pid (comm) state ppid ...
                # comm can contain spaces and parens, so split at the last ')'
                rparen = data.rindex(b")")
                rest = data[rparen + 2 :].split()
                if len(rest) >= 2:
                    ppid = int(rest[1])  # rest[0]=state, rest[1]=ppid
                    children.setdefault(ppid, []).append(int(pid_dir))
            except Exception:
                pass
    except Exception:
        pass
    return children


def get_all_pids(root_pid: int, children_map: dict):
    """Return root PID + all descendants via BFS on the parent->children map."""
    pids = {root_pid}
    stack = [root_pid]
    while stack:
        p = stack.pop()
        for c in children_map.get(p, []):
            if c not in pids:
                pids.add(c)
                stack.append(c)
    return pids


def run_once(cmd, cwd, timeout):
    start = time.monotonic()
    proc = subprocess.Popen(
        cmd,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=True,
    )
    peak = 0
    timed_out = False
    last_rescan = 0.0
    children_map = build_ppid_map()
    all_pids = get_all_pids(proc.pid, children_map)

    while proc.poll() is None:
        now = time.monotonic()
        # Rescan /proc every second to catch newly spawned child processes.
        if now - last_rescan > 1.0:
            children_map = build_ppid_map()
            all_pids = get_all_pids(proc.pid, children_map)
            last_rescan = now

        for pid in all_pids:
            rss = read_rss(pid)
            if rss is not None and rss > peak:
                peak = rss

        if now - start > timeout:
            timed_out = True
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
            except Exception:
                pass
            break
        time.sleep(0.05)

    # Final read after the process exits (descendants may still be zombies).
    children_map = build_ppid_map()
    all_pids = get_all_pids(proc.pid, children_map)
    for pid in all_pids:
        rss = read_rss(pid)
        if rss is not None and rss > peak:
            peak = rss

    try:
        out, err = proc.communicate(timeout=30)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except Exception:
            pass
        out, err = proc.communicate()

    elapsed = time.monotonic() - start

    return {
        "elapsed_s": round(elapsed, 3),
        "peak_rss_mb": round(peak / (1024 * 1024), 2) if peak else None,
        "returncode": proc.returncode,
        "timed_out": timed_out,
        "stdout": out.decode("utf-8", "replace").strip()[-300:] if out else "",
        "stderr": err.decode("utf-8", "replace").strip()[-300:] if err else "",
    }


def main():
    ap = argparse.ArgumentParser(description="Benchmark a command's memory & time")
    ap.add_argument("--lang", required=True, help="language name")
    ap.add_argument("--cmd", required=True, nargs="+", help="command to run")
    ap.add_argument("--cwd", default=".", help="working directory")
    ap.add_argument("--iterations", type=int, default=1, help="repeat count")
    ap.add_argument("--timeout", type=int, default=900, help="per-run timeout (s)")
    args = ap.parse_args()

    results = [run_once(args.cmd, args.cwd, args.timeout) for _ in range(args.iterations)]
    ok = [r for r in results if r["returncode"] == 0 and not r["timed_out"]]

    if ok:
        summary = {
            "lang": args.lang,
            "iterations": len(results),
            "successful": len(ok),
            "failed": len(results) - len(ok),
            "mean_elapsed_s": round(statistics.mean(r["elapsed_s"] for r in ok), 3),
            "median_elapsed_s": round(statistics.median(r["elapsed_s"] for r in ok), 3),
            "mean_peak_rss_mb": (
                round(
                    statistics.mean(
                        r["peak_rss_mb"] for r in ok if r["peak_rss_mb"] is not None
                    ),
                    2,
                )
                if any(r["peak_rss_mb"] is not None for r in ok)
                else None
            ),
            "max_peak_rss_mb": (
                round(
                    max(r["peak_rss_mb"] for r in ok if r["peak_rss_mb"] is not None),
                    2,
                )
                if any(r["peak_rss_mb"] is not None for r in ok)
                else None
            ),
        }
    else:
        summary = {
            "lang": args.lang,
            "iterations": len(results),
            "successful": 0,
            "failed": len(results),
        }
    summary["results"] = results
    print(json.dumps(summary))


if __name__ == "__main__":
    main()
