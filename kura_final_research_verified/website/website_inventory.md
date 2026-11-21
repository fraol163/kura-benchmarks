# KURA Official Website Inventory

**Target URL**: https://kuracpu.vercel.app  
**Host & Platform**: Vercel Serverless Hosting / Single Page Application (Vite + React)  
**Main Bundle**: `/assets/index-C5AhzZhO.js` (797,205 bytes)  
**Styling**: `/assets/index-Dw_qH3Zd.css`  
**Interactive Widgets**: `/mini-me.js` (by Fraol Teshome)  
**Author & Developer**: Fraol Teshome  
**Contact**: fraolteshome444@gmail.com | Telegram: `@mememe12334` | Telephone: `+251914465363` (project metadata)  
**Official Repository**: https://github.com/fraol163/kura-benchmarks  
**Inspection Date**: November 20, 2026  

---

## 1. Route and Component Inventory

The website is structured as a client-side routed documentation portal with 44 major content modules across 8 logical categories:

| Section / Category | Slug / ID | Title & Focus | Extracted Components |
| :--- | :--- | :--- | :--- |
| **Overview & Target Audience** | `target-audience` | Target Audience & Fit Matrix | Target developers, hardware constraints, when NOT to use Kura |
| **System Prerequisites** | `linux-primary` | Linux (Primary Target), macOS, Windows | Kernel configs (`elevator=none`, swap disable, `cgroup v2`) |
| **Installation & Setup** | `quickstart` | Quick Start: 3-Minute Setup | Bootstrap install script (`curl -fsSL .../install.sh`), PATH setup, `kura doctor` |
| **Model Management** | `recommended-starter` | OLMoE 1B-7B & Model Pulling | `kura models pull`, checksum verification, disk management |
| **Hardware Profiling** | `running-profile` | SENSE Hardware Profiler | `kura profile`, operational ratio $R$, NUMA probing |
| **Troubleshooting** | `oom-errors` | Common Diagnostics | Memory budget exceeded, slow decoding, permission issues |
| **Architecture Specifications** | `loom-subsystem` | Loom, Ember, Prefetch, SIMD | GGUF fragmentation, 3-tier memory (Hot/Warm/Cold), double buffering |
| **Phase 24 Scientific Audit** | `audit-overview` | Audit Methodology & Summary | 17 Proven (65.4%), 2 Supported, 2 Partial, 2 Experimental, 3 Rejected |
| **Empirical Benchmarks** | `throughput-matrix` | Physical Hardware Testbed | AMD Ryzen 3 3250U, 5.7GB RAM, SATA SSD, OLMoE steady-state decode |
| **Ablation Ladder** | `ablation-data` | Step-by-Step Cumulative Speedup | 6-step ablation ladder (4.9 tok/s to 12.09 tok/s (Trace-replayed I/O characterization on 8-layer proxy)) |
| **API & Protocol** | `protocol` | Drop-in OpenAI API Specification | `POST /v1/chat/completions`, `GET /v1/models` |
| **Citation & Reproduction** | `bibtex` | Academic Citation & Reproduction | BibTeX entry, APA/MLA/IEEE, repository reproduction rights |

---

## 2. Inaccessible or Missing Resources

- **Direct Google Drive Upload Mount**: No external Google Drive file-system mount is active in the host execution environment. Local verified copies and Git release manifests were utilized instead.
- **Backend Analytics / Private Telemetry**: The website strictly enforces a Zero-Telemetry Ironclad Rule; no private user tracking endpoints or external metrics collection servers exist.
