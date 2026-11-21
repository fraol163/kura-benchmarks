import re, json
from collections import Counter

with open('/home/renan/Downloads/projects/Kura/research_workspace/website_js_bundle.js', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

print(f"Total bundle length: {len(text)} characters")

# Count keywords
keywords = ['Fraol', 'Teshome', 'Loom', 'KAEF', 'Ember', 'Direct I/O', 'io_uring', 'OLMoE', 'Mixtral', 'benchmark', 'throughput', 'RamArena']
for kw in keywords:
    matches = len(re.findall(re.escape(kw), text, re.IGNORECASE))
    print(f"Keyword '{kw}': {matches} matches")

# Print context around Fraol
print("\n=== Context around 'Fraol' ===")
for m in re.finditer(r'Fraol', text, re.IGNORECASE):
    s = max(0, m.start() - 100)
    e = min(len(text), m.end() + 100)
    print(text[s:e])
    print("-" * 40)

# Extract major navigation or documentation headers
print("\n=== Markdown/Text Headers in Bundle ===")
headers = re.findall(r'(?:#+|\b[A-Z][a-zA-Z0-9\s]{3,30}:)\s*([^\n\r"]{4,60})', text)
print(f"Found {len(headers)} potential header strings")
for h in headers[:30]:
    print(" - ", h.strip())
