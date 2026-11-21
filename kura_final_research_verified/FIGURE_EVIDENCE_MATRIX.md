# Scientific Figure Evidence & Provenance Matrix

**Package**: `kura_final_research_verified`  
**Date**: November 20, 2026  
**Auditor**: Independent Scientific Reproducibility Auditor  
**Reproducibility Engine**: `figure_scripts/generate_all_figures.py`  
**Raw Data Directory**: `evidence/raw/`  

---

## 1. Figure Evidence Ledger

| Fig # | Figure Title & Type | Raw Benchmark File | JSON Fields / Source Keys | Intermediate CSV | Hardware & Configuration | Plotted Numerical Values | Reproducibility Verdict |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **Fig 1** | **Kura Architecture Pipeline**<br>*(Conceptual Systems Diagram)* | N/A (Conceptual Blueprint) | Systems Architecture (Loom, SENSE, KAEF, RamArena, SIMD) | N/A (Vector Diagram) | Linux bare-metal x86_64 | Modular crate hierarchy, DMA buffers, direct block streaming | **VERIFIED CONCEPTUAL** |
| **Fig 2** | **Random Read Reduction**<br>*(Empirical Bar Chart)* | `evidence/raw/m3_real_moe_benchmarks.json`<br>`evidence/raw/m4_regime_maps.json` | `secondary_model.metrics.baseline_kaef.rand_reads`<br>`secondary_model.metrics.loom_kaef.rand_reads` | `figure_data/fig2_random_reads.csv` | **OLMoE-1B-7B**: 256MB RAM<br>**Synthetic MoE**: 16MB RAM<br>Host: Intel Xeon w5-3425 | **OLMoE**: 216 $\to$ 71 (**-67.13%**)<br>**Synth MoE**: 248 $\to$ 76 (**-69.35%**) | **100% REPRODUCIBLE** |
| **Fig 3** | **Storage Traffic Reduction**<br>*(Empirical Bar Chart)* | `evidence/raw/m4_regime_maps.json`<br>`evidence/raw/m3_real_moe_benchmarks.json` | `shared_small_sweep.lru_storage_amp`<br>`shared_small_sweep.kaef_storage_amp` (16MB) | `figure_data/fig3_storage_traffic.csv` | **Synthetic MoE**: 16MB RAM (10.4x pressure)<br>**OLMoE**: 256MB RAM | **Synth MoE**: 14.93 $\to$ 6.16 MB/tok (**-58.71%**)<br>**OLMoE**: 48.60 $\to$ 21.30 MB/tok (**-56.17%**) | **100% REPRODUCIBLE** |
| **Fig 4** | **OLMoE Cold TTFT Reduction**<br>*(Empirical Grouped Bar)* | `evidence/raw/m3_real_moe_benchmarks.json` | `secondary_model.metrics.baseline_kaef.ttft_ms`<br>`secondary_model.metrics.loom_kaef.ttft_ms` | `figure_data/fig4_olmoe_cold_ttft.csv` | **OLMoE-1B-7B**: 256MB RAM<br>Kernel: cgroups v2, drop_caches | **Run A**: 338.90 $\to$ 250.80 ms (**-26.00%**)<br>**Run B**: 330.43 $\to$ 264.24 ms (**-20.03%**) | **100% REPRODUCIBLE** |
| **Fig 5** | **Generation Throughput Scaling**<br>*(Empirical Grouped Bar)* | `evidence/raw/m3_real_moe_benchmarks.json` | `secondary_model.metrics.baseline_kaef.tokens_per_s`<br>`secondary_model.metrics.loom_kaef.tokens_per_s` | `figure_data/fig5_throughput.csv` | **OLMoE-1B-7B**: 256MB RAM<br>Sequence: 64 tokens | **Run A**: 10.78 $\to$ 12.09 tok/s (**+12.15%**)<br>**Run B**: 10.57 $\to$ 12.09 tok/s (**+14.38%**) | **100% REPRODUCIBLE** |
| **Fig 6** | **RAM Capacity Sweep & Hit Rate**<br>*(Dual-Panel Line Plots)* | `evidence/raw/ram_sweep.json` | `points[].budget_mb`<br>`points[].lru_tok_s`<br>`points[].kaef_tok_s`<br>`points[].lru_hit_rate`<br>`points[].kaef_hit_rate` | `figure_data/fig6_ram_sweep.csv` | **Synthetic MoE**: 166.08MB<br>Budgets: 16MB to 256MB<br>Host: Intel Xeon w5-3425 | **16MB**: 2.78 $\to$ 4.73 tok/s (**+70.09%**)<br>**24MB**: 7.66 $\to$ 1.70 tok/s (**-77.78%**)<br>**32MB**: 5.50 $\to$ 2.27 tok/s (**-58.81%**)<br>**48MB**: 5.80 $\to$ 5.01 tok/s (**-13.52%**)<br>**64MB**: 6.38 $\to$ 8.78 tok/s (**+37.64%**)<br>**128MB**: 8.54 $\to$ 5.80 tok/s (**-32.03%**)<br>**256MB**: 124.0 $\to$ 38.6 tok/s (**-68.87%**) | **100% REPRODUCIBLE** |
| **Fig 7** | **KAEF Overhead Decomposition**<br>*(Donut + Horizontal Bar)* | `evidence/raw/overhead_breakdown.json` | `kaef_decision_application_ms`<br>`kaef_counterfactual_search_ms`<br>`kaef_mec_calculation_ms`<br>`kaef_forecasting_ms`<br>`kaef_resource_pricing_ms` | `figure_data/fig7_overhead_breakdown.csv` | High-resolution micro-profiler<br>Total epoch: 4,779.15 ms | **Arena mutation**: 4,772.54 ms (**99.86%**)<br>**Algorithmic search**: 6.60 ms (**0.14%**)<br>• Search: 3.88 ms<br>• MEC: 1.39 ms<br>• Forecast: 1.07 ms<br>• Pricing: 0.26 ms | **100% REPRODUCIBLE** |
| **Fig 8** | **Four-Way Subsystem Ablation**<br>*(Dual-Axis Bar & Line Plot)* | `evidence/raw/ablation_cd.json` | `a_lru`, `b_kaef`, `c_lru_loom`, `d_kaef_loom`:<br>• `ttft_ms`<br>• `tokens_per_s`<br>• `rand_reads`<br>• `seq_reads`<br>• `timing.nvme_io_ns` | `figure_data/fig8_four_way_ablation.csv` | **Synthetic MoE**: 24MB RAM<br>Host: Intel Xeon w5-3425<br>All 4 runs strictly controlled | **Baseline LRU**: 1,315.36 ms (4.02 tok/s)<br>**KAEF Only**: 821.73 ms (2.52 tok/s)<br>**Loom + LRU**: 609.59 ms (6.83 tok/s)<br>**Loom + KAEF**: 535.64 ms (5.05 tok/s) | **100% REPRODUCIBLE** |
| **Fig 9** | **Ember Latency & Fidelity Modes**<br>*(Log-Scale Bar Chart)* | `evidence/raw/m6_ember_gate.json` | `usefulness_modes.mode_b_draft_ttft_ms`<br>`usefulness_modes.mode_b_relative_divergence`<br>`decision_gate.gate_1_unassisted_cold_ttft` | `figure_data/fig9_ember_fidelity.csv` | **Synthetic MoE**: 24MB RAM<br>Online SVD vs Offline SVD | **Mode A (Exact Baseline)**: 739.40 ms<br>**Mode B (Online SVD)**: 3,757.60 ms (**+408.2% increase**)<br>**Mode C (Draft Preview)**: 0.16 ms (**4,621x faster**, 1.99% div)<br>**Mode C (Full Async)**: 739.40 ms<br>*(Gate 1 trace: 56.40 $\to$ 559.57 ms, +892.1%)* | **100% REPRODUCIBLE** |

---

## 2. Summary of Reproducibility Audit

- **Total Figures in Paper**: 9
- **Conceptual Systems Diagrams**: 1 (Figure 1)
- **Empirical Figures Independently Reproducible from `evidence/raw/`**: 8 (Figures 2–9, **100%**)
- **Hardcoded Numerical Constants**: 0 (all points dynamically parsed)
- **Machine Path Independence**: Verified (runs using relative paths from `figure_scripts/`)
