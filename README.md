# async-runtimes-benchmarks

This repository contains programs written in various programming languages.
Each program spawns N concurrent tasks. The number of tasks is controlled by the
command line argument. Each task waits 10 seconds and finishes. The programs finish when
all tasks exit.

The purpose of those programs is to measure the memory footprint of concurrent tasks in
different language runtimes.

## Convention (every language)

- Spawn **N** concurrent tasks (default **100,000**, overridable via CLI argument).
- Each task sleeps **10 seconds**.
- The program exits when all tasks have finished.
- Peak memory (high-water RSS) and elapsed time are measured per run.
- Each run has a **120 s (2 min) timeout**; runs that exceed it are marked as failed.

### Run a single language locally

```bash
# example: Ruby, 50 000 tasks
ruby ruby/main.rb 50000

# example: Deno, 50 000 tasks
deno run deno/main.ts 50000

# example: C++ (compile then run)
clang++ -std=c++20 -O2 -pthread cpp/main.cpp -o /tmp/cpp_bench
/tmp/cpp_bench 50000
```

## Benchmark results (auto-updated by GitHub Actions)

The table below is regenerated on every workflow run (schedule, push, or manual
`workflow_dispatch`) and committed back to this repository.

<!-- BENCHMARK_RESULTS_START -->
| Language | Peak Memory (MB) | Elapsed (s) | Status |
|---|---:|---:|---|
| red | 1.95 | 0.09 | ok |
| rayon | 7.87 | 10.05 | ok |
| c11_atomic | 11.31 | 10.06 | ok |
| c | 11.44 | 10.05 | ok |
| cpp | 12.59 | 10.06 | ok |
| cpp_jthread | 12.60 | 10.05 | ok |
| koka_cpp | 12.70 | 10.05 | ok |
| cpp_threads | 12.75 | 10.07 | ok |
| std_thread | 13.24 | 10.09 | ok |
| cpp_atomic | 13.33 | 10.11 | ok |
| rust_mpsc | 13.93 | 10.07 | ok |
| crossbeam | 14.25 | 10.08 | ok |
| gtk_c | 21.11 | 10.78 | ok |
| smol | 27.11 | 10.08 | ok |
| rayon2 | 28.04 | 10.33 | ok |
| mypy | 31.66 | 11.55 | ok |
| python | 31.75 | 12.97 | ok |
| gtk_rs | 32.22 | 10.06 | ok |
| gtk | 32.25 | 10.09 | ok |
| async_std | 37.04 | 10.14 | ok |
| rust_channels | 39.74 | 10.09 | ok |
| tokio_threads | 40.40 | 10.09 | ok |
| tokio_alt | 40.46 | 10.12 | ok |
| rust | 40.50 | 10.09 | ok |
| rust_tokio2 | 40.52 | 10.22 | ok |
| rust_channels2 | 51.96 | 10.12 | ok |
| browser_js | 52.89 | 10.22 | ok |
| nodejs_alt | 55.03 | 11.73 | ok |
| pypy | 74.39 | 15.98 | ok |
| typescript_alt | 82.38 | 10.41 | ok |
| go | 265.68 | 10.24 | ok |
| elixir | 361.35 | 10.66 | ok |
| nodejs | 385.01 | 10.09 | ok |
| php_threads | 570.51 | 11.03 | ok |
| php | 570.87 | 11.19 | ok |
| perl | 664.55 | 11.56 | ok |
| perl_threads | 664.71 | 11.31 | ok |
| haskell | 1,080.48 | 12.13 | ok |
| ruby | 1,421.52 | 18.82 | ok |
| ada | — | — | ada build |
| angelscript | — | — | angelscript build |
| apl | — | — | apl: dyalog not found |
| asdf | — | — | bench measurement failed |
| assembly | — | — | assembly: make failed |
| ballerina | — | — | ballerina: bal not found |
| ceylon | — | — | ceylon: ceylon not found |
| ceylon_threads | — | — | ceylon_threads: ceylon not found |
| chapel | — | — | chapel: chpl not found |
| chapel_alt | — | — | chapel_alt: chpl not found |
| cl_sbcl | — | — | bench measurement failed |
| clojure | — | — | clojure: cannot install |
| cobol | — | — | cobol build |
| common-lisp | — | — | bench measurement failed |
| common_lisp_sbcl | — | — | bench measurement failed |
| cpython | — | — | failed |
| crystal | — | — | crystal build |
| csharp_threads2 | — | — | bench measurement failed |
| d | — | — | d: dmd not found |
| d_parallel | — | — | d_parallel: dmd not found |
| d_parallel2 | — | — | d_parallel2: dmd not found |
| d_phobos | — | — | d_phobos: dmd not found |
| dart | — | — | bench measurement failed |
| dart_alt | — | — | dart_alt: dart not found |
| delphi | — | — | delphi: fpc not found |
| deno | — | — | failed |
| deno_alt | — | — | deno_alt: deno not found |
| dotnet | — | — | dotnet build |
| eiffel | — | — | eiffel: ec not found |
| elixir_threads | — | — | failed |
| erlang | — | — | erlang build |
| erlang_threads | — | — | erlang_threads: erlc not found |
| factor | — | — | failed |
| fantom | — | — | fantom: fan not found |
| flix | — | — | flix: flix not found |
| flutter | — | — | flutter: dart not found |
| fortran | — | — | failed |
| fpc | — | — | fpc: fpc not found |
| freepascal | — | — | freepascal: fpc not found |
| frege | — | — | frege: frege not found |
| fsharp | — | — | failed |
| gleam | — | — | gleam: gleam not found (use gleam-lang/setup-gleam) |
| gosu | — | — | failed |
| groovy | — | — | failed |
| guile | — | — | guile: guile not found |
| hack | — | — | hack: hhvm not found |
| haxe | — | — | haxe build |
| hy | — | — | failed |
| hylang | — | — | failed |
| idris2 | — | — | idris2: idris2 not found |
| io | — | — | io: io not found |
| j | — | — | j: ijconsole not found |
| janet | — | — | janet: janet not found |
| java | — | — | bench measurement failed |
| java_threads2 | — | — | java_threads2 build |
| julia | — | — | failed |
| julia_threads | — | — | failed |
| koka | — | — | koka: koka not found |
| kotlin | — | — | kotlin build |
| kotlin_threads2 | — | — | kotlin_threads2 build |
| lazarus | — | — | lazarus: fpc not found |
| lazarus_alt | — | — | lazarus_alt: fpc not found |
| lean | — | — | lean: lean not found |
| lobster | — | — | lobster: lobster not found |
| matlab | — | — | bench measurement failed |
| mercury | — | — | mercury: mmc not found |
| modula3 | — | — | modula3: m3 not found |
| nemerle | — | — | nemerle: ncc not found |
| nim | — | — | nim build |
| nim_alt | — | — | nim_alt: nim not found |
| oberon | — | — | oberon: obc not found |
| ocaml | — | — | ocaml build |
| odin | — | — | failed |
| odin_alt | — | — | odin_alt: odin not found |
| oz | — | — | oz: oz not found |
| pascal | — | — | pascal build |
| pascal_alt | — | — | pascal_alt: fpc not found |
| phix | — | — | phix: phix not found |
| phix_alt | — | — | phix_alt: phix not found |
| pike | — | — | pike: pike not found |
| pony | — | — | pony: ponyc not found |
| powershell | — | — | bench measurement failed |
| prolog | — | — | prolog: swipl not found |
| q | — | — | q: q not found |
| qt | — | — | qt build |
| r | — | — | r: coro package install failed |
| racket | — | — | failed |
| racket_threads | — | — | racket_threads: racket not found |
| raku | — | — | failed |
| raku_threads | — | — | raku_threads: raku not found |
| ring | — | — | ring: ring not found |
| ruby_threads | — | — | ruby_threads: async gem not installed |
| ruby_threads2 | — | — | ruby_threads2: async gem not installed |
| sbcl | — | — | bench measurement failed |
| scala | — | — | scala: scala-cli not found |
| scala_threads | — | — | scala_threads: scala-cli not found |
| scheme | — | — | failed |
| scheme_alt | — | — | scheme_alt: guile not found |
| smalltalk | — | — | smalltalk: gst not found |
| sml | — | — | failed |
| supercollider | — | — | failed |
| tcl | — | — | failed |
| turbo_pascal | — | — | turbo_pascal: fpc not found |
| typescript | — | — | typescript: tsx not found (use actions/setup-node) |
| unicon | — | — | unicon: icont not found |
| v | — | — | v: v not found |
| v_alt | — | — | v_alt: v not found |
| v_threads | — | — | v_threads: v not found |
| vala | — | — | vala build |
| vyper | — | — | failed |
| wolfram | — | — | wolfram: wolfram not found |
| wren | — | — | wren: wren not found |
| x10 | — | — | x10: cannot install |
| xtend | — | — | xtend build |
| zig | — | — | zig build |

