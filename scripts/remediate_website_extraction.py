#!/usr/bin/env python3
"""Accurately extract all structured pages and navigable content from the production Kura website bundle."""

import json
import re

BUNDLE_PATH = "/home/renan/Downloads/projects/Kura/research_workspace/website_js_bundle.js"

with open(BUNDLE_PATH, "r", encoding="utf-8") as f:
    text = f.read()

# Find all occurrences of content:`...`
matches = list(re.finditer(r"content:\s*`", text))
print(f"Total content occurrences: {len(matches)}")

pages = []
for idx, m in enumerate(matches):
    content_start = m.end()
    i = content_start
    escape = False
    while i < len(text):
        c = text[i]
        if escape:
            escape = False
            i += 1
            continue
        if c == "\\":
            escape = True
            i += 1
            continue
        if c == "`":
            break
        i += 1
    content = text[content_start:i]

    # Preceding prefix to find metadata
    prefix = text[max(0, m.start() - 1000):m.start()]
    
    # Try finding slug
    # Pattern 1: "slug":{
    # Pattern 2: id:`slug`
    slug_match = re.findall(r"\"([a-zA-Z0-9_\-]+)\":\s*\{", prefix)
    slug = slug_match[-1] if slug_match else f"section-{idx+1}"

    title_match = re.findall(r"title:\s*`([^`]+)`", prefix)
    title = title_match[-1] if title_match else ""

    desc_match = re.findall(r"description:\s*`([^`]+)`", prefix)
    description = desc_match[-1] if desc_match else ""

    # Headings
    headings_matches = re.findall(r"id:\s*`([^`]+)`,\s*title:\s*`([^`]+)`,\s*level:\s*(\d+)", prefix)
    headings = [{"id": h[0], "title": h[1], "level": int(h[2])} for h in headings_matches]

    # Check for diagrams or interactive components
    diag_match = re.search(r"diagramSvg:\s*`([^`]+)`", prefix)
    diagram = diag_match.group(1) if diag_match else None

    interactive_match = re.search(r"interactiveComponent:\s*`([^`]+)`", prefix)
    interactive = interactive_match.group(1) if interactive_match else None

    pages.append({
        "index": idx + 1,
        "slug": slug,
        "title": title,
        "description": description,
        "headings": headings,
        "diagram_svg": diagram,
        "interactive_component": interactive,
        "char_count": len(content),
        "word_count": len(content.split()),
        "content_markdown": content
    })

print(f"Parsed {len(pages)} structured pages.")
total_chars = sum(p["char_count"] for p in pages)
total_words = sum(p["word_count"] for p in pages)
print(f"Total Content Characters: {total_chars}")
print(f"Total Content Words: {total_words}")

# Save to website_rendered_content.json
out_data = {
    "website_url": "https://kuracpu.vercel.app",
    "bundle_hash": "index-C5AhzZhO.js",
    "total_pages": len(pages),
    "total_characters": total_chars,
    "total_words": total_words,
    "pages": pages
}

OUT_PATH = "/home/renan/Downloads/projects/Kura/kura_final_research/website/website_rendered_content.json"
with open(OUT_PATH, "w", encoding="utf-8") as f:
    json.dump(out_data, f, indent=2)

print(f"Saved to {OUT_PATH}")
