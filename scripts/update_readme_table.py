#!/usr/bin/env python3
"""Replace the language table section in README.md with generated table."""
import re

ROOT = "/Users/user/Downloads/async-runtimes-benchmarks"

# Read current README
with open(f"{ROOT}/README.md") as f:
    readme = f.read()

# Read generated table
with open("/tmp/new_table.md") as f:
    new_table = f.read().strip()

# Replace the table section
start_marker = "## Languages covered ("
end_marker = "## CI workflow"

# Find the start marker
start_idx = readme.find(start_marker)
if start_idx == -1:
    print("ERROR: Start marker not found")
    exit(1)

# Find the end marker
end_idx = readme.find(end_marker, start_idx)
if end_idx == -1:
    print("ERROR: End marker not found")
    exit(1)

# Count languages from the table (subtract header row)
table_lines = [l for l in new_table.split('\n') if l.startswith('| ') and '---' not in l]
lang_count = len(table_lines) - 1  # Subtract header row

# Build new section
new_section = f"## Languages covered ({lang_count})\n\n{new_table}\n\n"

# Replace
new_readme = readme[:start_idx] + new_section + readme[end_idx:]

with open(f"{ROOT}/README.md", "w") as f:
    f.write(new_readme)

print(f"Updated README with {lang_count} languages")