*Auto-updated by the GitHub Actions benchmark workflow (default 100,000 tasks, each sleeping 10 s). Peak memory = high-water RSS measured during the run.*
<!-- BENCHMARK_RESULTS_END -->

*No results have been collected yet. Push a change or trigger the
"Benchmark async runtimes" workflow to populate the table.*

Peak memory = high-water RSS measured while the 100,000 tasks sleep for 10 s.
"ok" means the run completed; anything else is the error from that language's job
(`continue-on-error` is used so one missing toolchain never blocks the rest).

## Languages covered (157)

| Language | CI toolchain | Concurrency primitive | Entry point |
|---|---|---|---|
| Ada | latest stable (`gnatmake`) | task types + protected counter | `ada/main.adb` |
| AngelScript | latest stable (`g++`) | std::thread | `angelscript/main.cpp` |
| Apl | latest stable (`latest stable`) | See source | `apl/main.apl` |
| Common Lisp (ASDF) | latest stable (`sbcl`) | sb-thread OS threads | `asdf/main.lisp` |
| Assembly (x86_64 NASM) | latest stable (`nasm + ld`) | pthread + semaphore | `assembly/main.asm` |
| Rust async-std | latest stable (`rustc`) | async-std::task | `async_std/main.rs` |
| Ballerina | latest stable (`bal`) | spawn / Semaphore | `ballerina/main.bal` |
| JavaScript (Browser) | latest stable (`node`) | worker_threads pool (1000) + deadline table | `browser_js/main.js` |
| C | latest stable (`gcc`) | pthread pool (1000) + deadline table | `c/main.c` |
| C (C11 atomic) | latest stable (`gcc`) | stdatomic + pthread pool | `c11_atomic/main.c` |
| Ceylon | latest stable (`ceylon`) | executor + CountDownLatch | `ceylon/main.ceylon` |
| Ceylon threads | latest stable (`ceylon`) | executor + CountDownLatch | `ceylon_threads/main.ceylon` |
| Chapel | latest stable (`chpl`) | coforall / semaphore | `chapel/main.chpl` |
| Chapel (alt) | latest stable (`chpl`) | coforall / semaphore | `chapel_alt/main.chpl` |
| Common Lisp (SBCL) | latest stable (`sbcl`) | sb-thread OS threads | `cl_sbcl/main.lisp` |
| Clojure | latest stable (`clojure`) | future / JVM thread pool | `clojure/src/bench/core.clj` |
| Cobol | latest stable (`cobc`) | C$THREAD calls | `cobol/main.cob` |
| Common Lisp | latest stable (`sbcl`) | sb-thread OS threads | `common-lisp/main.lisp` |
| Common Lisp (SBCL) | latest stable (`sbcl`) | sb-thread OS threads | `common_lisp_sbcl/main.lisp` |
| C++ | latest stable (`clang++`) | std::jthread (C++20) | `cpp/main.cpp` |
| C++ atomic | latest stable (`g++`) | std::atomic + semaphore | `cpp_atomic/main.cpp` |
| C++ jthread | latest stable (`g++`) | std::jthread (C++20) | `cpp_jthread/main.cpp` |
| C++ threads | latest stable (`g++`) | std::thread | `cpp_threads/main.cpp` |
| CPython | latest stable (`python3`) | threading.Thread | `cpython/main.py` |
| Rust crossbeam | latest stable (`rustc`) | crossbeam::channel + thread pool | `crossbeam/main.rs` |
| Crystal | latest stable (`crystal`) | spawn fibers + Channel | `crystal/main.cr` |
| C# threads | latest stable (`dotnet`) | Task.Factory.StartNew | `csharp_threads2/Program.cs` |
| D | latest stable (`dmd`) | core.thread.Thread | `d/main.d` |
| D parallel | latest stable (`dmd`) | std.parallelism | `d_parallel/main.d` |
| D parallel2 | latest stable (`dmd`) | std.parallelism | `d_parallel2/main.d` |
| D Phobos | latest stable (`dmd`) | std.parallelism | `d_phobos/main.d` |
| Dart | latest stable (`dart`) | Isolate pool (1000) + deadline table | `dart/main.dart` |
| Dart (alt) | latest stable (`dart`) | Isolate pool (1000) + deadline table | `dart_alt/main.dart` |
| Delphi | latest stable (`fpc`) | BeginThread / TEvent | `delphi/main.dpr` |
| Deno | latest stable (`deno`) | Worker pool (1000) + deadline table | `deno/main.ts` |
| Deno (alt) | latest stable (`deno`) | Worker pool (1000) + deadline table | `deno_alt/main.ts` |
| .NET | latest stable (`dotnet`) | Task.Delay + Task.WhenAll | `dotnet/Program.cs` |
| Eiffel | latest stable (`ec`) | EiffelThreads | `eiffel/main.e` |
| Elixir | latest stable (`elixir`) | spawn_monitor processes | `elixir/main.exs` |
| Elixir threads | latest stable (`elixir`) | Task / Agent | `elixir_threads/main.exs` |
| Erlang | latest stable (`erlc`) | lightweight processes | `erlang/main.erl` |
| Erlang threads | latest stable (`erlc`) | spawn processes | `erlang_threads/main.erl` |
| Factor | latest stable (`factor`) | green threads | `factor/main.factor` |
| Fantom | latest stable (`latest stable`) | See source | `fantom/main.fan` |
| Flix | latest stable (`flix`) | Par / Task | `flix/src/example/Main.flix` |
| Flutter | latest stable (`dart`) | Future.delayed + Future.wait | `flutter/main.dart` |
| Fortran | latest stable (`gfortran`) | OpenMP threads | `fortran/main.f90` |
| FreePascal | latest stable (`fpc`) | BeginThread / TEvent | `fpc/main.pas` |
| FreePascal | latest stable (`fpc`) | BeginThread / TEvent | `freepascal/main.pas` |
| Frege | latest stable (`frege`) | forkIO / threadDelay | `frege/Main.fr` |
| F# | latest stable (`fsharpi`) | Thread pool (1000) + deadline table | `fsharp/main.fsx` |
| Gleam | latest stable (`latest stable`) | See source | `gleam/gleam.toml` |
| Go | latest stable (`go`) | goroutines | `go/main.go` |
| Gosu | latest stable (`gosu`) | Task.Factory.StartNew | `gosu/Main.gosu` |
| Groovy | latest stable (`groovy`) | Java Thread | `groovy/main.groovy` |
| GTK (Rust) | latest stable (`rustc`) | glib MainLoop timers | `gtk/main.rs` |
| GTK (C) | latest stable (`gcc`) | pthread + GTK | `gtk_c/main.c` |
| GTK (Rust) | latest stable (`rustc`) | glib MainLoop timers | `gtk_rs/main.rs` |
| Scheme (Guile) | latest stable (`guile`) | POSIX threads + condition variable | `guile/main.scm` |
| Hack | latest stable (`hhvm`) | HH\Async + WaitHandle\all | `hack/main.hh` |
| Haskell | latest stable (`stack`) | Control.Concurrent.Async | `haskell/Main.hs` |
| Haxe | latest stable (`haxe + neko`) | Thread.create | `haxe/Main.hx` |
| Hy | latest stable (`hy`) | threads | `hy/main.hy` |
| Hy (alt) | latest stable (`hy`) | thread pool (1000) + deadline table | `hylang/main.hy` |
| Idris 2 | latest stable (`idris2`) | forkIO / threadDelay | `idris2/main.idr` |
| Io | latest stable (`io`) | actors / futures | `io/main.io` |
| J | latest stable (`ijconsole`) | parallel operators + threads | `j/main.ijs` |
| Janet | latest stable (`janet`) | fibers | `janet/main.janet` |
| Java | latest stable (`temurin 21`) | ExecutorService fixed thread pool (1000) + deadline table | `java/Threads.java` |
| Java threads | latest stable (`javac`) | Thread + CountDownLatch | `java_threads2/Main.java` |
| Julia | latest stable (`julia`) | Threads.@spawn pool (1000) + deadline table | `julia/main_a.jl` |
| Julia threads | latest stable (`julia`) | Threads.@spawn | `julia_threads/main.jl` |
| Koka | latest stable (`koka`) | effect handlers / forkIO | `koka/main.kk` |
| Koka (C++ backend) | latest stable (`g++`) | std::thread | `koka_cpp/main.cpp` |
| Kotlin | latest stable (`kotlinc`) | Coroutines (launch / delay) | `kotlin/main.kt` |
| Kotlin threads | latest stable (`kotlinc`) | Executor + CountDownLatch | `kotlin_threads2/main.kt` |
| Lazarus | latest stable (`fpc`) | BeginThread / TEvent | `lazarus/main.pas` |
| Lazarus (alt) | latest stable (`fpc`) | BeginThread / TEvent | `lazarus_alt/main.lpr` |
| Lean | latest stable (`lean`) | Thread.fork / IORef | `lean/Main.lean` |
| Lobster | latest stable (`lobster`) | thread::spawn | `lobster/main.lobster` |
| MATLAB | latest stable (`matlab`) | parfor | `matlab/main.m` |
| Mercury | latest stable (`mmc`) | threads + semaphore | `mercury/main.m` |
| Modula-3 | latest stable (`m3`) | Thread.Fork / Sema | `modula3/main.m3` |
| Mypy | latest stable (`python3`) | threading.Thread pool (1000) + deadline table | `mypy/main.py` |
| Nemerle | latest stable (`ncc + mono`) | .NET threads | `nemerle/main.n` |
| Nim | latest stable (`nim`) | thread pool (1000) + deadline table (--threads:on) | `nim/main.nim` |
| Nim (alt) | latest stable (`nim`) | thread pool (1000) + deadline table (--threads:on) | `nim_alt/main.nim` |
| JavaScript (Node.js) | latest stable (`node`) | worker_threads pool (1000) + deadline table | `nodejs/main.js` |
| Node.js (alt) | latest stable (`node`) | worker_threads pool (1000) + deadline table | `nodejs_alt/main.js` |
| Oberon | latest stable (`obc`) | Threads.Fork / Sema | `oberon/main.mod` |
| Objective-C | latest stable (`clang`) | NSThread / GCD | `objective-c/main.m` |
| OCaml | latest stable (`ocamlc`) | Mutex-protected thread pool (1000) + deadline table | `ocaml/main.ml` |
| Odin | latest stable (`odin`) | threads.Spawn | `odin/main.odin` |
| Odin (alt) | latest stable (`odin`) | threads.Spawn | `odin_alt/main.odin` |
| Oz | latest stable (`mozart`) | threads | `oz/main.oz` |
| Pascal | latest stable (`fpc`) | BeginThread / TEvent | `pascal/main.pas` |
| Pascal (alt) | latest stable (`fpc`) | BeginThread / TEvent | `pascal_alt/main.pas` |
| Perl | latest stable (`perl`) | ithreads pool (1000) + deadline | `perl/main.pl` |
| Perl threads | latest stable (`perl`) | ithreads pool (1000) + deadline | `perl_threads/main.pl` |
| Phix | latest stable (`phix`) | tasks / semaphore | `phix/main.exw` |
| Phix (alt) | latest stable (`phix`) | tasks / semaphore | `phix_alt/main.exw` |
| PHP | latest stable (`php + ReactPHP`) | event loop timers + Promise.all | `php/main.php` |
| PHP threads | latest stable (`php`) | event loop + Promise.all | `php_threads/main.php` |
| Pike | latest stable (`pike`) | threads | `pike/main.pike` |
| Pony | latest stable (`ponyc`) | actors | `pony/main.pony` |
| PowerShell | latest stable (`pwsh`) | .NET ThreadPool.QueueUserWorkItem | `powershell/main.ps1` |
| Prolog | latest stable (`swipl`) | thread_create / message passing | `prolog/main.pl` |
| Python | latest stable (`python3`) | threading.Thread pool (1000) + deadline table | `python/main.py` |
| Q | latest stable (`q`) | spawn / semaphore | `q/main.q` |
| Qt (C++) | latest stable (`g++`) | QThread | `qt/main.cpp` |
| R | latest stable (`Rscript`) | parallel package | `r/main.R` |
| Racket | latest stable (`racket`) | thread pool (1000) + deadline table | `racket/main.rkt` |
| Racket threads | latest stable (`racket`) | thread pool (1000) + deadline table | `racket_threads/main.rkt` |
| Raku | latest stable (`raku`) | start blocks pool (1000) + deadline table | `raku/main.raku` |
| Raku (alt) | latest stable (`raku`) | start blocks pool (1000) + deadline table | `raku_alt/main.raku` |
| Raku (alt2) | latest stable (`raku`) | start blocks pool (1000) + deadline table | `raku_alt2/main.raku` |
| Raku threads | latest stable (`raku`) | start blocks pool (1000) + deadline table | `raku_threads/main.raku` |
| Rust rayon | latest stable (`rustc`) | rayon::scope | `rayon/main.rs` |
| Rust rayon2 | latest stable (`rustc`) | rayon ThreadPool (1000) + scope | `rayon2/main.rs` |
| Red | latest stable (`red`) | actors / event! | `red/main.red` |
| Ring | latest stable (`ring`) | threads | `ring/main.ring` |
| Ruby | latest stable (`ruby`) | OS Thread | `ruby/main.rb` |
| Ruby threads | latest stable (`ruby`) | Thread | `ruby_threads/main.rb` |
| Ruby threads2 | latest stable (`ruby`) | Thread | `ruby_threads2/main.rb` |
| Rust | latest stable (`rustc`) | tokio::task | `rust/main.rs` |
| Rust channels | latest stable (`rustc`) | tokio mpsc channel | `rust_channels/main.rs` |
| Rust channels2 | latest stable (`rustc`) | tokio mpsc (bounded) | `rust_channels2/main.rs` |
| Rust mpsc | latest stable (`rustc`) | std::mpsc + thread pool | `rust_mpsc/main.rs` |
| Rust tokio | latest stable (`rustc`) | tokio::task | `rust_tokio2/main.rs` |
| Common Lisp (SBCL) | latest stable (`sbcl`) | sb-thread OS threads | `sbcl/main.lisp` |
| Scala | latest stable (`scala-cli`) | Future / global fork-join pool | `scala/main.scala` |
| Scala threads | latest stable (`scala-cli`) | Executor + CountDownLatch | `scala_threads/main.scala` |
| Scheme (Guile) | latest stable (`guile`) | POSIX threads + condition variable | `scheme/main.scm` |
| Scheme (alt) | latest stable (`guile`) | thread pool (1000) + deadline table | `scheme_alt/main.scm` |
| Smalltalk | latest stable (`gst`) | green processes (fork) | `smalltalk/main.st` |
| SML/NJ | latest stable (`sml`) | Sync.mutex thread pool (1000) + deadline table | `sml/main.sml` |
| Rust smol | latest stable (`rustc`) | smol::Timer | `smol/main.rs` |
| Rust std::thread | latest stable (`rustc`) | std::thread pool (1000) | `std_thread/main.rs` |
| SuperCollider | latest stable (`scsynth`) | fork / Semaphore | `supercollider/main.scd` |
| Swift | latest stable (`swiftc`) | Swift Concurrency (Task / withTaskGroup) | `swift/main.swift` |
| Tcl | latest stable (`tclsh`) | thread package (OS threads) | `tcl/main.tcl` |
| Rust tokio alt | latest stable (`rustc`) | tokio::task | `tokio_alt/main.rs` |
| Rust tokio | latest stable (`rustc`) | tokio::task | `tokio_threads/main.rs` |
| Turbo Pascal | latest stable (`fpc`) | BeginThread / TEvent | `turbo_pascal/main.pas` |
| TypeScript | latest stable (`tsx`) | worker_threads pool (1000) + deadline table | `typescript/main.ts` |
| TypeScript (alt) | latest stable (`tsx`) | worker_threads pool (1000) + deadline table | `typescript_alt/main.ts` |
| Unicon | latest stable (`icont`) | co-expressions / threads | `unicon/main.icn` |
| V | latest stable (`v`) | go goroutines + sync.WaitGroup | `v/main.v` |
| V (alt) | latest stable (`v`) | go goroutines + sync.WaitGroup | `v_alt/main.v` |
| V threads | latest stable (`v`) | go goroutines + sync.WaitGroup | `v_threads/main.v` |
| Vala | latest stable (`valac`) | GLib.Thread / mutex + cond | `vala/main.vala` |
| Vyper | latest stable (`python3`) | threading.Thread | `vyper/main.vy` |
| Wolfram Language | latest stable (`wolfram`) | ParallelTable | `wolfram/main.wl` |
| Wren | latest stable (`wren`) | fibers | `wren/main.wren` |
| X10 | latest stable (`x10c`) | async / at / finish | `x10/Main.x10` |
| Xtend | latest stable (`javac`) | Task.Factory.StartNew | `xtend/Main.java` |
| Zig | latest stable (`zig`) | std.Thread.spawn | `zig/main.zig` |

