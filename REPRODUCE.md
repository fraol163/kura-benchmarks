# Reproducibility Guide: Kura Systems Evaluation

This guide provides instructions for independently reproducing the experimental results presented in **"Kura: Storage-Native Decoupled Inference for Memory-Constrained Mixture-of-Experts"**.

---

## 1. Hardware & System Requirements

The experimental claims in this paper are evaluated on commodity client hardware under strict memory boundaries:

- **Processor**: AMD Ryzen 3 3250U (2 physical cores, 4 threads @ 2.60 GHz base / 3.50 GHz boost, AVX2 support).
- **RAM**: 5.7 GB physical DDR4-2400 (single-channel).
- **Storage**: 128 GB SATA M.2 SSD (`/dev/sda` Samsung PM871b MZNTY128HDHP-000L7).
  - Measured sequential read throughput: ~350 MB/s.
  - Measured 4K random QD1 read: 8,158.7 IOPS (31.87 MB/s) @ 122.57 µs latency.
- **Operating System**: Linux x86_64 (Kernel 6.8+ recommended) with `cgroups v2` unified hierarchy mounted at `/sys/fs/cgroup`.
- **Software Dependencies**:
  - Rust 1.80+ (`rustc` and `cargo`)
  - Python 3.10+ with `numpy`, `pandas`, and `matplotlib`
  - Linux `systemd` or root privileges to configure `cgroups v2`

---

## 2. Environment Setup

### 2.1 Rust Toolchain
Ensure the Rust toolchain is installed and on your `$PATH`:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustc --version # verified with rustc 1.80+ / 1.99+
```

### 2.2 Python Environment for Figures
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install numpy pandas matplotlib
```

### 2.3 Cgroup v2 Isolation (Strict 3.5 GB Ceiling, Swap=0)
To observe memory pressure and reproduce out-of-memory avoidance without swapping:

**Method 1: User-Space Scope (Recommended, No Root Required)**
```bash
systemd-run --user --scope \
  -p MemoryMax=3500M \
  -p MemorySwapMax=0 \
  bash
```

**Method 2: Root Control Group**
```bash
sudo mkdir -p /sys/fs/cgroup/kura_bench
echo "3670016000" | sudo tee /sys/fs/cgroup/kura_bench/memory.max
echo "0" | sudo tee /sys/fs/cgroup/kura_bench/memory.swap.max
sudo cgexec -g memory:kura_bench bash
```

---

## 3. Model Weight Preparation

Place required GGUF model files in the `models/` directory:

1. **In-Memory Baseline (Qwen2.5-1.5B)**:
   - File: `models/qwen2.5-1.5b-instruct-q4_k_m.gguf` (0.99 GB)
   - Behavior: Fits fully within the 3.5 GB cgroup limit; executes at memory-resident speed (~11.6 tok/s).

2. **Out-of-Memory Dense Streaming (Qwen2.5-7B)**:
   - File: `models/qwen2.5-7b-instruct-q4_k_m.gguf` (4.68 GB)
   - Behavior: Exceeds the 3.5 GB cgroup limit; standard `mmap` triggers major page fault thrashing and crash/OOM; Kura streams layers from SATA at hardware-bound ~0.019 tok/s.

3. **MoE Proxy Artifact (OLMoE Sub-Network)**:
   - File: `storage/shared-olmoe.gguf.kura` (1.21 GB)
   - Configuration: 8-layer, 32-expert sub-network in Q8_0 format ($4,595,712$ bytes per expert).
   - Behavior: Used for measuring I/O stall reduction (29.26% on real trace) and Loom physical layout coalescing (67% random seek reduction).

---

## 4. Running Benchmarks

### 4.1 Dense Model SATA Streaming Reality Suite
Execute the automated test runner (captures wall-clock time, TTFT, tok/s, and page faults across Baseline mmap, Kura Buffered, and Kura + Loom):
```bash
chmod +x scripts/run_phase2_sata_reality.sh
./scripts/run_phase2_sata_reality.sh
```
Results are saved to: `benchmarks/results/phase2_sata_reality.json`.

### 4.2 MoE Routing Trace & Loom Layout Evaluation
Execute the MoE replay driver against the OLMoE sub-network:
```bash
cargo run --release --bin kura_bench -- \
  --config benchmarks/configs/olmoe_real_trace.json
```

### 4.3 Mathematical and Kernel Unit Tests
Verify SIMD GEMV kernels, dequantization routines, and RamArena alignment guarantees:
```bash
cargo test --release --all
```

---

## 5. Regenerating Figures

All figures in the manuscript can be regenerated directly from the verified telemetry JSON files:
```bash
python3 generate_all_figures.py
```
Generated assets:
- `figures/fig1_kura_architecture.pdf`
- `figures/fig2_random_read_reduction.png`
- `figures/fig3_storage_traffic.png`
- `figures/fig4_ttft_comparison.png`
- `figures/fig5_kaef_ablation.png`
- `figures/fig6_memory_pressure.png`
- `figures/fig7_throughput_vs_bandwidth.png`
- `figures/fig8_layer_latency_breakdown.png`
- `figures/fig9_ram_sweep.png`

---

## 6. Telemetry Data Integrity

Key verified numbers in the experimental record:
- **Loom Random Read Reduction**: 67% reduction in random reads via spectral graph serialization.
- **I/O Stall Reduction**: 29.26% reduction on the OLMoE trace; 74.25% reduction on synthetic stress workloads.
- **KAEF Controller Overhead**: Average 12.35 ms per decision (4,741.47 ms sequence-wide overhead).
- **Ember Online SVD CPU Bottleneck**: 3,018.20 ms CPU stall (+408.2% latency increase), necessitating offline precompilation.
- **Commodity SATA Dense 70B Throughput**: Measured 0.019 tok/s hardware streaming limit.
