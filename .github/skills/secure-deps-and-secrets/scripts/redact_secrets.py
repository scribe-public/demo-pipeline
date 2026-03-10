#!/usr/bin/env python3
"""
Redact likely secrets in text so logs/snippets can be safely shared.

Usage:
  python redact_secrets.py < input.txt > redacted.txt
"""
import re
import sys

text = sys.stdin.read()

# Heuristics: keep conservative. Redact broad patterns rather than risk leaking.
patterns = [
    # Generic high-entropy tokens (very rough)
    (re.compile(r'(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*([A-Za-z0-9_\-+/=]{8,})'), r'\1=<REDACTED>'),
    # AWS Access Key ID
    (re.compile(r'\bAKIA[0-9A-Z]{16}\b'), '<REDACTED_AWS_ACCESS_KEY_ID>'),
    # GitHub tokens
    (re.compile(r'\bgh[pousr]_[A-Za-z0-9]{20,}\b'), '<REDACTED_GH_TOKEN>'),
    # Slack tokens
    (re.compile(r'\bxox[baprs]-[A-Za-z0-9-]{10,}\b'), '<REDACTED_SLACK_TOKEN>'),
    # Private key blocks
    (re.compile(r'-----BEGIN [A-Z ]*PRIVATE KEY-----.*?-----END [A-Z ]*PRIVATE KEY-----', re.S), '<REDACTED_PRIVATE_KEY_BLOCK>'),
]

for rx, repl in patterns:
    text = rx.sub(repl, text)

sys.stdout.write(text)
