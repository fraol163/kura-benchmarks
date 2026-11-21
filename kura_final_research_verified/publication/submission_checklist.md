# Academic Paper Submission Checklist

**Title**: Kura: Storage-Native Decoupled Inference for Memory-Constrained Mixture-of-Experts  
**Author**: Fraol Teshome (Independent Researcher)  
**Target Submission**: Peer-Reviewed Systems / ML Conference  
**Date**: November 20, 2026  

---

## 1. Pre-Submission Verification Steps

### 1.1. Authorship and Ethical Attributions
- [x] Author name confirmed as **Fraol Teshome**.
- [x] Affiliation set as **Independent Researcher**.
- [x] Contact email verified as **fraolteshome444@gmail.com**.
- [x] Project website linked as **https://kuracpu.vercel.app**.
- [x] Private telephone number (+251914465363) excluded from public PDF.
- [x] No fabricated affiliations, institutions, or co-authors.

### 1.2. Scientific Rigor and Evidence Accuracy
- [x] Every numerical claim verified against raw benchmark JSON/CSV files.
- [x] OLMoE cold TTFT reductions reported transparently as $20.03\%$ to $26.00\%$ across historical runs.
- [x] OLMoE token throughput gains reported as $+12.15\%$ to $+14.38\%$ (both reaching 12.09 tok/s).
- [x] Figure 2/3 memory budget explicitly identified as 16 MB (Synthetic MoE, $10.4\times$ memory pressure), correcting the previous 4 GB misstatement.
- [x] Loom's Fiedler vector sorting qualified as a continuous spectral relaxation heuristic for 1D-MLA, not an unconstrained discrete global minimum.
- [x] Ember Mode C provisional draft preview (0.16 ms, $1.99\%$ divergence) explicitly unbundled from full exact token completion (739.40 ms).
- [x] High-RAM inversion regimes and intermediate memory regressions (24 MB–128 MB) documented with complete empirical tables.
- [x] Decommissioning of the primary Xeon workstation acknowledged as an environmental reproducibility limitation.

### 1.3. Manuscript Package Integrity
- [x] `kura_research_paper.pdf` compiled cleanly with Tectonic (zero compilation errors).
- [x] Verified zero broken citations (`(?)`) and zero undefined references (`??`).
- [x] Header reads `Preprint. Work in progress.`.
- [x] All 9 figures embedded in high-resolution vector PDF and 300 DPI PNG format.
- [x] BibTeX entries validated against authentic digital object identifiers (DOIs) and DBLP/arXiv records.

---

## 2. Submission Files Inventory

When submitting to an academic conference portal (e.g., OpenReview, HotCRP), upload the following files from `/home/renan/Downloads/projects/Kura/kura_final_research/`:

1. **Main Paper PDF**: `manuscript/kura_research_paper.pdf`
2. **LaTeX Source Archive**: `manuscript/latex/` (containing `main.tex`, `references.bib`, `iclr2025_conference.sty`, `sections/`, `appendix/`, `figures/`)
3. **Artifact Package**: `figure_data/` (raw CSVs), `figures/` (high-res vector graphics), and `evidence/` (provenance ledgers)
4. **Anonymized Submission Version** (if required by venue double-blind policy):
   - Toggle `\author{Anonymous Authors}` in `main.tex` and recompile.
