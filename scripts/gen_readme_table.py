#!/usr/bin/env python3
"""Generate the README language table from directory names."""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Map directory names to (display name, CI toolchain, concurrency primitive)
LANG_MAP = {
    "ada": ("Ada", "gnatmake", "task types + protected counter", "ada/main.adb"),
    "angelscript": ("AngelScript", "g++", "std::thread", "angelscript/main.cpp"),
    "asdf": ("Common Lisp (ASDF)", "sbcl", "sb-thread OS threads", "asdf/main.lisp"),
    "assembly": ("Assembly (x86_64 NASM)", "nasm + ld", "pthread + semaphore", "assembly/main.asm"),
    "ballerina": ("Ballerina", "bal", "spawn / Semaphore", "ballerina/main.bal"),
    "c": ("C", "gcc", "OS pthread", "c/main.c"),
    "ceylon": ("Ceylon", "ceylon", "executor + CountDownLatch", "ceylon/main.ceylon"),
    "chapel": ("Chapel", "chpl", "coforall / semaphore", "chapel/main.chpl"),
    "chapel_alt": ("Chapel (alt)", "chpl", "coforall / semaphore", "chapel_alt/main.chpl"),
    "clojure": ("Clojure", "clojure", "future / JVM thread pool", "clojure/src/bench/core.clj"),
    "cobol": ("Cobol", "cobc", "C$THREAD calls", "cobol/main.cob"),
    "common-lisp": ("Common Lisp", "sbcl", "sb-thread OS threads", "common-lisp/main.lisp"),
    "common_lisp_sbcl": ("Common Lisp (SBCL)", "sbcl", "sb-thread OS threads", "common_lisp_sbcl/main.lisp"),
    "cpp": ("C++", "clang++", "std::jthread (C++20)", "cpp/main.cpp"),
    "cpp_threads": ("C++ threads", "g++", "std::thread", "cpp_threads/main.cpp"),
    "cpp_atomic": ("C++ atomic", "g++", "std::atomic + semaphore", "cpp_atomic/main.cpp"),
    "cpp_jthread": ("C++ jthread", "g++", "std::jthread (C++20)", "cpp_jthread/main.cpp"),
    "crystal": ("Crystal", "crystal", "spawn fibers + Channel", "crystal/main.cr"),
    "d": ("D", "dmd", "core.thread.Thread", "d/main.d"),
    "dart": ("Dart", "dart", "Future.delayed + Future.wait", "dart/main.dart"),
    "dart_alt": ("Dart (alt)", "dart", "Future.delayed + Future.wait", "dart_alt/main.dart"),
    "deno": ("Deno", "deno", "setTimeout + Promise.all", "deno/main.ts"),
    "deno_alt": ("Deno (alt)", "deno", "setTimeout + Promise.all", "deno_alt/main.ts"),
    "dotnet": (".NET", "dotnet", "Task.Delay + Task.WhenAll", "dotnet/Program.cs"),
    "elixir": ("Elixir", "elixir", "spawn_monitor processes", "elixir/main.exs"),
    "elixir_threads": ("Elixir threads", "elixir", "Task / Agent", "elixir_threads/main.exs"),
    "erlang": ("Erlang", "erlc", "lightweight processes", "erlang/main.erl"),
    "erlang_threads": ("Erlang threads", "erlc", "spawn processes", "erlang_threads/main.erl"),
    "eiffel": ("Eiffel", "ec", "EiffelThreads", "eiffel/main.e"),
    "factor": ("Factor", "factor", "green threads", "factor/main.factor"),
    "flix": ("Flix", "flix", "Par / Task", "flix/src/example/Main.flix"),
    "fortran": ("Fortran", "gfortran", "OpenMP threads", "fortran/main.f90"),
    "frege": ("Frege", "frege", "forkIO / threadDelay", "frege/Main.fr"),
    "fsharp": ("F#", "fsharpc + Mono", "Async workflows (Async.Parallel)", "fsharp/main.fsx"),
    "go": ("Go", "go", "goroutines", "go/main.go"),
    "gosu": ("Gosu", "gosu", "Task.Factory.StartNew", "gosu/Main.gosu"),
    "groovy": ("Groovy", "groovy", "Java Thread", "groovy/main.groovy"),
    "guile": ("Scheme (Guile)", "guile", "POSIX threads + condition variable", "guile/main.scm"),
    "hack": ("Hack", "hhvm", "HH\\Async + WaitHandle\\all", "hack/main.hh"),
    "haskell": ("Haskell", "stack", "Control.Concurrent.Async", "haskell/Main.hs"),
    "haxe": ("Haxe", "haxe + neko", "Thread.create", "haxe/Main.hx"),
    "hy": ("Hy", "hy", "threads", "hy/main.hy"),
    "hylang": ("Hy (alt)", "hy", "threads", "hylang/main.hy"),
    "idris2": ("Idris 2", "idris2", "forkIO / threadDelay", "idris2/main.idr"),
    "io": ("Io", "io", "actors / futures", "io/main.io"),
    "janet": ("Janet", "janet", "fibers", "janet/main.janet"),
    "java": ("Java", "temurin 21", "Virtual Threads (Project Loom)", "java/VirtualThreads.java"),
    "java_threads2": ("Java threads", "javac", "Thread + CountDownLatch", "java_threads2/Main.java"),
    "j": ("J", "ijconsole", "parallel operators + threads", "j/main.ijs"),
    "julia": ("Julia", "julia", "@async tasks", "julia/main_a.jl"),
    "julia_threads": ("Julia threads", "julia", "Threads.@spawn", "julia_threads/main.jl"),
    "koka": ("Koka", "koka", "effect handlers / forkIO", "koka/main.kk"),
    "koka_cpp": ("Koka (C++ backend)", "g++", "std::thread", "koka_cpp/main.cpp"),
    "kotlin": ("Kotlin", "kotlinc", "Coroutines (launch / delay)", "kotlin/main.kt"),
    "kotlin_threads2": ("Kotlin threads", "kotlinc", "Executor + CountDownLatch", "kotlin_threads2/main.kt"),
    "lean": ("Lean", "lean", "Thread.fork / IORef", "lean/Main.lean"),
    "lazarus": ("Lazarus", "fpc", "BeginThread / TEvent", "lazarus/main.pas"),
    "lazarus_alt": ("Lazarus (alt)", "fpc", "BeginThread / TEvent", "lazarus_alt/main.lpr"),
    "lobster": ("Lobster", "lobster", "thread::spawn", "lobster/main.lobster"),
    "lua": ("Lua", "lua5.4", "coroutines + socket.sleep", "lua/main.lua"),
    "luajit": ("LuaJIT", "luajit", "coroutines + socket.sleep", "luajit/main.lua"),
    "matlab": ("MATLAB", "matlab", "parfor", "matlab/main.m"),
    "mercury": ("Mercury", "mmc", "threads + semaphore", "mercury/main.m"),
    "modula3": ("Modula-3", "m3", "Thread.Fork / Sema", "modula3/main.m3"),
    "mozart": ("Mozart/Oz", "oz", "threads", "oz/main.oz"),
    "nim": ("Nim", "nim", "asyncproc / sleepAsync", "nim/main.nim"),
    "nim_alt": ("Nim (alt)", "nim", "asyncproc / sleepAsync", "nim_alt/main.nim"),
    "nodejs": ("JavaScript (Node.js)", "node", "setTimeout + Promise.all", "nodejs/main.js"),
    "nodejs_alt": ("Node.js (alt)", "node", "setTimeout + Promise.all", "nodejs_alt/main.js"),
    "ocaml": ("OCaml", "ocamlc", "native Thread", "ocaml/main.ml"),
    "odin": ("Odin", "odin", "threads.Spawn", "odin/main.odin"),
    "odin_alt": ("Odin (alt)", "odin", "threads.Spawn", "odin_alt/main.odin"),
    "oz": ("Oz", "mozart", "threads", "oz/main.oz"),
    "pascal": ("Pascal", "fpc", "BeginThread / TEvent", "pascal/main.pas"),
    "pascal_alt": ("Pascal (alt)", "fpc", "BeginThread / TEvent", "pascal_alt/main.pas"),
    "perl": ("Perl", "perl", "ithreads (threads + join)", "perl/main.pl"),
    "perl_threads": ("Perl threads", "perl", "ithreads", "perl_threads/main.pl"),
    "phix": ("Phix", "phix", "tasks / semaphore", "phix/main.exw"),
    "phix_alt": ("Phix (alt)", "phix", "tasks / semaphore", "phix_alt/main.exw"),
    "php": ("PHP", "php + ReactPHP", "event loop timers + Promise.all", "php/main.php"),
    "php_threads": ("PHP threads", "php", "event loop + Promise.all", "php_threads/main.php"),
    "pike": ("Pike", "pike", "threads", "pike/main.pike"),
    "pony": ("Pony", "ponyc", "actors", "pony/main.pony"),
    "powershell": ("PowerShell", "pwsh", ".NET ThreadPool.QueueUserWorkItem", "powershell/main.ps1"),
    "pypy": ("PyPy", "pypy3", "asyncio (create_task / sleep)", "python/main.py"),
    "prolog": ("Prolog", "swipl", "thread_create / message passing", "prolog/main.pl"),
    "python": ("Python", "python3", "asyncio (create_task / sleep)", "python/main.py"),
    "cpython": ("CPython", "python3", "threading.Thread", "cpython/main.py"),
    "mypy": ("Mypy", "python3", "asyncio", "mypy/main.py"),
    "vyper": ("Vyper", "python3", "threading.Thread", "vyper/main.vy"),
    "q": ("Q", "q", "spawn / semaphore", "q/main.q"),
    "racket": ("Racket", "racket", "OS thread + thread-wait!", "racket/main.rkt"),
    "racket_threads": ("Racket threads", "racket", "thread", "racket_threads/main.rkt"),
    "raku": ("Raku", "raku", "start blocks + await", "raku/main.raku"),
    "raku_alt": ("Raku (alt)", "raku", "start blocks + await", "raku_alt/main.raku"),
    "raku_alt2": ("Raku (alt2)", "raku", "start blocks + await", "raku_alt2/main.raku"),
    "raku_threads": ("Raku threads", "raku", "start blocks + await", "raku_threads/main.raku"),
    "red": ("Red", "red", "actors / event!", "red/main.red"),
    "ring": ("Ring", "ring", "threads", "ring/main.ring"),
    "ruby": ("Ruby", "ruby", "OS Thread", "ruby/main.rb"),
    "ruby_threads": ("Ruby threads", "ruby", "Thread", "ruby_threads/main.rb"),
    "ruby_threads2": ("Ruby threads2", "ruby", "Thread", "ruby_threads2/main.rb"),
    "rust": ("Rust", "rustc", "std::thread", "rust/main.rs"),
    "rust_channels": ("Rust channels", "rustc", "std::thread + mpsc", "rust_channels/main.rs"),
    "rust_channels2": ("Rust channels2", "rustc", "std::thread + mpsc", "rust_channels2/main.rs"),
    "rust_mpsc": ("Rust mpsc", "rustc", "std::thread + mpsc", "rust_mpsc/main.rs"),
    "rust_tokio2": ("Rust tokio", "rustc", "tokio::task", "rust_tokio2/main.rs"),
    "tokio_threads": ("Rust tokio", "rustc", "tokio::task", "tokio_threads/main.rs"),
    "tokio_alt": ("Rust tokio alt", "rustc", "tokio::task", "tokio_alt/main.rs"),
    "std_thread": ("Rust std::thread", "rustc", "std::thread", "std_thread/main.rs"),
    "crossbeam": ("Rust crossbeam", "rustc", "crossbeam::scope", "crossbeam/main.rs"),
    "async_std": ("Rust async-std", "rustc", "async-std::task", "async_std/main.rs"),
    "smol": ("Rust smol", "rustc", "smol::Timer", "smol/main.rs"),
    "gtk_rs": ("Rust GTK", "rustc", "glib::thread", "gtk_rs/main.rs"),
    "rayon": ("Rust rayon", "rustc", "rayon::scope", "rayon/main.rs"),
    "rayon2": ("Rust rayon2", "rustc", "rayon::scope", "rayon2/main.rs"),
    "scala": ("Scala", "scala-cli", "Future / global fork-join pool", "scala/main.scala"),
    "scala_threads": ("Scala threads", "scala-cli", "Executor + CountDownLatch", "scala_threads/main.scala"),
    "scheme": ("Scheme (Guile)", "guile", "POSIX threads + condition variable", "scheme/main.scm"),
    "scheme_alt": ("Scheme (alt)", "guile", "POSIX threads", "scheme_alt/main.scm"),
    "sbcl": ("Common Lisp (SBCL)", "sbcl", "sb-thread OS threads", "sbcl/main.lisp"),
    "smalltalk": ("Smalltalk", "gst", "green processes (fork)", "smalltalk/main.st"),
    "sml": ("SML/NJ", "sml", "Thread.fork / Thread.join", "sml/main.sml"),
    "supercollider": ("SuperCollider", "scsynth", "fork / Semaphore", "supercollider/main.scd"),
    "swift": ("Swift", "swiftc", "Swift Concurrency (Task / withTaskGroup)", "swift/main.swift"),
    "tcl": ("Tcl", "tclsh", "thread package (OS threads)", "tcl/main.tcl"),
    "typescript": ("TypeScript", "tsx", "Promise.all + setTimeout", "typescript/main.ts"),
    "typescript_alt": ("TypeScript (alt)", "tsx", "Promise.all + setTimeout", "typescript_alt/main.ts"),
    "unicon": ("Unicon", "icont", "co-expressions / threads", "unicon/main.icn"),
    "v": ("V", "v", "go goroutines + sync.WaitGroup", "v/main.v"),
    "v_alt": ("V (alt)", "v", "go goroutines + sync.WaitGroup", "v_alt/main.v"),
    "v_threads": ("V threads", "v", "go goroutines + sync.WaitGroup", "v_threads/main.v"),
    "vala": ("Vala", "valac", "GLib.Thread / mutex + cond", "vala/main.vala"),
    "vyper": ("Vyper", "python3", "threading.Thread", "vyper/main.vy"),
    "wolfram": ("Wolfram Language", "wolfram", "ParallelTable", "wolfram/main.wl"),
    "wren": ("Wren", "wren", "fibers", "wren/main.wren"),
    "x10": ("X10", "x10c", "async / at / finish", "x10/Main.x10"),
    "xtend": ("Xtend", "javac", "Task.Factory.StartNew", "xtend/Main.java"),
    "zig": ("Zig", "zig", "std.Thread.spawn", "zig/main.zig"),
}

