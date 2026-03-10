#!/usr/bin/env python3
"""
Summarize SARIF findings (CodeQL/other) into a short list:
- ruleId
- level
- message
- file + line

Usage:
  python summarize_sarif.py results.sarif
"""
import json
import sys

path = sys.argv[1] if len(sys.argv) > 1 else None
if not path:
    print("Usage: python summarize_sarif.py results.sarif", file=sys.stderr)
    sys.exit(2)

with open(path, "r", encoding="utf-8") as f:
    sarif = json.load(f)

runs = sarif.get("runs", [])
out = []

for run in runs:
    results = run.get("results", [])
    for r in results:
        rule = r.get("ruleId", "unknown-rule")
        level = r.get("level", "unknown")
        msg = (r.get("message") or {}).get("text", "").strip()
        locs = r.get("locations", [])
        if locs:
            phys = (locs[0].get("physicalLocation") or {})
            artifact = (phys.get("artifactLocation") or {}).get("uri", "unknown-file")
            region = phys.get("region") or {}
            line = region.get("startLine", "?")
        else:
            artifact, line = "unknown-file", "?"
        out.append((level, rule, artifact, line, msg))

# Sort: error > warning > note
rank = {"error": 0, "warning": 1, "note": 2}
out.sort(key=lambda x: rank.get(x[0], 9))

for level, rule, artifact, line, msg in out[:50]:
    print(f"[{level}] {rule} — {artifact}:{line}")
    if msg:
        print(f"  {msg[:200]}")
