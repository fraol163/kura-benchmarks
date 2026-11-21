import re, json

with open('/home/renan/Downloads/projects/Kura/research_workspace/website_js_bundle.js', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's extract all page definitions:
# Pages usually have: id or slug, title, content or similar
# Let's find all objects with {title: ..., slug: ...} or {id: ..., title: ..., content: ...}

page_regex = re.compile(r'\{[^{}]*id:\`([^\`]+)\`[^{}]*title:\`([^\`]+)\`[^{}]*content:\`([^\`]+)\`', re.DOTALL)
matches = page_regex.findall(text)
print(f"Extracted {len(matches)} complete pages with id, title, content")

pages_data = []
for m in matches:
    pages_data.append({
        'id': m[0],
        'title': m[1],
        'content': m[2]
    })

# If page_regex didn't catch everything, let's also find all content blocks:
content_blocks = re.findall(r'content:\`([^\`]{100,50000})\`', text)
print(f"Extracted {len(content_blocks)} content markdown blocks")

with open('/home/renan/Downloads/projects/Kura/research_workspace/website_all_pages.json', 'w') as f:
    json.dump({
        'structured_pages': pages_data,
        'content_blocks': content_blocks
    }, f, indent=2)

print("Saved to website_all_pages.json")
