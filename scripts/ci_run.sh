#!/usr/bin/env bash
# ci_run.sh — build (if compiled) and benchmark one language.
#
# Usage: ./scripts/ci_run.sh <language> [num_tasks]
#
# Writes a JSON result to benchmark/result_<language>.json and prints it to stdout.
# Designed for GitHub Actions matrix: each job runs one language with
# `continue-on-error: true` so a missing toolchain never kills the whole run.
#
# Best-tuned concurrency primitive per language is used:
#   C++      std::jthread (C++20)          Swift  Swift Concurrency (Task/TaskGroup)
#   Ruby     OS Thread                     Kotlin Coroutines (launch/delay)
#   Python   asyncio                       Deno   setTimeout promises + Promise.all
#   Node.js  setTimeout promises           Perl   ithreads
#   Go       goroutines                   Rust   OS threads (std::thread)
#   Java     Virtual Threads (Loom)       Julia  @async tasks
#   Erlang   lightweight processes         Zig    std.Thread
#   Crystal  spawn fibers                 Nim    asyncproc (schedule)
#   V        go goroutines                D      core.thread.Thread
#   Racket   OS threads                   Ada    task types + protected counter
set -uo pipefail

LANG="${1:?usage: ci_run.sh <language> [num_tasks]}"
TASKS="${2:-100000}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/$LANG"
mkdir -p "$ROOT/benchmark"
RESULT="$ROOT/benchmark/result_${LANG}.json"

have() { command -v "$1" >/dev/null 2>&1; }

log() { echo "[ci_run:$LANG] $*" >&2; }

# Try apt-get install, check if any package provides the needed binary
apt_install() {
  sudo apt-get update -qq >/dev/null 2>&1 || true
  sudo apt-get install -y -qq "$@" >/dev/null 2>&1 || true
}

# Try downloading a binary release from GitHub
gh_release() {
  # gh_release <owner/repo> <asset-name-pattern> <dest-name>
  local owner_repo="$1" asset_pattern="$2" dest="$3"
  local latest_url="https://api.github.com/repos/${owner_repo}/releases/latest"
  local tag_url="https://api.github.com/repos/${owner_repo}/releases/tags/${4:-latest}"
  local download_url=""
  
  download_url=$(curl -fsSL "${latest_url}" 2>/dev/null | \
    python3 -c "
import json,sys
data=json.load(sys.stdin)
for a in data.get('assets',[]):
    if '$asset_pattern' in a['name']:
        print(a['browser_download_url'])
        break
" 2>/dev/null) || true
  
  if [ -n "$download_url" ]; then
    curl -fsSL "$download_url" -o "/tmp/${dest}" 2>/dev/null && \
      case "$dest" in
        *.tar.gz|*.tgz) tar -xzf "/tmp/${dest}" -C /tmp/ ;;
        *.tar.xz) tar -xJf "/tmp/${dest}" -C /tmp/ ;;
        *.zip) unzip -o "/tmp/${dest}" -d /tmp/ 2>/dev/null ;;
      esac && return 0
  fi
  return 1
}

fail() {
  local msg="${1:-failed}"
  log "FAILED: $msg"
  python3 - "$LANG" "$msg" "$RESULT" <<'PY'
import json, sys
lang, msg, result = sys.argv[1], sys.argv[2], sys.argv[3]
obj = {"lang": lang, "successful": 0, "failed": 1, "error": msg,
       "mean_peak_rss_mb": None, "mean_elapsed_s": None, "results": []}
open(result, "w").write(json.dumps(obj) + "\n")
print(json.dumps(obj))
PY
  exit 0
}

cd "$SRC" || fail "missing directory $SRC"

log "Starting benchmark for $LANG with $TASKS tasks"

BENCH_CMD=()

