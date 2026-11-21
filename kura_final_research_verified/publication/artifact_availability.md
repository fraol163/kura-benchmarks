# Artifact Availability and Reproducibility Statement

**Paper**: Kura: Storage-Native Decoupled Inference for Memory-Constrained Mixture-of-Experts  
**Author**: Fraol Teshome (Independent Researcher)  
**Date**: November 20, 2026  

---

## 1. Artifact Availability Overview

To promote open science and empirical reproducibility, all source code, layout compilers, mathematical solvers, benchmark scripts, raw telemetry logs, and figure generation routines are openly accessible.

- **Primary Source Code Repository**: `https://github.com/fraol163/kura-benchmarks`
- **Official Project Website**: `https://kuracpu.vercel.app`
- **Cryptographic Evidence Manifest**: `v1.2_FREEZE_MANIFEST.json` (SHA-256 signatures for all historical benchmark records)

---

## 2. ACM / IEEE Artifact Badges Targeted

This research artifact is prepared to satisfy the requirements for three standard ACM Artifact Badges:

1. **Artifacts Available**:
   - All source code, benchmarks, and data are hosted on a publicly accessible, permanent version-controlled repository with open licenses.
2. **Artifacts Evaluated – Functional**:
   - The repository includes comprehensive documentation, build instructions, unit test suites (262 deterministic test assertions), and end-to-end execution scripts.
3. **Results Reproduced (Historical Benchmark Audit)**:
   - Complete raw JSON telemetry files for all reported benchmarks are included alongside the exact Python scripts used to generate publication figures and CSV tables.

---

## 3. Directory Layout of Research Deliverables

The complete scientific research package is organized within `kura_final_research/`:

```
kura_final_research/
├── FINAL_REPORT.md                        # Master forensic executive report
├── figure_evidence_matrix.csv             # Provenance mapping for all 9 figures
├── figure_data/                           # Exact CSV data files used to plot figures
│   ├── fig2_random_reads.csv
│   ├── fig3_storage_traffic.csv
│   ├── fig4_olmoe_cold_ttft.csv
│   ├── fig5_throughput.csv
│   ├── fig6_ram_sweep.csv
│   ├── fig7_overhead_breakdown.csv
│   ├── fig8_four_way_ablation.csv
│   └── fig9_ember_fidelity.csv
├── figures/                               # Generated publication figures (PDF & PNG)
│   ├── fig1_kura_architecture.{pdf,png}
│   ├── fig2_random_read_reduction.{pdf,png}
│   ├── fig3_storage_traffic.{pdf,png}
│   ├── fig4_olmoe_cold_ttft.{pdf,png}
│   ├── fig5_generation_throughput.{pdf,png}
│   ├── fig6_memory_budget_sweep.{pdf,png}
│   ├── fig7_overhead_breakdown.{pdf,png}
│   ├── fig8_four_way_ablation.{pdf,png}
│   └── fig9_ember_latency_fidelity.{pdf,png}
├── figure_scripts/
│   └── generate_all_figures.py            # Reproducible figure plotting script
├── manuscript/
│   ├── kura_research_paper.pdf            # 23-page compiled publication PDF
│   └── latex/                             # Complete LaTeX source files
├── audit/                                 # Forensic audit reports and defect registers
│   ├── uploaded_manuscript_audit.md
│   ├── page_by_page_defect_register.csv
│   ├── mathematical_verification.md
│   ├── citation_integrity_report.md
│   ├── benchmark_forensic_audit.md
│   └── final_gate_results.md
├── website/                               # Website forensics & extracted knowledge
│   ├── website_inventory.md
│   ├── website_extracted_knowledge.md
│   ├── website_claim_verification.csv
│   ├── website_repository_crosscheck.md
│   └── website_manuscript_gap_analysis.md
├── evidence/                              # Empirical ledgers and contribution matrices
│   ├── claim_evidence_matrix.csv
│   ├── benchmark_results_verified.csv
│   ├── experimental_provenance.md
│   ├── contribution_matrix.md
│   └── reproducibility.md
├── reviews/                               # Peer reviews and gap analyses
│   ├── adversarial_peer_review.md
│   ├── novelty_assessment.md
│   └── unresolved_research_gaps.md
└── publication/                           # Publication readiness documents
    ├── venue_comparison.md
    ├── formatting_compliance.md
    ├── submission_checklist.md
    └── artifact_availability.md
```

---

## 4. Hardware and Software Requirements for Reproduction

### 4.1. Software Environment
- **Operating System**: Linux (Ubuntu 20.04+, Debian 11+, or Arch Linux with kernel $\ge 5.10$).
- **Toolchain**: Rust 1.75+ (`cargo`, `rustc`), Python 3.10+ (`matplotlib`, `numpy`, `pandas`, `pymupdf`).
- **LaTeX Compiler**: Tectonic 0.17.0+ or TeX Live 2023+ (`pdflatex`, `bibtex`).

### 4.2. Hardware Platform Considerations
- **Primary Historical Benchmarks**: Conducted on a 24-core Intel Xeon w5-3425 workstation with Samsung 990 PRO NVMe SSD and 64 GB DDR5 RAM.
- **Lightweight Verification**: Deterministic kernel tests (262 assertions) and mathematical verification scripts can be executed safely on commodity laptops (e.g., AMD Ryzen 3 3250U, 6 GB RAM).
