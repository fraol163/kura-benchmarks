# KURA Research Audit Remediation Plan

**Document Version**: 2.0 (Remediated)  
**Author**: Principal Systems Researcher, Scientific Reproducibility Engineer & Auditor  
**Date**: November 20, 2026  
**Status**: APPROVED & EXECUTED  

---

## 1. Summary of Identified Defects & Remediation Strategy

Following independent adversarial inspection of the preliminary `kura_final_research_complete.zip` archive, three categories of critical deficiencies were identified and addressed:

| Defect ID | Category | Discovered Problem | Root Cause | Remediated Evidence & Action Taken |
| :---: | :--- | :--- | :--- | :--- |
| **DEF-01** | **Website Extraction** | Previous report claimed 44 routes, 68,412 chars, 9,842 words, 100% coverage. In reality, `accessible_content_archive.json` contained 44 text blocks (22,475 chars, 3,191 words) with an empty `structured_pages: []` array. | Crude regex matching only backtick-delimited IDs, missing 21 pages and structured metadata. | Wrote full AST parser for `index-C5AhzZhO.js`, extracting all 10 navigation categories (`b`), 63 routed documentation pages, and 2 interactive apps (65 total) with **95,944 characters** and **13,367 words** into `website_rendered_content.json`. |
| **DEF-02** | **Figure Reproducibility** | Previous script had hardcoded numerical constants and the package omitted the raw benchmark JSON files required to reproduce Figures 1–9. | Lack of self-contained raw data bundle in the deliverable archive. | Created self-contained `evidence/raw/` directory containing all 11 raw JSON telemetry files, computed `evidence/manifest.json`, and re-implemented `generate_all_figures.py` using portable relative paths and programmatic dynamic parsing. |
| **DEF-03** | **Ember Latency Baseline** | Previous draft conflated 3,757.60 ms vs 739.40 ms (+408.2% increase) with the +892.1% degradation from the 56.40 ms unassisted gate. | Conflating two incompatible baseline benchmarks (Synthetic MoE 56.4 ms gate vs Full Model 739.4 ms completion). | Formally unbundled and traced both experiments in the manuscript, Figure 9, CSV datasets, and audit documents. |
| **DEF-04** | **Ablation Transparency** | Verification of four-way ablation (1,315 ms, 822 ms, 610 ms, 536 ms) required proving whether hardware/models were controlled. | Ambiguity in provenance documentation. | Traced to `ablation_cd.json`: all four runs share identical 24 MB RAM limits, Synthetic MoE model, cold page drops, and Xeon w5-3425 host. Proven to be a strictly controlled 4-way ablation. |
| **DEF-05** | **KAEF Regimes Accuracy** | Need to explicitly account for the non-monotonic +37.64% speedup at 64 MB alongside regressions at 24 MB, 32 MB, 48 MB, 128 MB. | Risk of oversimplifying non-monotonic operating regimes. | Fully verified all 7 data points in `ram_sweep.json` and presented complete comparative table in Section 12. |
| **DEF-06** | **Historical Freeze Manifest** | Need to locate and verify authentic `v1.2_FREEZE_MANIFEST.json` without substituting new files as historical evidence. | Provenance traceability check. | Located authentic historical manifest from September 18, 2026 (commit `966dc519fb720cdecd5ef5f7e4a031b22ff95aec`) and verified its presence in `evidence/`. |

---

## 2. Verification Gates & Execution Status

All remediation steps are executed against authentic raw files, verified with programmatic checksums, and documented for independent reproducibility.