# Additional missing entries
LANG_MAP.update({
    "angelscript": ("AngelScript", "g++", "std::thread", "angelscript/main.cpp"),
    "asdf": ("Common Lisp (ASDF)", "sbcl", "sb-thread OS threads", "asdf/main.lisp"),
    "browser_js": ("JavaScript (Browser)", "node", "setTimeout + Promise.all", "browser_js/main.js"),
    "c11_atomic": ("C (C11 atomic)", "gcc", "std::atomic + semaphore", "c11_atomic/main.c"),
    "ceylon_threads": ("Ceylon threads", "ceylon", "executor + CountDownLatch", "ceylon_threads/main.ceylon"),
    "cl_sbcl": ("Common Lisp (SBCL)", "sbcl", "sb-thread OS threads", "cl_sbcl/main.lisp"),
    "csharp_threads2": ("C# threads", "dotnet", "Task.Factory.StartNew", "csharp_threads2/Program.cs"),
    "d_parallel": ("D parallel", "dmd", "std.parallelism", "d_parallel/main.d"),
    "d_parallel2": ("D parallel2", "dmd", "std.parallelism", "d_parallel2/main.d"),
    "d_phobos": ("D Phobos", "dmd", "std.parallelism", "d_phobos/main.d"),
    "delphi": ("Delphi", "fpc", "BeginThread / TEvent", "delphi/main.dpr"),
    "fpc": ("FreePascal", "fpc", "BeginThread / TEvent", "fpc/main.pas"),
    "freepascal": ("FreePascal", "fpc", "BeginThread / TEvent", "freepascal/main.pas"),
    "flutter": ("Flutter", "dart", "Future.delayed + Future.wait", "flutter/main.dart"),
    "gtk": ("GTK (Rust)", "rustc", "glib::thread", "gtk/main.rs"),
    "gtk_c": ("GTK (C)", "gcc", "pthread + GTK", "gtk_c/main.c"),
    "gtk_rs": ("GTK (Rust)", "rustc", "glib::thread", "gtk_rs/main.rs"),
    "nemerle": ("Nemerle", "ncc + mono", ".NET threads", "nemerle/main.n"),
    "oberon": ("Oberon", "obc", "Threads.Fork / Sema", "oberon/main.mod"),
    "objective-c": ("Objective-C", "clang", "NSThread / GCD", "objective-c/main.m"),
    "qt": ("Qt (C++)", "g++", "QThread", "qt/main.cpp"),
    "r": ("R", "Rscript", "parallel package", "r/main.R"),
    "turbo_pascal": ("Turbo Pascal", "fpc", "BeginThread / TEvent", "turbo_pascal/main.pas"),
})

# Get all directories
dirs = sorted([d for d in os.listdir(ROOT) 
               if os.path.isdir(os.path.join(ROOT, d)) 
               and d not in ('.git', 'scripts', '.github')
               and not d.startswith('.')])

lines = []
lines.append("| Language | CI toolchain | Concurrency primitive | Entry point |")
lines.append("|---|---|---|---|")

for d in dirs:
    if d in LANG_MAP:
        name, toolchain, primitive, entry = LANG_MAP[d]
    else:
        # Generate name from directory name
        name = d.replace('-', ' ').replace('_', ' ').title()
        toolchain = "latest stable"
        primitive = "See source"
        # Find first source file in directory
        dpath = os.path.join(ROOT, d)
        files = [f for f in os.listdir(dpath) if os.path.isfile(os.path.join(dpath, f))]
        entry = f"{d}/{files[0]}" if files else f"{d}/"

    lines.append(f"| {name} | latest stable (`{toolchain}`) | {primitive} | `{entry}` |")

lines.append("")
lines.append("*Auto-updated by the GitHub Actions benchmark workflow (default 100,000 tasks, "
             "each sleeping 10 s). Results sorted by peak memory (asc), then elapsed time (asc).*")

print("\n".join(lines))