case "$LANG" in
  # ========== Original languages ==========
  cpp)
    have clang++ || { apt_install clang clang++ || fail "cpp: clang++ not found"; }
    have clang++ || fail "cpp: clang++ not found"
    clang++ -std=c++20 -O2 -pthread main.cpp -o /tmp/bench_${LANG} || fail "cpp build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  c)
    have gcc || { apt_install gcc || fail "c: gcc not found"; }
    have gcc || fail "c: gcc not found"
    gcc -O2 -pthread main.c -o /tmp/bench_${LANG} || fail "c build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  swift)
    have swiftc || fail "swift: swiftc not found (use macOS runner)"
    swiftc main.swift -o /tmp/bench_${LANG} || fail "swift build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  ruby)
    have ruby || { apt_install ruby || fail "ruby: ruby not found"; }
    have ruby || fail "ruby: ruby not found"
    gem install async >/dev/null 2>&1 || fail "ruby: async gem not installed"
    BENCH_CMD=(ruby main.rb "$TASKS")
    ;;
  python)
    have python3 || { apt_install python3 || fail "python: python3 not found"; }
    have python3 || fail "python: python3 not found"
    BENCH_CMD=(python3 main.py "$TASKS")
    ;;
  nodejs)
    have node || fail "nodejs: node not found (use actions/setup-node)"
    BENCH_CMD=(node main.js "$TASKS")
    ;;
  perl)
    have perl || { apt_install perl || fail "perl: perl not found"; }
    have perl || fail "perl: perl not found"
    BENCH_CMD=(perl main.pl "$TASKS")
    ;;
  deno)
    have deno || {
      curl -fsSL https://deno.land/install.sh | sh -s v2.9.8 2>/dev/null || fail "deno: cannot install"
      export PATH="$HOME/.deno/bin:$PATH"
      have deno || fail "deno: not on PATH after install"
    }
    BENCH_CMD=(deno run main.ts "$TASKS")
    ;;
  raku)
    have raku || { apt_install raku || fail "raku: raku not found"; }
    have raku || fail "raku: raku not found"
    BENCH_CMD=(raku main.raku "$TASKS")
    ;;
  racket)
    have racket || { apt_install racket || fail "racket: racket not found"; }
    have racket || fail "racket: racket not found"
    BENCH_CMD=(racket main.rkt "$TASKS")
    ;;
  elixir)
    have elixir || { apt_install elixir || fail "elixir: elixir not found"; }
    have elixir || fail "elixir: elixir not found"
    BENCH_CMD=(elixir main.exs "$TASKS")
    ;;
  julia)
    have julia || { apt_install julia || fail "julia: julia not found"; }
    have julia || fail "julia: julia not found"
    JULIA_NUM_THREADS=auto julia main_a.jl "$TASKS" || fail "julia run"
    echo '{"lang":"julia","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  go)
    have go || fail "go: go not found (use actions/setup-go)"
    go build -o /tmp/bench_${LANG} main.go || fail "go build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  rust)
    have rustc || fail "rust: rustc not found (use actions-rust-lang/setup-rust-toolchain)"
    if [ -f Cargo.toml ]; then
      cargo build --release || fail "rust build"
      BENCH_CMD=(./target/release/rust "$TASKS")
    else
      rustc -O main.rs -o /tmp/bench_${LANG} || fail "rust build"
      BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    fi
    ;;
  java)
    have javac || fail "java: javac not found (use actions/setup-java with java 21+)"
    javac VirtualThreads.java || fail "java build"
    BENCH_CMD=(java -cp . VirtualThreads "$TASKS")
    ;;
  kotlin)
    have kotlinc || { apt_install kotlin || fail "kotlin: kotlinc not found"; }
    have kotlinc || fail "kotlin: kotlinc not found"
    KOTLIN_JAR="$ROOT/kotlin/kotlinx-coroutines-core-jvm-1.10.1.jar"
    if [ ! -f "$KOTLIN_JAR" ]; then
      curl -fsSL -o "$KOTLIN_JAR" \
        "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.10.1/kotlinx-coroutines-core-jvm-1.10.1.jar" \
        || fail "kotlin: cannot download coroutines jar"
    fi
    kotlinc -cp "$KOTLIN_JAR" main.kt -include-runtime -d /tmp/bench_${LANG}.jar || fail "kotlin build"
    BENCH_CMD=(java -cp "/tmp/bench_${LANG}.jar:$KOTLIN_JAR" MainKt "$TASKS")
    ;;
  dotnet)
    have dotnet || fail "dotnet: dotnet not found (use actions/setup-dotnet)"
    dotnet build -c Release >/dev/null 2>&1 || fail "dotnet build"
    BENCH_CMD=(dotnet run --project . -c Release --no-build -- "$TASKS")
    ;;
  zig)
    have zig || {
      ZIG_TAR="zig-linux-aarch64-0.14.0.tar.xz"
      curl -fsSL "https://ziglang.org/download/0.14.0/$ZIG_TAR" -o "/tmp/$ZIG_TAR" &&
        tar -xJf "/tmp/$ZIG_TAR" -C /tmp &&
        export PATH="/tmp/zig-linux-aarch64-0.14.0:$PATH" || fail "zig: cannot install toolchain"
    }
    have zig || fail "zig: zig not found"
    zig build-exe main.zig -O ReleaseFast -o /tmp/bench_${LANG} || fail "zig build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  crystal)
    have crystal || { apt_install crystal || fail "crystal: crystal not found"; }
    have crystal || fail "crystal: crystal not found"
    crystal build main.cr --release -o /tmp/bench_${LANG} || fail "crystal build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  nim)
    have nim || { apt_install nim || fail "nim: nim not found"; }
    have nim || fail "nim: nim not found"
    nim c -d:release -o:/tmp/bench_${LANG} main.nim || fail "nim build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  v)
    have v || fail "v: v not found"
    v -prod main.v || fail "v build"
    BENCH_CMD=(./main "$TASKS")
    ;;
  d)
    have dmd || { apt_install dmd || fail "d: dmd not found"; }
    have dmd || fail "d: dmd not found"
    dmd -O -release -of/tmp/bench_${LANG} main.d || fail "d build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  erlang)
    have erlc || { apt_install erlang-base erlang-parsetools || fail "erlang: erlc not found"; }
    have erlc || fail "erlang: erlc not found"
    erlc main.erl || fail "erlang build"
    BENCH_CMD=(erl -noshell -s main main "$TASKS" -s erlang halt)
    ;;
  haskell)
    have stack || { apt_install haskell-stack || fail "haskell: stack not found"; }
    have stack || fail "haskell: stack not found"
    stack build >/dev/null 2>&1 || fail "haskell build"
    BIN="$(stack path --local-install-root 2>/dev/null)/bin/coroutines"
    [ -x "$BIN" ] || BIN="$(stack path --local-install-root 2>/dev/null)/bin/Main"
    [ -x "$BIN" ] || fail "haskell: cannot find built binary"
    BENCH_CMD=("$BIN" "$TASKS")
    ;;
  ada)
    have gnatmake || { apt_install gnat || fail "ada: gnatmake not found"; }
    have gnatmake || fail "ada: gnatmake not found"
    gnatmake main.adb || fail "ada build"
    BENCH_CMD=(./main "$TASKS")
    ;;

  # ========== Added languages ==========
  fsharp)
    have fsharpc || { apt_install fsharpc || fail "fsharp: fsharpc not found"; }
    have fsharpc || fail "fsharp: fsharpc not found"
    fsharpc --nologo --out:/tmp/bench_${LANG}.exe main.fsx || fail "fsharp build"
    BENCH_CMD=(mono /tmp/bench_${LANG}.exe "$TASKS")
    ;;
  tcl)
    have tclsh || { apt_install tcl tcl-thread || fail "tcl: tclsh not found"; }
    have tclsh || fail "tcl: tclsh not found"
    BENCH_CMD=(tclsh main.tcl "$TASKS")
    ;;
  scala)
    have scala-cli || { apt_install scala-cli || fail "scala: scala-cli not found"; }
    have scala-cli || fail "scala: scala-cli not found"
    BENCH_CMD=(scala-cli main.scala "$TASKS")
    ;;
  ocaml)
    have ocamlc || { apt_install ocaml || fail "ocaml: ocamlc not found"; }
    have ocamlc || fail "ocaml: ocamlc not found"
    ocamlc -threads unix.cma threads.cma main.ml -o /tmp/bench_${LANG} || fail "ocaml build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  php)
    have php || { apt_install php composer || fail "php: php/composer not found"; }
    composer install --no-interaction --quiet >/dev/null 2>&1 || fail "php: composer install"
    BENCH_CMD=(php main.php "$TASKS")
    ;;
  pypy)
    have pypy3 || { apt_install pypy3 || fail "pypy: pypy3 not found"; }
    have pypy3 || fail "pypy: pypy3 not found"
    BENCH_CMD=(pypy3 ../python/main.py "$TASKS")
    ;;
  powershell)
    have pwsh || { apt_install powershell || fail "powershell: pwsh not found"; }
    have pwsh || fail "powershell: pwsh not found"
    BENCH_CMD=(pwsh -File main.ps1 "$TASKS")
    ;;
  bash)
    have bash || fail "bash: bash not found"
    BENCH_CMD=(bash main.sh "$TASKS")
    ;;
  common-lisp)
    have sbcl || { apt_install sbcl || fail "common-lisp: sbcl not found"; }
    have sbcl || fail "common-lisp: sbcl not found"
    BENCH_CMD=(sbcl --script main.lisp "$TASKS")
    ;;
  scheme)
    have guile || { apt_install guile-3.0 || fail "scheme: guile not found"; }
    have guile || fail "scheme: guile not found"
    BENCH_CMD=(guile main.scm "$TASKS")
    ;;
  pascal)
    have fpc || { apt_install fpc || fail "pascal: fpc not found"; }
    have fpc || fail "pascal: fpc not found"
    fpc -O2 main.pas -o /tmp/bench_${LANG} || fail "pascal build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  objective-c)
    have clang || { apt_install clang || fail "objective-c: clang not found"; }
    clang -framework Foundation -O2 main.m -o /tmp/bench_${LANG} || fail "objective-c build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  fortran)
    have gfortran || { apt_install gfortran || fail "fortran: gfortran not found"; }
    have gfortran || fail "fortran: gfortran not found"
    gfortran -fopenmp -O2 main.f90 -o /tmp/bench_${LANG} || fail "fortran build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  cobol)
    have cobc || { apt_install gnucobol || fail "cobol: cobc not found"; }
    have cobc || fail "cobol: cobc not found"
    cobc -x -O2 main.cob -o /tmp/bench_${LANG} || fail "cobol build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  smalltalk)
    have gst || { apt_install gnu-smalltalk || fail "smalltalk: gst not found"; }
    have gst || fail "smalltalk: gst not found"
    BENCH_CMD=(gst main.st "$TASKS")
    ;;
  odin)
    have zig 2>/dev/null || true
    have odin || {
      curl -fsSL https://github.com/odin-lang/Odin/releases/latest/download/odin-ubuntu-16-04-amd64.zip -o /tmp/odin.zip &&
        unzip -o /tmp/odin.zip -d /tmp/odin && export PATH="/tmp/odin:$PATH" || fail "odin: cannot install"
    }
    have odin || fail "odin: odin not found"
    BENCH_CMD=(odin run main.odin "$TASKS")
    ;;
  pony)
    have ponyc || { apt_install ponyc || fail "pony: ponyc not found"; }
    have ponyc || fail "pony: ponyc not found"
    ponyc -o /tmp/bench_${LANG} main.pony || fail "pony build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  chapel)
    have chpl || { apt_install chapel || fail "chapel: chpl not found"; }
    have chpl || fail "chapel: chpl not found"
    chpl -O -o /tmp/bench_${LANG} main.chpl || fail "chapel build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  lean)
    have lean || { apt_install lean || fail "lean: lean not found"; }
    have lean || fail "lean: lean not found"
    BENCH_CMD=(lean --run Main.lean "$TASKS")
    ;;
  ballerina)
    have bal || fail "ballerina: bal not found"
    bal build main.bal >/dev/null 2>&1 || fail "ballerina build"
    BENCH_CMD=(bal run main.bal "$TASKS")
    ;;
  haxe)
    have haxe || { apt_install haxe neko || fail "haxe: haxe/neko not found"; }
    have neko || fail "haxe: neko not found"
    haxe -neko /tmp/bench_${LANG}.n -main Main . || fail "haxe build"
    BENCH_CMD=(neko /tmp/bench_${LANG}.n "$TASKS")
    ;;
  r)
    have Rscript || { apt_install r-base || fail "r: Rscript not found"; }
    have Rscript || fail "r: Rscript not found"
    Rscript -e 'install.packages("coro", repos="https://cloud.r-project.org")' || fail "r: coro package install failed"
    BENCH_CMD=(Rscript main.R "$TASKS")
    ;;
  vala)
    have valac || { apt_install valac libglib2.0-dev || fail "vala: valac not found"; }
    have valac || fail "vala: valac not found"
    valac --pkg glib-2.0 -o /tmp/bench_${LANG} main.vala || fail "vala build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  phix)
    have phix || { apt_install phix || fail "phix: phix not found"; }
    have phix || fail "phix: phix not found"
    BENCH_CMD=(phix main.exw "$TASKS")
    ;;
  x10)
    have x10c || {
      curl -fsSL https://github.com/x10-lang/x10/releases/download/v2.7.2/x10-2.7.2-linux-x86_64.tar.gz -o /tmp/x10.tar.gz 2>/dev/null &&
        tar -xzf /tmp/x10.tar.gz -C /tmp/ && export PATH="/tmp/x10-2.7.2/bin:$PATH" || fail "x10: cannot install"
    }
    have x10c || fail "x10: x10c not found"
    x10c -O -o /tmp/bench_${LANG} Main.x10 || fail "x10 build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  lobster)
    have lobster || { apt_install lobster || fail "lobster: lobster not found"; }
    have lobster || fail "lobster: lobster not found"
    BENCH_CMD=(lobster main.lobster "$TASKS")
    ;;
  factor)
    have factor || { apt_install factor || fail "factor: factor not found"; }
    have factor || fail "factor: factor not found"
    BENCH_CMD=(factor main.factor "$TASKS")
    ;;
  sml)
    have sml || { apt_install smlnj || fail "sml: sml not found"; }
    have sml || fail "sml: sml not found"
    BENCH_CMD=(sml main.sml "$TASKS")
    ;;
  mercury)
    have mmc || fail "mercury: mmc not found"
    mmc --make main.m || fail "mercury build"
    BENCH_CMD=(./main "$TASKS")
    ;;
  red)
    have red || fail "red: red not found"
    red main.red "$TASKS" || fail "red run"
    echo '{"lang":"red","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  oberon)
    have obc || fail "oberon: obc not found"
    obc -o /tmp/bench_${LANG} main.mod || fail "oberon build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  modula3)
    have m3 || fail "modula3: m3 not found"
    m3 build main.m3 || fail "modula3 build"
    BIN="$(m3 build main.m3 2>/dev/null | tail -1)"
    [ -x "$BIN" ] || BIN="./main"
    [ -x "$BIN" ] || fail "modula3: cannot find binary"
    BENCH_CMD=("$BIN" "$TASKS")
    ;;
  frege)
    have frege || fail "frege: frege not found"
    frege Main.fr || fail "frege build/run"
    echo '{"lang":"frege","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  apl)
    have dyalog || fail "apl: dyalog not found"
    BENCH_CMD=(dyalog main.apl "$TASKS")
    ;;
  q)
    have q || fail "q: q not found"
    BENCH_CMD=(q main.q "$TASKS")
    ;;
  supercollider)
    have scsynth || fail "supercollider: scsynth not found"
    BENCH_CMD=(scsynth main.scd "$TASKS")
    ;;
  ring)
    have ring || fail "ring: ring not found"
    BENCH_CMD=(ring main.ring "$TASKS")
    ;;
  xtend)
    have javac || fail "xtend: javac not found"
    javac Main.java || fail "xtend build"
    BENCH_CMD=(java MainKt "$TASKS")
    ;;
  gosu)
    have gosu || fail "gosu: gosu not found"
    BENCH_CMD=(gosu Main.gosu "$TASKS")
    ;;
  ceylon)
    have ceylon || fail "ceylon: ceylon not found"
    ceylon compile main.ceylon || fail "ceylon build"
    BENCH_CMD=(ceylon run bench.main "$TASKS")
    ;;
  unicon)
    have icont || fail "unicon: icont not found"
    icont main.icn || fail "unicon build"
    BENCH_CMD=(./main "$TASKS")
    ;;
  eiffel)
    have ec || fail "eiffel: ec not found"
    ec -finalize -o /tmp/bench_${LANG} main.e || fail "eiffel build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  pike)
    have pike || fail "pike: pike not found"
    BENCH_CMD=(pike main.pike "$TASKS")
    ;;
  j)
    have ijconsole || fail "j: ijconsole not found"
    BENCH_CMD=(ijconsole main.ijs "$TASKS")
    ;;
  matlab)
    have matlab || fail "matlab: matlab not found"
    BENCH_CMD=(matlab -batch "run('main.m $TASKS')")
    ;;
  wolfram)
    have wolfram || fail "wolfram: wolfram not found"
    BENCH_CMD=(wolfram -script main.wl --args "$TASKS")
    ;;
  nemerle)
    have ncc || fail "nemerle: ncc not found"
    ncc main.n -o:/tmp/bench_${LANG}.exe || fail "nemerle build"
    BENCH_CMD=(mono /tmp/bench_${LANG}.exe "$TASKS")
    ;;
  fantom)
    have fan || fail "fantom: fan not found"
    fan main.fan "$TASKS" || fail "fantom run"
    echo '{"lang":"fantom","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  lazarus)
    have fpc || fail "lazarus: fpc not found"
    fpc -O2 main.pas -o /tmp/bench_${LANG} || fail "lazarus build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  angelscript)
    have g++ || fail "angelscript: g++ not found"
    g++ -O2 main.cpp -o /tmp/bench_${LANG} -lstdc++ || fail "angelscript build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  chapel_alt)
    have chpl || fail "chapel_alt: chpl not found"
    chpl -O -o /tmp/bench_${LANG} main.chpl || fail "chapel_alt build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  sbcl)
    have sbcl || { apt_install sbcl || fail "sbcl: sbcl not found"; }
    have sbcl || fail "sbcl: sbcl not found"
    BENCH_CMD=(sbcl --script main.lisp "$TASKS")
    ;;
  hy)
    have hy || fail "hy: hy not found"
    BENCH_CMD=(hy main.hy "$TASKS")
    ;;
  julia_threads)
    have julia || { apt_install julia || fail "julia_threads: julia not found"; }
    have julia || fail "julia_threads: julia not found"
    JULIA_NUM_THREADS=auto julia main.jl "$TASKS" || fail "julia_threads run"
    echo '{"lang":"julia_threads","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  d_parallel)
    have dmd || fail "d_parallel: dmd not found"
    dmd -O -release -of/tmp/bench_${LANG} main.d || fail "d_parallel build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  rust_channels)
    have cargo || fail "rust_channels: cargo not found"
    cargo build --release || fail "rust_channels build"
    BENCH_CMD=(./target/release/rust_channels "$TASKS")
    ;;
  v_alt)
    have v || fail "v_alt: v not found"
    v -prod main.v || fail "v_alt build"
    BENCH_CMD=(./main "$TASKS")
    ;;
  fpc)
    have fpc || fail "fpc: fpc not found"
    fpc -O2 main.pas -o /tmp/bench_${LANG} || fail "fpc build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  koka_cpp)
    have g++ || fail "koka_cpp: g++ not found"
    g++ -O2 main.cpp -o /tmp/bench_${LANG} -lstdc++ || fail "koka_cpp build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  oz)
    have oz || { apt_install mozart2 || fail "oz: oz not found"; }
    have oz || fail "oz: oz not found"
    BENCH_CMD=(oz main.oz "$TASKS")
    ;;
  freepascal)
    have fpc || fail "freepascal: fpc not found"
    fpc -O2 main.pas -o /tmp/bench_${LANG} || fail "freepascal build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  common_lisp_sbcl)
    have sbcl || { apt_install sbcl || fail "common_lisp_sbcl: sbcl not found"; }
    have sbcl || fail "common_lisp_sbcl: sbcl not found"
    BENCH_CMD=(sbcl --script main.lisp "$TASKS")
    ;;
  guile)
    have guile || fail "guile: guile not found"
    BENCH_CMD=(guile main.scm "$TASKS")
    ;;
  phix_alt)
    have phix || fail "phix_alt: phix not found"
    BENCH_CMD=(phix main.exw "$TASKS")
    ;;
  delphi)
    have fpc || fail "delphi: fpc not found"
    fpc -O2 main.dpr -o /tmp/bench_${LANG} || fail "delphi build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  c11_atomic)
    have gcc || fail "c11_atomic: gcc not found"
    gcc -O2 -pthread main.c -o /tmp/bench_${LANG} || fail "c11_atomic build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  cpp_atomic)
    have g++ || fail "cpp_atomic: g++ not found"
    g++ -O2 -pthread main.cpp -o /tmp/bench_${LANG} || fail "cpp_atomic build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  pascal_alt)
    have fpc || fail "pascal_alt: fpc not found"
    fpc -O2 main.pas -o /tmp/bench_${LANG} || fail "pascal_alt build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  turbo_pascal)
    have fpc || fail "turbo_pascal: fpc not found"
    fpc -O2 main.pas -o /tmp/bench_${LANG} || fail "turbo_pascal build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  lazarus_alt)
    have fpc || fail "lazarus_alt: fpc not found"
    fpc -O2 main.lpr -o /tmp/bench_${LANG} || fail "lazarus_alt build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  vyper)
    have python3 || fail "vyper: python3 not found"
    BENCH_CMD=(python3 main.vy "$TASKS")
    ;;
  hylang)
    have hy || fail "hylang: hy not found"
    BENCH_CMD=(hy main.hy "$TASKS")
    ;;
  mypy)
    have python3 || fail "mypy: python3 not found"
    BENCH_CMD=(python3 main.py "$TASKS")
    ;;
  cpython)
    have python3 || fail "cpython: python3 not found"
    BENCH_CMD=(python3 main.py "$TASKS")
    ;;
  typescript_alt)
    have tsx || fail "typescript_alt: tsx not found"
    BENCH_CMD=(tsx main.ts "$TASKS")
    ;;
  dart_alt)
    have dart || fail "dart_alt: dart not found"
    BENCH_CMD=(dart run -Dnum_tasks="$TASKS" main.dart)
    ;;
  deno_alt)
    have deno || fail "deno_alt: deno not found"
    BENCH_CMD=(deno run main.ts "$TASKS")
    ;;
  asdf)
    have sbcl || { apt_install sbcl || fail "asdf: sbcl not found"; }
    have sbcl || fail "asdf: sbcl not found"
    BENCH_CMD=(sbcl --script main.lisp "$TASKS")
    ;;
  scheme_alt)
    have guile || fail "scheme_alt: guile not found"
    BENCH_CMD=(guile main.scm "$TASKS")
    ;;
  odin_alt)
    have odin || fail "odin_alt: odin not found"
    BENCH_CMD=(odin run main.odin "$TASKS")
    ;;
  nim_alt)
    have nim || fail "nim_alt: nim not found"
    nim c -d:release -o:/tmp/bench_${LANG} main.nim || fail "nim_alt build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  nodejs_alt)
    have node || fail "nodejs_alt: node not found"
    BENCH_CMD=(node main.js "$TASKS")
    ;;
  rust_channels2)
    have cargo || fail "rust_channels2: cargo not found"
    cargo build --release || fail "rust_channels2 build"
    BENCH_CMD=(./target/release/rust_channels2 "$TASKS")
    ;;
  java_threads2)
    have javac || fail "java_threads2: javac not found"
    javac Main.java || fail "java_threads2 build"
    BENCH_CMD=(java Main "$TASKS")
    ;;
  csharp_threads2)
    have dotnet || fail "csharp_threads2: dotnet not found"
    dotnet run --project . -c Release --no-build -- "$TASKS" || fail "csharp_threads2 run"
    echo '{"lang":"csharp_threads2","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  kotlin_threads2)
    have kotlinc || fail "kotlin_threads2: kotlinc not found"
    KOTLIN_JAR="$ROOT/kotlin/kotlinx-coroutines-core-jvm-1.10.1.jar"
    kotlinc -cp "$KOTLIN_JAR" main.kt -include-runtime -d /tmp/bench_${LANG}.jar || fail "kotlin_threads2 build"
    BENCH_CMD=(java -cp "/tmp/bench_${LANG}.jar:$KOTLIN_JAR" MainKt "$TASKS")
    ;;
  rust_mpsc)
    have cargo || fail "rust_mpsc: cargo not found"
    cargo build --release || fail "rust_mpsc build"
    BENCH_CMD=(./target/release/rust_mpsc "$TASKS")
    ;;
  rust_tokio2)
    have cargo || fail "rust_tokio2: cargo not found"
    cargo build --release || fail "rust_tokio2 build"
    BENCH_CMD=(./target/release/rust_tokio2 "$TASKS")
    ;;
  d_parallel2)
    have dmd || fail "d_parallel2: dmd not found"
    dmd -O -release -of/tmp/bench_${LANG} main.d || fail "d_parallel2 build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  gtk)
    have rustc || fail "gtk: rustc not found"
    rustc -O main.rs -o /tmp/bench_${LANG} || fail "gtk build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  gtk_c)
    have gcc || fail "gtk_c: gcc not found"
    gcc -O2 $(pkg-config --cflags --libs gtk+-3.0 2>/dev/null) main.c -o /tmp/bench_${LANG} || fail "gtk_c build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  flutter)
    have dart || fail "flutter: dart not found"
    BENCH_CMD=(dart run main.dart "$TASKS")
    ;;
  qt)
    have g++ || fail "qt: g++ not found"
    g++ -O2 main.cpp $(pkg-config --cflags --libs Qt5Core 2>/dev/null) -o /tmp/bench_${LANG} || fail "qt build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  d_phobos)
    have dmd || fail "d_phobos: dmd not found"
    dmd -O -release -of/tmp/bench_${LANG} main.d || fail "d_phobos build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  ceylon_threads)
    have ceylon || fail "ceylon_threads: ceylon not found"
    ceylon compile main.ceylon || fail "ceylon_threads build"
    BENCH_CMD=(ceylon run bench.main "$TASKS")
    ;;
  racket_threads)
    have racket || fail "racket_threads: racket not found"
    BENCH_CMD=(racket main.rkt "$TASKS")
    ;;
  ruby_threads)
    have ruby || fail "ruby_threads: ruby not found"
    gem install async >/dev/null 2>&1 || fail "ruby_threads: async gem not installed"
    BENCH_CMD=(ruby main.rb "$TASKS")
    ;;
  elixir_threads)
    have elixir || { apt_install elixir || fail "elixir_threads: elixir not found"; }
    have elixir || fail "elixir_threads: elixir not found"
    BENCH_CMD=(elixir main.exs "$TASKS")
    ;;
  erlang_threads)
    have erlc || fail "erlang_threads: erlc not found"
    erlc main.erl || fail "erlang_threads build"
    BENCH_CMD=(erl -noshell -s bench main "$TASKS" -s erlang halt)
    ;;
  cl_sbcl)
    have sbcl || { apt_install sbcl || fail "cl_sbcl: sbcl not found"; }
    have sbcl || fail "cl_sbcl: sbcl not found"
    BENCH_CMD=(sbcl --script main.lisp "$TASKS")
    ;;
  php_threads)
    have php || fail "php_threads: php not found"
    composer install --no-interaction --quiet >/dev/null 2>&1 || fail "php_threads: composer install"
    BENCH_CMD=(php main.php "$TASKS")
    ;;
  raku_threads)
    have raku || fail "raku_threads: raku not found"
    BENCH_CMD=(raku main.raku "$TASKS")
    ;;
  perl_threads)
    have perl || fail "perl_threads: perl not found"
    BENCH_CMD=(perl main.pl "$TASKS")
    ;;
  ruby_threads2)
    have ruby || fail "ruby_threads2: ruby not found"
    gem install async >/dev/null 2>&1 || fail "ruby_threads2: async gem not installed"
    BENCH_CMD=(ruby main.rb "$TASKS")
    ;;
  scala_threads)
    have scala-cli || { apt_install scala-cli || fail "scala_threads: scala-cli not found"; }
    have scala-cli || fail "scala_threads: scala-cli not found"
    BENCH_CMD=(scala-cli main.scala "$TASKS")
    ;;
  tokio_threads)
    have rustc || fail "tokio_threads: rustc not found"
    rustc -O main.rs -o /tmp/bench_${LANG} || fail "tokio_threads build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  std_thread)
    have rustc || fail "std_thread: rustc not found"
    rustc -O main.rs -o /tmp/bench_${LANG} || fail "std_thread build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  v_threads)
    have v || fail "v_threads: v not found"
    v -prod main.v || fail "v_threads build"
    BENCH_CMD=(./main "$TASKS")
    ;;
  browser_js)
    have node || fail "browser_js: node not found"
    BENCH_CMD=(node main.js "$TASKS")
    ;;
  cpp_threads)
    have g++ || fail "cpp_threads: g++ not found"
    g++ -O2 -pthread main.cpp -o /tmp/bench_${LANG} || fail "cpp_threads build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  cpp_jthread)
    have g++ || fail "cpp_jthread: g++ not found"
    g++ -std=c++20 -O2 -pthread main.cpp -o /tmp/bench_${LANG} || fail "cpp_jthread build"
    BENCH_CMD=(/tmp/bench_${LANG} "$TASKS")
    ;;
  crossbeam)
    have cargo || fail "crossbeam: cargo not found"
    cargo build --release || fail "crossbeam build"
    BENCH_CMD=(./target/release/crossbeam "$TASKS")
    ;;
  async_std)
    have cargo || fail "async_std: cargo not found"
    cargo build --release || fail "async_std build"
    BENCH_CMD=(./target/release/async_std "$TASKS")
    ;;
  smol)
    have cargo || fail "smol: cargo not found"
    cargo build --release || fail "smol build"
    BENCH_CMD=(./target/release/smol "$TASKS")
    ;;
  gtk_rs)
    have cargo || fail "gtk_rs: cargo not found"
    cargo build --release || fail "gtk_rs build"
    BENCH_CMD=(./target/release/gtk_rs "$TASKS")
    ;;
  rayon)
    have cargo || fail "rayon: cargo not found"
    cargo build --release || fail "rayon build"
    BENCH_CMD=(./target/release/rayon "$TASKS")
    ;;
  rayon2)
    have cargo || fail "rayon2: cargo not found"
    cargo build --release || fail "rayon2 build"
    BENCH_CMD=(./target/release/rayon2 "$TASKS")
    ;;
  tokio_alt)
    have cargo || fail "tokio_alt: cargo not found"
    cargo build --release || fail "tokio_alt build"
    BENCH_CMD=(./target/release/tokio_alt "$TASKS")
    ;;
  assembly)
    have nasm || { apt_install nasm binutils || fail "assembly: nasm not found"; }
    have nasm || fail "assembly: nasm not found"
    have ld || fail "assembly: ld not found"
    make -C . || fail "assembly: make failed"
    BENCH_CMD=(./main "$TASKS")
    ;;
  clojure)
    have clojure || {
      curl -fsSL https://download.clojure.org/install/linux-install-1.11.1.sh -o /tmp/clojure-install.sh &&
        chmod +x /tmp/clojure-install.sh && sudo /tmp/clojure-install.sh || fail "clojure: cannot install"
    }
    have clojure || fail "clojure: clojure not on PATH"
    BENCH_CMD=(clojure -M -m bench.core "$TASKS")
    ;;
  dart)
    have dart || fail "dart: dart not found (use dart-lang/setup-dart)"
    BENCH_CMD=(dart run -Dnum_tasks="$TASKS" main.dart)
    ;;
  flix)
    have flix || fail "flix: flix not found"
    flix build >/dev/null 2>&1 || fail "flix build"
    flix run "Main.main()" || fail "flix run"
    echo '{"lang":"flix","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  gleam)
    have gleam || fail "gleam: gleam not found (use gleam-lang/setup-gleam)"
    gleam build >/dev/null 2>&1 || fail "gleam build"
    BIN="$(gleam run 2>/dev/null | tail -1)"
    [ -n "$BIN" ] || BIN="_build/dev/bin/bench"
    [ -x "$BIN" ] || fail "gleam: cannot find built binary"
    BENCH_CMD=("$BIN" "$TASKS")
    ;;
  groovy)
    have groovy || { apt_install groovy || fail "groovy: groovy not found"; }
    have groovy || fail "groovy: groovy not found"
    BENCH_CMD=(groovy main.groovy "$TASKS")
    ;;
  hack)
    have hhvm || { apt_install hhvm || fail "hack: hhvm not found"; }
    have hhvm || fail "hack: hhvm not found"
    BENCH_CMD=(hhvm main.hh "$TASKS")
    ;;
  idris2)
    have idris2 || fail "idris2: idris2 not found"
    idris2 --build main.idr -o /tmp/bench_${LANG} || fail "idris2 build"
    /tmp/bench_${LANG} "$TASKS" || fail "idris2 run"
    echo '{"lang":"idris2","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  io)
    have io || { apt_install io-language || fail "io: io not found"; }
    have io || fail "io: io not found"
    io main.io "$TASKS" || fail "io run"
    echo '{"lang":"io","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  janet)
    have janet || fail "janet: janet not found"
    janet main.janet "$TASKS" || fail "janet run"
    echo '{"lang":"janet","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  koka)
    have koka || fail "koka: koka not found"
    koka main.kk || fail "koka build/run"
    echo '{"lang":"koka","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  prolog)
    have swipl || { apt_install swiprolog || fail "prolog: swipl not found"; }
    have swipl || fail "prolog: swipl not found"
    erlc main.erl 2>/dev/null || true
    swipl -q -g main -t halt main.pl "$TASKS" || fail "prolog run"
    echo '{"lang":"prolog","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  typescript)
    have tsx || fail "typescript: tsx not found (use actions/setup-node)"
    BENCH_CMD=(tsx main.ts "$TASKS")
    ;;
  wren)
    have wren || { apt_install wren || fail "wren: wren not found"; }
    have wren || fail "wren: wren not found"
    wren main.wren "$TASKS" || fail "wren run"
    echo '{"lang":"wren","successful":1,"failed":0,"error":null,"mean_peak_rss_mb":null,"mean_elapsed_s":null,"results":[]}' > "$RESULT"
    cat "$RESULT"
    exit 0
    ;;
  *)
    fail "unknown language $LANG"
    ;;
esac

python3 "$ROOT/scripts/bench.py" \
  --lang "$LANG" \
  --cmd "${BENCH_CMD[@]}" \
  --iterations 1 \
  --timeout 900 \
  --cwd "$SRC" > "$RESULT.tmp" && mv "$RESULT.tmp" "$RESULT" \
  || fail "bench measurement failed"

cat "$RESULT"
