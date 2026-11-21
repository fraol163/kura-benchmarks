# Independent Scientific Reproducibility Guide

**Package**: `kura_final_research_verified`  
**Author**: Fraol Teshome (Independent Researcher)  
**Date**: November 20, 2026  
**Target Platform**: Linux (x86_64 or ARM64) / macOS / WSL2  

---

## 1. Quickstart: Reproduce All Figures in 60 Seconds

The entire scientific figure suite (Figures 1–9) can be independently regenerated from the authentic raw JSON benchmark files bundled directly in `evidence/raw/` without external internet access or hardcoded constants.

### Step 1: Environment Setup
Ensure Python 3.9+ is installed. Create a clean virtual environment:
```bash
# Unpack archive if not already unpacked
unzip kura_final_research_verified.zip
cd kura_final_research_verified

# Initialize clean virtual environment
python3 -m venv venv
source venv/bin/activate

# Install lightweight dependencies
pip install --upgrade pip
pip install matplotlib numpy pandas pymupdf
```

### Step 2: Regenerate All Figures & Datasets
Execute the portable generation script:
```bash
python figure_scripts/generate_all_figures.py
```

### Expected Output:
```text
Generating Figure 1: Conceptual Architecture Pipeline...
  [OK] Saved fig1_kura_architecture.pdf and fig1_kura_architecture.png
Generating Figure 2 & Figure 3 from m3_real_moe_benchmarks.json & m4_regime_maps.json...
  [OK] Saved fig2_random_read_reduction.pdf and fig2_random_read_reduction.png
  [OK] Saved fig3_storage_traffic.pdf and fig3_storage_traffic.png
Generating Figure 4 & Figure 5 from m3_real_moe_benchmarks.json...
  [OK] Saved fig4_olmoe_cold_ttft.pdf and fig4_olmoe_cold_ttft.png
  [OK] Saved fig5_generation_throughput.pdf and fig5_generation_throughput.png
Generating Figure 6 dynamically from ram_sweep.json...
  [OK] Saved fig6_memory_budget_sweep.pdf and fig6_memory_budget_sweep.png
Generating Figure 7 dynamically from overhead_breakdown.json...
  [OK] Saved fig7_overhead_breakdown.pdf and fig7_overhead_breakdown.png
Generating Figure 8 dynamically from ablation_cd.json...
  [OK] Saved fig8_four_way_ablation.pdf and fig8_four_way_ablation.png
Generating Figure 9 dynamically from m6_ember_gate.json...
  [OK] Saved fig9_ember_latency_fidelity.pdf and fig9_ember_latency_fidelity.png
All figures successfully generated programmatically from evidence/raw/!
```

All 9 figures will be written to `figures/` (vector PDF and 300 DPI PNG) and copied to `manuscript/latex/figures/`. Simultaneously, all numerical points are exported to `figure_data/*.csv`.

---

## 2. Recompiling the LaTeX Manuscript

The paper is typeset with standard LaTeX packages (`times`, `amsmath`, `booktabs`, `microtype`, `cleveref`).

### Using Tectonic (Zero Configuration):
```bash
cd manuscript/latex
tectonic main.tex
cp main.pdf ../kura_research_paper.pdf
```

### Using Standard TeX Live:
```bash
cd manuscript/latex
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
cp main.pdf ../kura_research_paper.pdf
```

---

## 3. Cryptographic Manifest Verification

To verify that the raw benchmark files in `evidence/raw/` have not been tampered with or modified from their historical freeze states:
```bash
python3 -c "
import json, hashlib, os
with open('evidence/manifest.json') as f:
    m = json.load(f)
for fname, meta in m['files'].items():
    p = os.path.join('evidence/raw', fname)
    with open(p, 'rb') as fp:
        actual = hashlib.sha256(fp.read()).hexdigest()
    assert actual == meta['sha256'], f'Mismatch for {fname}'
    print(f'[VERIFIED] {fname}: SHA-256 match')
print('All raw benchmark evidence files cryptographically verified!')
"
```

---

## 4. Hardware Environment Notes

- **Historical Primary Benchmarks**: Executed on an Intel Xeon w5-3425 workstation (24 cores, AVX-512, Samsung 990 PRO NVMe SSD, 64 GB DDR5 ECC RAM) under Linux kernel 6.5.0 with `cgroups v2` memory constraints.
- **Independent Audit & Figure Reproduction**: The bundled raw data and automated reproduction scripts require only standard POSIX environments and execute in seconds on any standard laptop.
