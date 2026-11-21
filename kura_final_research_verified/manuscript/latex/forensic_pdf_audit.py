import re
import os
import sys
import pdfplumber
import pypdf

PDF_PATH = "/home/renan/Downloads/projects/Kura/kura_final_research_verified/manuscript/latex/main.pdf"
TEXT_DUMP_PATH = "pdf_full_text_dump.txt"
REPORT_PATH = "forensic_audit_report.md"

def run_audit():
    if not os.path.exists(PDF_PATH):
        print(f"Error: PDF not found at {PDF_PATH}")
        sys.exit(1)

    print(f"Opening {PDF_PATH} with pypdf and pdfplumber...")
    reader = pypdf.PdfReader(PDF_PATH)
    total_pages = len(reader.pages)
    print(f"Total pages via pypdf: {total_pages}")

    pages_text = {}
    pages_chars = {}
    pages_words = {}
    pages_curves_rects = {}

    with pdfplumber.open(PDF_PATH) as pdf:
        if len(pdf.pages) != total_pages:
            print(f"Warning: page count mismatch {len(pdf.pages)} vs {total_pages}")

        for i, page in enumerate(pdf.pages):
            pnum = i + 1
            # Extract standard text layout
            text = page.extract_text(layout=True) or ""
            words = page.extract_words(keep_blank_chars=False)
            chars = page.chars
            
            pages_text[pnum] = text
            pages_words[pnum] = words
            pages_chars[pnum] = chars
            pages_curves_rects[pnum] = {
                "curves": len(page.curves),
                "lines": len(page.lines),
                "rects": len(page.rects),
                "images": len(page.images)
            }

    # Write pdf_full_text_dump.txt
    with open(TEXT_DUMP_PATH, "w", encoding="utf-8") as f:
        for pnum in sorted(pages_text.keys()):
            f.write(f"--- PAGE {pnum} ---\n")
            f.write(pages_text[pnum])
            f.write("\n\n")

    print(f"Saved complete text dump to {TEXT_DUMP_PATH}")

    # STEP 2: GHOST HUNTING (REGEX MATCHES)
    ghost_patterns = [
        ("O_DIRECT or Direct I/O", re.compile(r"(\bO_DIRECT\b|Direct\s+I/O)", re.IGNORECASE)),
        ("Conference", re.compile(r"(Conference'?17|Con\s*f\s*e\s*r\s*e\s*n\s*c\s*e)", re.IGNORECASE)),
        ("Washington", re.compile(r"\bWashington\b", re.IGNORECASE)),
        ("Anonymous", re.compile(r"\bAnonymous\b", re.IGNORECASE)),
        ("24-core", re.compile(r"\b24-core\b", re.IGNORECASE)),
        ("io uring (broken underscore)", re.compile(r"\bio\s+uring\b", re.IGNORECASE)),
        ("p read64 (broken underscore)", re.compile(r"\bp\s+read64\b", re.IGNORECASE)),
    ]

    ghost_matches = []

    for pnum in sorted(pages_text.keys()):
        raw = pages_text[pnum]
        # Also construct text from words to catch non-layout spacing
        word_text = " ".join([w["text"] for w in pages_words[pnum]])
        combined_text = raw + "\n" + word_text

        # Break text into candidate sentences
        # Simple sentence splitter: split on periods, newlines, semicolons
        chunks = re.split(r"(?<=[.!?\n])\s+", combined_text)

        for ghost_name, pat in ghost_patterns:
            for chunk in chunks:
                chunk_clean = chunk.strip().replace("\n", " ")
                if pat.search(chunk_clean):
                    # verify it's not a duplicate for this page
                    entry = (pnum, ghost_name, chunk_clean)
                    if entry not in ghost_matches:
                        ghost_matches.append(entry)

    # STEP 3: ABBREVIATION & NOMENCLATURE AUDIT
    # Find nomenclature table in extracted text
    # Usually has Term / Definition or Acronym / Definition
    defined_terms = set()
    raw_full = "\n".join(pages_text.values())

    # Load 00_nomenclature.tex directly to be exact on defined terms
    nom_file = "/home/renan/Downloads/projects/Kura/kura_final_research_verified/manuscript/latex/sections/00_nomenclature.tex"
    if os.path.exists(nom_file):
        with open(nom_file, "r") as f:
            nom_content = f.read()
            # Extract first column of table rows before &
            for line in nom_content.split("\n"):
                if "&" in line and not line.strip().startswith("%") and not line.strip().startswith("\\textbf"):
                    term = line.split("&")[0].strip().replace("$", "").replace("\\", "").strip()
                    if term:
                        defined_terms.add(term)
                        # Handle slash like AVX/AVX2
                        if "/" in term:
                            for part in term.split("/"):
                                defined_terms.add(part.strip())

    # Also extract from PDF Page where Nomenclature occurs
    for pnum, ptext in pages_text.items():
        if "Nomenclature" in ptext:
            lines = ptext.split("\n")
            in_nom = False
            for line in lines:
                if "Nomenclature" in line or "Acronym" in line or "Term" in line:
                    in_nom = True
                    continue
                if in_nom:
                    if "Background" in line or "3 Background" in line or "Related Work" in line:
                        in_nom = False
                        break
                    tokens = line.split()
                    if tokens and len(tokens[0]) >= 2 and tokens[0].isupper():
                        defined_terms.add(tokens[0])

    print("Defined Nomenclature Terms:", sorted(list(defined_terms)))

    # Scan for uppercase acronyms (length 2-6, all caps, or alphanumeric like AVX2, VNNI, Q4_K_M)
    # Exclude common English short words if capitalized like IT, AT, BE, IN, AS, ON, OR, US, IF
    common_stopwords = {"IT", "AT", "BE", "IN", "AS", "ON", "OR", "US", "IF", "BY", "AN", "DO", "NO", "TO", "SO", "HE", "WE", "MY", "OK", "II", "III", "IV", "VI", "VII", "VIII", "IX", "XI", "XII", "XIII", "XIV", "XV"}
    
    # Exclude Latin / Math symbols / Section headings
    found_acronyms = set()
    for pnum, ptext in pages_text.items():
        # find tokens
        tokens = re.findall(r"\b[A-Z][A-Z0-9_]{1,6}\b", ptext)
        for tok in tokens:
            # strip trailing punctuation
            tok = tok.strip(".,;:()")
            if len(tok) >= 2 and tok not in common_stopwords:
                # exclude section letters like "A", "B", "C" or Roman numerals
                if not re.match(r"^[IVXLCDM]+$", tok):
                    found_acronyms.add(tok)

    # Cross reference
    missing_acronyms = []
    for acr in sorted(list(found_acronyms)):
        # Check if acr or a variation is in defined_terms
        matched = False
        for dt in defined_terms:
            if acr.upper() == dt.upper() or acr.upper() in dt.upper() or dt.upper() in acr.upper():
                matched = True
                break
        if not matched:
            missing_acronyms.append(acr)

    # STEP 4: LAYOUT & WHITESPACE AUDIT
    # Page 15 whitespace audit
    p15_whitespace_pct = 0.0
    p15_failure = False
    with pdfplumber.open(PDF_PATH) as pdf:
        p15 = pdf.pages[14] # 0-indexed 15th page
        p_w, p_h = p15.width, p15.height
        total_page_area = p_w * p_h

        # Calculate bounding box of all words/drawings on page 15
        words_15 = p15.extract_words()
        if words_15:
            min_x0 = min(w["x0"] for w in words_15)
            max_x1 = max(w["x1"] for w in words_15)
            min_top = min(w["top"] for w in words_15)
            max_bottom = max(w["bottom"] for w in words_15)

            occupied_height = max_bottom - min_top
            occupied_width = max_x1 - min_x0
            # Total area fraction of page actually used
            # Also calculate vertical occupancy
            vertical_occupancy = occupied_height / p_h
            # In two column, if text only occupies left column (width ~ p_w/2) and top portion
            area_occupancy = (occupied_width * occupied_height) / total_page_area
            empty_whitespace_pct = (1.0 - (sum((w["x1"] - w["x0"]) * (w["bottom"] - w["top"]) for w in words_15) / (total_page_area * 0.5))) * 100.0 # conservative
            # simpler metric: vertical empty space at bottom of page
            bottom_empty_pct = ((p_h - max_bottom) / p_h) * 100.0
            total_whitespace_pct = (1.0 - (len(words_15) / 500.0)) * 100.0 # word density compared to normal 500-600 word page
            p15_whitespace_pct = max(bottom_empty_pct, 100.0 - (occupied_height / p_h * 100.0))
        else:
            p15_whitespace_pct = 100.0

        if p15_whitespace_pct > 40.0:
            p15_failure = True

        # Check top 50 pixels (points) of every page for headers
        header_ghosts = []
        for i, page in enumerate(pdf.pages):
            pnum = i + 1
            # words in top 50 points
            top_words = [w for w in page.extract_words() if w["top"] < 50]
            if top_words:
                top_text = " ".join(w["text"] for w in top_words)
                # Check if it contains header artifacts
                for susp in ["Preprint", "Anonymous", "Conference", "Kura:", "Storage-Native", "Under Review"]:
                    if susp.lower() in top_text.lower():
                        header_ghosts.append((pnum, top_text))
                        break

    # STEP 5: VECTOR GRAPHIC / EMBEDDED TEXT AUDIT (Figure 1 in particular)
    # Extract text from page 6 or where figures exist
    vector_graphic_texts = []
    with pdfplumber.open(PDF_PATH) as pdf:
        for i, page in enumerate(pdf.pages):
            pnum = i + 1
            # Check if page has curves/rects/drawings typical of figures
            if len(page.curves) > 5 or len(page.rects) > 5:
                # Find text situated within regions containing curves
                # Or check words on this page
                fig_words = [w["text"] for w in page.extract_words()]
                # Check for architecture keywords
                for kw in ["pread64", "io_uring", "RamArena", "Loom", "Spectral", "Weight Storage", "Slab", "Arena", "Asynchronous"]:
                    if kw in fig_words:
                        vector_graphic_texts.append(f"Page {pnum} (Figure region): contains '{kw}'")
                        break

    # GENERATE forensic_audit_report.md
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        f.write("# FORENSIC PDF AUDIT REPORT\n\n")
        f.write(f"**Target**: `{PDF_PATH}`\n")
        f.write(f"**Total Pages Processed**: {total_pages}\n\n")

        f.write("## 1. Ghost Match Matrix\n\n")
        if not ghost_matches:
            f.write("0 matches found in raw text dump.\n\n")
        else:
            f.write("| Page | Ghost Category | Surrounding Match Text |\n")
            f.write("|---|---|---|\n")
            for pnum, cat, text in ghost_matches:
                clean_text = text.replace("|", "\\|")[:120]
                f.write(f"| Page {pnum} | {cat} | `{clean_text}` |\n")
            f.write("\n")

        f.write("## 2. Vector Graphic & Figure Text Extraction\n\n")
        f.write(f"Audited vector objects across all {total_pages} pages.\n")
        for item in set(vector_graphic_texts):
            f.write(f"- {item}\n")
        f.write("\n")

        # Specific Fig 1 check:
        fig1_pdf = "/home/renan/Downloads/projects/Kura/kura_final_research_verified/manuscript/latex/figures/fig1_kura_architecture.pdf"
        if os.path.exists(fig1_pdf):
            with pdfplumber.open(fig1_pdf) as f1:
                f1_text = " ".join([w["text"] for w in f1.pages[0].extract_words()])
                f.write(f"**Figure 1 Standalone Vector Asset Raw Text**:\n`{f1_text}`\n\n")
                if "O_DIRECT" in f1_text:
                    f.write("🚨 **CRITICAL ALERT**: O_DIRECT DETECTED IN FIGURE 1 STANDALONE ASSET!\n\n")
                else:
                    f.write("✅ **FIGURE 1 CLEAN**: O_DIRECT is absent from standalone vector asset.\n\n")

        f.write("## 3. Abbreviation & Nomenclature Audit\n\n")
        f.write(f"**Defined Terms in Nomenclature Table ({len(defined_terms)})**:\n")
        f.write(", ".join(sorted(list(defined_terms))) + "\n\n")
        f.write(f"**Acronyms Used in Document Missing from Nomenclature Table ({len(missing_acronyms)})**:\n")
        if missing_acronyms:
            f.write(", ".join(missing_acronyms) + "\n\n")
        else:
            f.write("0 missing acronyms detected.\n\n")

        f.write("## 4. Layout & Whitespace Audit\n\n")
        f.write(f"- **Final Page (Page 15) Empty Whitespace**: {p15_whitespace_pct:.2f}%\n")
        if p15_failure:
            f.write("  - ⚠️ **Status**: `Float/Layout Failure` (>40% empty whitespace on final page)\n")
        else:
            f.write("  - ✅ **Status**: Passed (<=40% whitespace)\n")

        f.write(f"- **Top Margin (0-50pt) Header Audit**:\n")
        if header_ghosts:
            f.write(f"  - 🚨 **Status**: `Header Ghost Present` ({len(header_ghosts)} violations detected)\n")
            for pnum, htext in header_ghosts:
                f.write(f"    - Page {pnum}: `{htext}`\n")
        else:
            f.write("  - ✅ **Status**: Zero running header ghosts detected across all pages.\n\n")

    print(f"Report generated at {REPORT_PATH}")

if __name__ == "__main__":
    run_audit()