*Auto-updated by the GitHub Actions benchmark workflow (default 100,000 tasks, each sleeping 10 s). Results sorted by peak memory (asc), then elapsed time (asc).*

## CI workflow

`.github/workflows/benchmark.yml` builds each language (installing its toolchain when
needed), runs it with `scripts/ci_run.sh`, measures peak RSS + elapsed time with
`scripts/bench.py`, aggregates with `scripts/aggregate.py`, and rewrites the table above
via `scripts/patch_readme.py`.

**Every language runs on the latest stable toolchain** available via the official GitHub
Actions setup action or the distro package manager (e.g. `go-version: stable`, `java-version: 21`,
`node-version: latest`, `ruby-version: latest`, `dotnet-version: latest`, `scala-cli version: latest`,
`julia version: latest`, Rust `channel: stable`, etc.). Compiled languages that lack a setup action
are installed from source/packages at job start.

Jobs use `continue-on-error: true`, so a language whose toolchain isn't available on the
runner is reported as "failed" in the table rather than blocking the whole benchmark.
Each benchmark run is capped at **120 seconds** (`--timeout 120` passed to
`scripts/bench.py`), so a hung or pathologically slow implementation fails fast
instead of stalling its matrix job. Each matrix job additionally has
`timeout-minutes: 5` as a safety net for hung builds or toolchain installs.
