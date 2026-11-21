# KURA Website Extracted Technical Knowledge

**Source**: Extracted from https://kuracpu.vercel.app production bundle  
**Extraction Date**: November 20, 2026  

---

## 1. Core Architectural Concepts on Website

### 1.1 SENSE: Autonomous Hardware Sensing & Regime Calibration
- **Role**: Hardware introspection and calibration engine executing prior to runtime initialization.
- **Probes**: CPUID SIMD vector extensions (AVX-512, AVX2, NEON), NUMA topology, and empirical sequential NVMe read bandwidth.
- **Classification Ratio ($R$)**:
  $$R = \frac{\text{Empirical Sequential Storage Bandwidth (MB/s)}}{\text{Single-Core Memory Bus Bandwidth (MB/s)}}$$
- **Operational Regimes**: Automatically switches between Direct NVMe streaming, RAM caching, and hybrid split execution based on $R$.

### 1.2 LOOM: Physical Tensor Coalescing Engine
- **Problem Formulation**: Standard GGUF file format groups tensors by type across scattered file offsets, inducing hundreds of random NVMe seeks per token and collapsing read bandwidth from $>3{,}000$\,MB/s to $<80$\,MB/s.
- **Mechanism**: Loom reorganizes weights into continuous, sequential physical spans on NVMe storage, converting fine-grained random reads into coalesced sequential bursts.

### 1.3 EMBER: Three-Tier Physical Memory Architecture
Replaces dynamic operating system heap allocations with three strictly budgeted physical memory pools:
1. **Hot Tier (Resident in RAM)**: Critical weights touched continuously on every token that cannot be streamed (Token embeddings, output RMSNorm, LM head projection matrix, active 8-bit KV cache).
2. **Warm Tier (RAM Residue)**: Early Transformer prefix layers that fit into remaining physical memory budget.
3. **Cold Tier (NVMe Streamed)**: Middle and late Transformer layers stored on NVMe storage and streamed into reusable staging buffers.

### 1.4 PREFETCH: Double-Buffered Overlap Concept
Eliminates storage read wait times by alternating two ping-pong staging buffers:
- While CPU computes Layer $L$ using Buffer 0, an asynchronous `io_uring` direct I/O request fills Buffer 1 with Layer $L+1$ weights.
- When Layer $L$ completes, pointers swap with zero memory copying.

### 1.5 SIMD Vector Intrinsics & Bitwise Parity Gate
- Hand-crafted SIMD matrix kernels in AVX-512 FMA, AVX2, and ARM NEON.
- On-the-fly dequantization of Q4_K_M and Q8_0 blocks directly into CPU vector registers.
- Bitwise Parity Gate: Enforces identical token decoding sequences across platforms with cosine similarity $\ge 0.99999$.

---

## 2. Phase 24 Physical Hardware Audit Results (Published on Website)

The website prominently displays the results of the Phase 24 Physical Hardware Audit:
- **17 PROVEN (65.4%)**: Storage-Native Execution, Decoupled Memory, Loom Coalescing, Ember Residency, Regime-Aware Prefetch, Flash-Attention, AVX-512/F16C SIMD, INT8 KV Compression, Dense Boundaries, MoE Locality, Linux cgroup Zero-OOM.
- **2 SUPPORTED (7.7%)**: Functional Memory Budgets, StreamingLLM Ring Buffering.
- **2 PARTIALLY VALIDATED (7.7%)**: Cache-Affinity Pinning, SwiGLU Zero-Skipping.
- **2 EXPERIMENTAL (7.7%)**: Two-Model Speculative Decoding, Low-Rank Recomputation Sketches.
- **3 REJECTED (11.5%)**: **KAEF Predictive Lookahead**, **Single-Stream Atlas Coordination**, **Confidence Early-Exit**.

> [!IMPORTANT]
> The website explicitly notes that **KAEF Predictive Lookahead** was rejected for general workloads because dynamic lookahead scheduling added synchronization latency without saving NVMe bytes compared to static Loom coalescing and double-buffered prefetching.

---

## 3. Official Website Ablation Ladder (OLMoE 1B-7B)

The website provides a 6-step physical cumulative speedup ladder:
1. **Baseline Unaligned Paging**: 4.9 tok/s (0.0% gain)
2. **+ SENSE Autonomous Regimes**: 6.7 tok/s (+36.7% gain)
3. **+ LOOM Layout Coalescing**: 9.1 tok/s (+35.8% step, +85.7% cumulative)
4. **+ PREFETCH Overlap Pipeline**: 12.2 tok/s (+34.1% step, +149.0% cumulative)
5. **+ EMBER Hot/Warm Tiering**: 13.5 tok/s (+10.7% step, +175.5% cumulative)
6. **+ Vector SIMD Intrinsics**: 12.09 tok/s (Trace-replayed I/O characterization on 8-layer proxy) (+12.6% step, +210.2% cumulative)
