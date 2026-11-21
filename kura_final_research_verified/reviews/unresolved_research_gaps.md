# Kura: Unresolved Research Gaps and Systems Roadmap

**Author**: Fraol Teshome (Independent Researcher)  
**Date**: November 20, 2026  
**Scope**: Identification of open research challenges, engineering bottlenecks, and future research directions for out-of-RAM MoE systems.

---

## 1. Executive Summary

While Kura establishes foundational improvements in physical layout compilation and predictive memory auctions, our forensic audit has identified several open engineering bottlenecks and theoretical boundaries. Documenting these unresolved challenges provides a clear roadmap for subsequent iterations of the Kura architecture and offers high-value research directions for the broader systems community.

---

## 2. Identified Systems Bottlenecks & Gaps

### 2.1. The Synchronous Memory Arena Re-Allocation Bottleneck
- **Observed Behavior**: Micro-profiling of KAEF planning epochs reveals that over $99.8\%$ of total planning time is consumed by synchronous arena memory reallocation (e.g., 4,772.54 ms out of 4,779.15 ms in `overhead_breakdown.json`), while the mathematical search algorithms require only 6.60 ms ($<0.15\%$).
- **Root Cause**: When KAEF decides to admit new expert blocks and evict resident tensors, the underlying runtime executes synchronous virtual memory operations (`munmap`, `mmap`, or buffer zeroing) and cache flushes. In intermediate memory budgets (24 MB–128 MB), this synchronous mutation latency exceeds the time saved by avoiding NVMe reads.
- **Proposed Solution (Kura v2 Roadmap)**:
  - Implement a **pre-pinned circular ring buffer** where expert slots are fixed at startup and never unmapped.
  - Replace synchronous buffer reconfiguration with lockless atomic pointer swaps using Linux `io_uring` fixed buffer registrations (`IORING_REGISTER_BUFFERS`).
  - Overlap arena slot clearing with CPU SIMD tensor execution on adjacent threads.

### 2.2. Scaling to Multi-Sequence Batched Serving ($B > 1$)
- **Observed Behavior**: All current Kura benchmarks evaluate single-user interactive generation ($\text{batch\_size} = 1$). 
- **Open Challenge**: When batch size scales to $B \ge 32$ or $B \ge 64$, tokens within the batch route to diverse experts across the model layer. This causes:
  1. *Co-activation Graph Saturation*: The expert co-activation graph becomes denser, reducing the modularity of Loom's spectral clusters.
  2. *NVMe Bandwidth Saturation*: Direct I/O queue depths fill rapidly, potentially converting sequential multi-expert bursts into concurrent bus contention.
- **Proposed Solution**:
  - Investigate batch-aware layout compilation that clusters experts based on inter-sequence topic distributions.
  - Implement dynamic batch scheduling that groups requests with high routing affinity into the same forward execution pass.

### 2.3. Dynamic Online Layout Adaptation
- **Observed Behavior**: Loom currently functions as an offline layout compiler. It requires a representative calibration dataset (such as C4 or Wikitext) to construct the Markov co-activation graph before model deployment.
- **Open Challenge**: If runtime user queries diverge significantly from the calibration domain (e.g., transitioning from conversational English to dense C++ source code), routing distributions may shift, reducing the locality benefits of the precompiled physical layout.
- **Proposed Solution**:
  - Develop an online, asynchronous re-compaction daemon that monitors real-time expert routing frequencies and writes dynamic NVMe remap sidecars in the background during idle periods.

### 2.4. Cross-Platform Acceleration and Unified Memory Architectures
- **Observed Behavior**: Kura currently targets Linux x86_64 host CPUs with AVX-512/AVX2 and Linux `io_uring` Direct I/O.
- **Open Challenge**: Emerging edge platforms feature unified memory architectures (e.g., Apple M-series Unified Memory, Compute Express Link / CXL 2.0/3.0, and NVIDIA Grace Hopper).
- **Proposed Solution**:
  - Extend Kura's Direct I/O abstraction layer to support CXL Direct Memory Access and Apple Silicon `Metal` unified memory streaming.
  - Implement zero-copy GPU tensor core dispatch directly from NVMe over PCIe peer-to-peer (P2P / GPUDirect Storage).

---

## 3. Prioritized Research and Implementation Agenda

| Phase | Target Mechanism | Objective | Estimated Complexity |
| :---: | :--- | :--- | :---: |
| **Phase A** | Lockless Circular Arena Buffers | Eliminate $>99.8\%$ synchronous arena allocation overhead; convert intermediate regressions into net speedups. | Medium (Rust Systems) |
| **Phase B** | Asynchronous Loom Online Re-indexer | Dynamically update physical NVMe extents for domain-shifting workloads. | High (I/O Architecture) |
| **Phase C** | Batched Affinity Scheduler | Scale KAEF market clearing to multi-user concurrent serving ($B = 16$--$64$). | High (Distributed Systems) |
| **Phase D** | GPUDirect Storage (GDS) Backend | Enable zero-copy DMA streaming directly from NVMe SSDs into GPU VRAM for edge workstations. | High (CUDA / Systems) |
