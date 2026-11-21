import re, json

with open('/home/renan/Downloads/projects/Kura/research_workspace/website_js_bundle.js', 'r', encoding='utf-8') as f:
    text = f.read()

# In the bundle, we saw: c=b.flatMap(e=>e.pages
# Let's search for the definition of b = [ ... ] where categories/pages are defined
# Often looks like: [{category:"...",pages:[{title:"...",...}]}] or similar

pattern = re.compile(r'\[\s*\{\s*(?:category|title|id)\s*:\s*[`\'"][^`\'"]+[`\'"]')
for m in pattern.finditer(text):
    start = m.start()
    snippet = text[start:start+2500]
    print("Found potential pages/categories array:")
    print(snippet[:600])
    print("="*60)
