# Comprehensive Forensic Audit of Uploaded Manuscript

**Target Document**: `kura_research_manuscript.pdf` & associated LaTeX sources  
**Auditor**: Principal Independent Verification Auditor  
**Date**: November 20, 2026  
**Audit Scope**: Forensic inspection of every page, section, table, equation, citation, caption, footnote, and appendix.

---

## 1. Executive Summary & Critical Findings

The initial manuscript suffered from 6 critical defects that would undermine its scientific credibility or trigger immediate desk rejection:

1. **False Publication Header (CRITICAL)**:
   - *Problem*: Page headers displayed `Published as a conference paper at ICLR 2025`.
   - *Forensic Cause*: Hardcoded string in `iclr2025_conference.sty` line 88 activated by `\iclrfinalcopy`.
   - *Correction*: Replaced with `Preprint. Work in progress.`.
2. **Fabricated Group Authorship (CRITICAL)**:
   - *Problem*: Listed "Fraol Teshome", "Independent Research Division", and "contact@kura-project.org".
   - *Correction*: Replaced with actual researcher and developer: **Fraol Teshome**, Independent Researcher, `fraolteshome444@gmail.com`, `https://kuracpu.vercel.app`. Telephone retained in private metadata.
3. **Broken / Unresolved Bibliography Keys (CRITICAL)**:
   - *Problem*: Text rendered `vLLM (?)`, `MoE-Infinity (?)`, `SVD-LLM (?)`.
   - *Forensic Cause*: In `04_related_work.tex`, citation keys were written as `\citep{kwon2023efficient}`, `\citep{tan2024moe}`, `\citep{wang2024svd}`, whereas `references.bib` defined `kwon2023vllm`, `gao2024moeinfinity`, `wang2024svdllm`.
   - *Correction*: Reconciled citation keys in both `.tex` and `.bib`, verifying full bibliographic metadata against authoritative peer-reviewed proceedings.
4. **Incorrect Memory-Budget Caption in Figure 2 (MAJOR)**:
   - *Problem*: Figure 2 caption claimed a "58.7% storage-traffic reduction under a 4 GB RAM budget".
   - *Forensic Cause*: Under 4 GB, a 166 MB model fits 100% in memory with zero storage traffic. The actual historical experiment in `M4_REGIME_MAPS.md` and `m4_regime_maps.json` evaluated `shared-small.gguf` under a **16 MB RAM ceiling** (15,654,144 bytes to 6,462,720 bytes per token = -58.71%).
   - *Correction*: Corrected caption, text, and tables to report the exact 16 MB memory budget.
5. **Unsupported Mathematical Optimization Claim in Loom (MAJOR)**:
   - *Problem*: Stated that sorting the Fiedler vector "minimizes the cut weight" of the 1D graph arrangement.
   - *Mathematical Truth*: 1D graph arrangement / minimum cut is NP-hard. Spectral ordering solves a continuous Rayleigh quotient relaxation; sorting the Fiedler vector is a heuristic discrete approximation, not a proven global minimum.
   - *Correction*: Qualified the derivation as a spectral relaxation heuristic.
6. **Unverified Public Release Claims in Abstract (MAJOR)**:
   - *Problem*: Abstract claimed all blueprints and traces are "openly released" without providing working repository URLs.
   - *Correction*: Tied release statements directly to Fraol Teshome's GitHub repository: `https://github.com/fraol163/kura-benchmarks`.

---

## 2. Classification of Audit Findings

| Category | Total Issues | Critical | Major | Minor | Verified / Resolved |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Publication Status & Header | 1 | 1 | 0 | 0 | 1 |
| Authorship & Attribution | 1 | 1 | 0 | 0 | 1 |
| Bibliography & Citations | 3 | 1 | 2 | 0 | 3 |
| Memory Budgets & Benchmarks | 4 | 0 | 4 | 0 | 4 |
| Mathematical Claims & Rigor | 3 | 0 | 2 | 1 | 3 |
| Ember Provisional Distinction | 2 | 0 | 2 | 0 | 2 |
| Hardware Speculation (ASPM/SLC) | 2 | 0 | 2 | 0 | 2 |
| Layout & Overfull HBoxes | 4 | 0 | 0 | 4 | 4 |
| **Total** | **20** | **3** | **12** | **5** | **20** |
