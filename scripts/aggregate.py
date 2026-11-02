#!/usr/bin/env python3
"""Aggregate per-language benchmark JSON files into results.json + a markdown table."""
import glob
import json
import os
import statistics

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BENCH_DIR = os.path.join(ROOT, "benchmark")

rows = []
for path in sorted(glob.glob(os.path.join(BENCH_DIR, "result_*.json"))):
    with open(path) as f:
        obj = json.load(f)
    lang = obj.get("lang", os.path.basename(path))
    if obj.get("successful", 0) > 0:
        rows.append({
            "language": lang,
            "mean_peak_rss_mb": obj.get("mean_peak_rss_mb"),
            "mean_elapsed_s": obj.get("mean_elapsed_s"),
            "status": "ok",
        })
    else:
        rows.append({
            "language": lang,
            "mean_peak_rss_mb": None,
            "mean_elapsed_s": None,
            "status": obj.get("error", "failed"),
        })

# Sort: successful runs by peak memory (asc), then elapsed time (asc), then failures at the end.
ok = [r for r in rows if r["status"] == "ok"]
fail = [r for r in rows if r["status"] != "ok"]
ok.sort(key=lambda r: (
    r["mean_peak_rss_mb"] is None,           # None values last
    r["mean_peak_rss_mb"] or 0,              # lower memory first
    r["mean_elapsed_s"] is None,             # None values last
    r["mean_elapsed_s"] or 0,                # faster time first
    r["language"],                            # alphabetical tiebreaker
))
fail.sort(key=lambda r: r["language"])
ordered = ok + fail

results = {"languages": ordered, "count": len(ordered)}
with open(os.path.join(BENCH_DIR, "results.json"), "w") as f:
    json.dump(results, f, indent=2)

lines = []
lines.append("| Language | Peak Memory (MB) | Elapsed (s) | Status |")
lines.append("|---|---:|---:|---|")
for r in ordered:
    mem = f"{r['mean_peak_rss_mb']:,.2f}" if r["mean_peak_rss_mb"] is not None else "—"
    tim = f"{r['mean_elapsed_s']:.2f}" if r["mean_elapsed_s"] is not None else "—"
    lines.append(f"| {r['language']} | {mem} | {tim} | {r['status']} |")
lines.append("")
lines.append(
    "*Auto-updated by the GitHub Actions benchmark workflow (default 100,000 tasks, "
    "each sleeping 10 s). Peak memory = high-water RSS measured during the run.*"
)

table_path = os.path.join(BENCH_DIR, "table.md")
with open(table_path, "w") as f:
    f.write("\n".join(lines))

print("\n".join(lines))
