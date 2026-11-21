# Premier Research Venue Comparison for Kura

**Target Work**: Kura: Storage-Native Decoupled Inference for Memory-Constrained Mixture-of-Experts  
**Author**: Fraol Teshome (Independent Researcher)  
**Date**: November 20, 2026  

---

## 1. Overview of Suitable Venues

Kura operates at the intersection of **Computer Systems Engineering** (operating systems, asynchronous I/O, memory architectures) and **Machine Learning Systems** (sparse Transformer inference, routing dynamics, low-rank approximations). Choosing the optimal venue requires evaluating the technical focus, review expectations, and publication cycles.

---

## 2. Comparative Analysis Matrix

| Venue | Primary Focus | Best Fit Reason | Potential Reviewer Concerns | Page Limit & Format | Submission Cycles |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **MLSys**<br>*(Conference on Machine Learning and Systems)* | Intersection of ML algorithms and hardware/systems design | **Ideal Tier-1 Match**. Values end-to-end ML serving efficiency, low-level systems profiling, and hardware-software co-design. | Will scrutinize batch size 1 limitation; will expect comparison against vLLM/DeepSpeed on GPU (must clarify CPU/edge focus). | 10 pages excluding references and appendix (MLSys template). | Annual (Typically October/November). |
| **EuroSys**<br>*(European Conference on Computer Systems)* | Operating systems, storage systems, distributed systems | **Strong Tier-1 Match**. Deep appreciation for Direct I/O (`io_uring`), kernel bypass, zero-copy allocators, and detailed micro-profiling. | Will heavily critique the synchronous memory arena mutation bottleneck; will demand rigorous OS baseline comparisons. | 12 pages excluding references (ACM template). | Bi-annual (Spring & Fall deadlines). |
| **ASPLOS**<br>*(Architectural Support for Prog. Lang. & OS)* | Architecture, OS, compilers, hardware interfaces | **Excellent Match**. Highlights the co-design of physical storage layout (Loom), memory hierarchy (RamArena), and predictive algorithms. | Expects detailed PCIe bus and cache-line memory traffic analysis (e.g., VTune/perf hardware counters). | 11 pages excluding references (ACM template). | Multi-deadline (Spring, Summer, Fall). |
| **USENIX ATC**<br>*(Annual Technical Conference)* | Practical computer systems, storage, file systems, I/O | **High Match**. Values solid empirical engineering, real working code, transparent negative results, and Linux systems internals. | Pragmatic reviewers will want to see end-to-end user application benchmarks (e.g., real-time chat latency). | 11 pages excluding references (USENIX template). | Bi-annual (January and April deadlines). |
| **OSDI / SOSP**<br>*(Symposium on Operating Systems Principles)* | Premier operating systems research | Highest prestige; would showcase out-of-RAM decoupled inference paradigm. | Extremely high bar for conceptual architectural breakthrough; requires resolving the arena allocation bottleneck first. | 12 pages excluding references (USENIX/ACM template). | Annual (Rotating deadlines). |

---

## 3. Official Submission Requirements by Target Venue

### 3.1. MLSys (Conference on Machine Learning and Systems)
- **Review Model**: Double-Blind (Author names, affiliations, acknowledgments, and self-identifying repository links must be strictly anonymized in the submission PDF).
- **Page Limits**: 10 pages for the main technical paper (including text, figures, tables). Unlimited pages for references and supplementary appendix.
- **Dual-Submission Policy**: Work must not be simultaneously submitted to another peer-reviewed conference or journal. Preprints on arXiv or project websites are permitted, but authors must not advertise the specific submission venue.
- **Artifact Evaluation**: MLSys encourages artifact evaluation for accepted papers. Badges: Artifacts Available, Functional, and Reproduced.
- **Formatting Template**: Standard MLSys LaTeX style files (`mlsys2025.sty`).

### 3.2. EuroSys (European Conference on Computer Systems)
- **Review Model**: Double-Blind (Strict anonymization of source code repositories, commits, and affiliations).
- **Page Limits**: 12 pages excluding references (ACM SIGOPS format). Appendix permitted within the submission file or as supplementary material.
- **Artifact Evaluation**: Mandatory for badge eligibility; evaluated by the EuroSys Artifact Evaluation Committee (AEC).
- **Rebuttal Phase**: Authors receive preliminary reviews and submit a 1,000-word rebuttal before final decisions.

### 3.3. USENIX ATC (Annual Technical Conference)
- **Review Model**: Double-Blind.
- **Page Limits**: 11 pages of technical content, plus unlimited pages for references.
- **Operational Requirement**: Focus on practical systems implementation and demonstrable source code.

---

## 4. Venue Recommendation and Strategic Roadmap

### Primary Recommendation: **MLSys 2026 / 2027**
- **Rationale**: Kura's focus on sparse MoE routing dynamics, low-rank SVD sketches (Ember), and memory-constrained LLM inference aligns directly with MLSys's mission. The community appreciates the intersection of predictive algorithms (CRF/KAEF) with direct storage systems (`io_uring`).
- **Preparation Step**: Ensure that the CPU-workstation and edge developer use-case is articulated prominently in the abstract and introduction so reviewers do not penalize the absence of multi-GPU cluster evaluations. Toggle anonymous mode for initial submission.

### Secondary Recommendation: **EuroSys or USENIX ATC**
- **Rationale**: If the author wishes to highlight the storage and operating system aspects (kernel bypass, physical layout compilation, Linux slab allocation), EuroSys or USENIX ATC offers an audience that deeply values Linux systems engineering and honest reporting of non-monotonic performance regimes.
