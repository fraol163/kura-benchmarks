# KURA Audit Remediation Changelog

**Package**: `kura_final_research_verified`  
**Date**: November 20, 2026  
**Author**: Principal Systems Researcher, Reproducibility Engineer & Auditor  

---

## 1. Summary of Changes Applied

### A. Evidence & Raw Data Self-Containment
- **Added `evidence/raw/`**: Bundled all 11 authentic historical JSON benchmark records (`m2_correctness_determinism.json`, `m3_real_moe_benchmarks.json`, `m4_regime_maps.json`, `m5_ablations.json`, `m6_ember_gate.json`, `m7_reliability_security.json`, `ram_sweep.json`, `overhead_breakdown.json`, `ablation_cd.json`, `ember_diagnostic.json`, `ember_usefulness.json`).
- **Added `evidence/manifest.json`**: Generated cryptographic SHA-256 inventory for all raw evidence files.
- **Added `evidence/v1.2_FREEZE_MANIFEST.json`**: Located and preserved the authentic historical freeze manifest from September 18, 2026 (commit `966dc519fb720cdecd5ef5f7e4a031b22ff95aec`).

### B. Scientific Figure Generation & Reproducibility
- **Rewrote `figure_scripts/generate_all_figures.py`**:
  - Removed all hardcoded constants; replaced with programmatic extraction from `evidence/raw/`.
  - Removed machine-dependent `/home/renan/...` paths; replaced with portable relative path resolution.
  - Formally segregated Figure 1 as a conceptual systems diagram.
  - Regenerated all intermediate CSV datasets in `figure_data/`.
  - Regenerated all 9 figures in vector PDF and 300 DPI PNG formats in `figures/` and `manuscript/latex/figures/`.
- **Created `FIGURE_EVIDENCE_MATRIX.md`**: Mapped every plotted point, formula, hardware setup, and JSON field for Figures 1–9.
- **Created `REPRODUCE.md`**: Provided standalone instructions to reproduce the figure suite on clean environments in under 60 seconds.

### C. Website Extraction & Content Completeness
- **Fixed Extraction Defect**: Identified and corrected the regex bug in `extract_all_website_pages.py` that caused previous runs to miss 21 pages and output an empty structured array.
- **Extracted Complete Website State**: Parsed JavaScript AST navigation `b`, landing dictionary `x`, and subsystem dictionary `y`, capturing **all 10 categories, 63 routed pages, and 2 interactive sandboxes (65 total)**.
- **Reconciled Text Metrics**:
  - Previous defective report: 44 blocks, 22,475 chars, 3,191 words.
  - Remediated verified corpus: **65 structured pages, 95,944 characters, 13,367 words**.
- **Generated Detailed Website Reports**:
  - `website/website_route_inventory.md`
  - `website/website_rendered_content.json`
  - `website/website_coverage_report.md`
  - `website/website_unresolved_pages.md`
  - `WEBSITE_COVERAGE_EVIDENCE.md`

### D. Scientific Accuracy & Latency Unbundling
- **Corrected Ember SVD Latency**:
  - Unbundled 739.40 ms vs 3,757.60 ms (**+408.2% cold TTFT increase**) from the 56.40 ms vs 559.57 ms (**+892.1% degradation**) Synthetic MoE decision gate.
  - Updated text in `02_intro.tex`, `09_ember.tex`, Figure 9, and `fig9_ember_fidelity.csv`.
- **Characterized KAEF Memory Regimes**:
  - Verified all 7 points in `ram_sweep.json` (16 MB to 256 MB), explicitly documenting the +37.64% speedup at 64 MB alongside regressions at 24 MB, 32 MB, 48 MB, 128 MB, and ample RAM LRU dominance.
- **Verified Four-Way Ablation**:
  - Confirmed that all four stages in `ablation_cd.json` (Baseline LRU 1315 ms, KAEF 822 ms, Loom+LRU 610 ms, Loom+KAEF 536 ms) were evaluated under identical 24 MB RAM budgets on Synthetic MoE on the Xeon w5-3425 host.

### E. Manuscript & Publication Integrity
- **Maintained Authorship**: Sole author **Fraol Teshome**, Independent Researcher.
- **Preserved Privacy**: Excluded private telephone number from public PDF.
- **Enforced Preprint Status**: Header set to `Preprint. Work in progress.`. No false conference acceptance or external peer review claims.
- **Verified References**: Zero broken `(?)` or `??` references across all 23 pages of `kura_research_paper.pdf`.
