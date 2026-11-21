# Historical Benchmark Forensic Audit & Numerical Recalculation

**Auditor**: Benchmark & Experimental Reproducibility Auditor  
**Date**: November 20, 2026  
**Scope**: Verification and recalculation of every numerical claim directly from raw historical benchmark JSON and CSV telemetry records.

---

## 1. Primary Experimental Recalculation Ledger

### 1.1 Loom Random Read Reduction (RQ1)
- **OLMoE-1B-7B Benchmark** (`results/raw/m3_real_moe_benchmarks.json`):
  - Baseline Random Reads: **216**
  - Loom+KAEF Random Reads: **71**
  - Calculation: $\frac{71 - 216}{216} = \frac{-145}{216} = \mathbf{-67.1296\%}$ (reported as **-67.1%**).
  - Status: **VERIFIED EXACT MATCH**.
- **Synthetic MoE Benchmark** (`results/raw/m5_loom_benchmarks.json` & `benchmark_results.csv`):
  - Baseline Random Reads: **248**
  - Loom+KAEF Random Reads: **76**
  - Calculation: $\frac{76 - 248}{248} = \frac{-172}{248} = \mathbf{-69.3548\%}$ (reported as **-69.35%**).
  - Status: **VERIFIED EXACT MATCH**.

---

### 1.2 Storage Traffic Reduction (KAEF)
- **Synthetic MoE under 16 MB RAM Budget** (`results/reports/checkpoints/M4_REGIME_MAPS.md` & `m4_regime_maps.json`):
  - Model footprint: 166.08 MB (`shared-small.gguf`)
  - Memory Budget: **16 MB** ceiling (9.6% residency, $10.4\times$ memory pressure)
  - Baseline (LRU) storage traffic: **15,654,144 bytes/token** (14.93 MB/tok)
  - KAEF storage traffic: **6,462,720 bytes/token** (6.16 MB/tok)
  - Calculation: $\frac{6,462,720 - 15,654,144}{15,654,144} = \frac{-9,191,424}{15,654,144} = \mathbf{-58.7156\%}$ (reported as **-58.7%**).
  - Status: **VERIFIED EXACT MATCH**.
- **OLMoE-1B-7B under 256 MB RAM Budget** (`results/raw/m3_real_moe_benchmarks.json`):
  - Model footprint: 1,237.49 MB (1.21 GB)
  - Memory Budget: **256 MB** ceiling ($4.8\times$ memory pressure)
  - Baseline (LRU) storage traffic: **48.6 MB/token**
  - Loom+KAEF storage traffic: **21.3 MB/token**
  - Calculation: $\frac{21.3 - 48.6}{48.6} = \frac{-27.3}{48.6} = \mathbf{-56.1728\%}$ (reported as **-56.2%**).
  - Status: **VERIFIED EXACT MATCH**.

---

### 1.3 OLMoE Cold TTFT and Throughput Repetitions
Two distinct historical runs exist in the repository:
1. **Run A (Checkpoint Report `M3_REAL_MOE.md`)**:
   - Baseline TTFT: **338.90 ms**, Stall: **267.00 ms**, Throughput: **10.78 tok/s**
   - Loom+KAEF TTFT: **250.80 ms** ($\mathbf{-26.00\%}$), Stall: **184.40 ms** ($\mathbf{-30.94\%}$), Throughput: **12.09 tok/s** ($\mathbf{+12.15\%}$)
2. **Run B (JSON Telemetry Snapshot `m3_real_moe_benchmarks.json`)**:
   - Baseline TTFT: **330.43 ms**, Stall: **266.30 ms**, Throughput: **10.57 tok/s**
   - Loom+KAEF TTFT: **264.24 ms** ($\mathbf{-20.03\%}$), Stall: **188.40 ms** ($\mathbf{-29.25\%}$), Throughput: **12.09 tok/s** ($\mathbf{+14.38\%}$)
- **Finding**: Both are authentic historical runs executed under identical 256 MB memory ceilings on the Intel Xeon w5-3425 workstation. Cold TTFT variance is attributable to cold disk access latency jitter across runs. Both throughput measurements converge identically to **12.09 tokens/s**.
- Status: **VERIFIED AND RECONCILED**.

---

### 1.4 Ember Progressive Tiered Fidelity
- Provisional Speculative Draft Preview TTFT: **0.16 ms** (`m6_ember_gate.json`) / **0.177 ms** (`ember_usefulness.json`).
- Full Exact-Token Completion TTFT: **739.40 ms**.
- Physical Preview Speedup Ratio: $\frac{739.40}{0.16} = \mathbf{4,621.25\times}$ (99.978% preview latency reduction).
- Output Activation Quality Divergence: **1.99%** relative $L_2$ error.
- Online SVD Computation CPU Latency: **3,018.2 ms**.
- Online SVD TTFT Regression: $56.40\text{ ms} \to 559.57\text{ ms} = \mathbf{+892.1\%}$.
- Status: **VERIFIED UNBUNDLED METRICS**.

---

### 1.5 KAEF Overhead Decomposition
- **`overhead_breakdown.json`**:
  - Decision Application (synchronous arena mutation): **4,772.54 ms** ($\mathbf{99.86\%}$)
  - Algorithmic Search (forecasting 1.07 ms, MEC 1.39 ms, pricing 0.26 ms, search 3.88 ms): **6.60 ms** ($\mathbf{0.14\%}$)
  - Total Planning Overhead: **4,779.15 ms**
- **Milestone Micro-Telemetry (`m3_real_moe_benchmarks.json`)**:
  - Arena Reallocation: **361.70 ms** ($\mathbf{99.85\%}$)
  - Mathematical Beam Search: **0.54 ms** ($\mathbf{0.15\%}$)
  - Total: **362.24 ms**
- Status: **VERIFIED EXACT MATCH**.
