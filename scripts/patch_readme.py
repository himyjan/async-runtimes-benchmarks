#!/usr/bin/env python3
"""Splice the generated benchmark table into README.md between markers."""
import sys

if len(sys.argv) != 3:
    sys.exit("usage: patch_readme.py <readme> <table>")
readme_path, table_path = sys.argv[1], sys.argv[2]

readme = open(readme_path).read()
table = open(table_path).read().strip()

start_marker = "<!-- BENCHMARK_RESULTS_START -->"
end_marker = "<!-- BENCHMARK_RESULTS_END -->"

i = readme.find(start_marker)
j = readme.find(end_marker)
if i == -1 or j == -1 or j < i:
    sys.exit("benchmark result markers not found in README.md")

new_readme = (
    readme[: i + len(start_marker)]
    + "\n"
    + table
    + "\n"
    + readme[j:]
)
open(readme_path, "w").write(new_readme)
