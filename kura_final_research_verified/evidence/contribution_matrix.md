# KURA Research Contribution Matrix

This matrix distinguishes prior art, established techniques, Kura-specific combinations, and genuine systems contributions.

---

## 1. Subsystem Contribution Classification

| Subsystem | Underlying Problem | Prior Art / Established Techniques | Kura's Specific Mechanism | Novelty Classification | Empirical Demonstration |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Loom** | GGUF serial ordering forces scattered random NVMe reads across non-contiguous offsets ($<80$\,MB/s). | Standard linear serial tensor serialization (GGUF, SafeTensors). | Continuous spectral relaxation heuristic on empirical co-activation Markov graph, compiling contiguous 128\,KB NVMe sidecar blocks. | **Novel application of spectral placement to MoE weights on NVMe** | Collapses random reads by **67.1%** (OLMoE) and **69.3%** (Synthetic); reduces stall by 30.9%. |
| **KAEF** | Reactive LRU caching thrashes under bursty token-conditional MoE routing distributions. | Reactive caching (LRU, LFU, 2Q) and batch linear programming offloading (FlexGen). | Equilibrium auction clearing memory residency via convex scarcity pricing, router entropy quantile filtering, and counterfactual beam search with $\lambda$-pruning. | **Novel combination of micro-economic auction, router uncertainty, and $\lambda$-pruned search** | Reduces storage traffic by up to **58.7%** (Synthetic at 16MB) and **56.2%** (OLMoE at 256MB). |
| **Ember** | Cold expert loading introduces human-perceptible delays ($>700$\,ms TTFT) under tight memory budgets. | Speculative Decoding (Leviathan 2023), static SVD post-training compression (SVD-LLM 2024). | Three-tier progressive fidelity: precompiled low-rank SVD sketches yield provisional speculative draft preview in 0.16\,ms while exact weights load via io_uring. | **Systems boundary discovery & multi-tier execution paradigm** | 0.16\,ms preview ($4{,}621\times$ faster preview) with 1.99% divergence; proves online SVD failure (+892% TTFT regression). |
| **Direct I/O & RamArena** | Kernel page cache double-buffering introduces lock contention, CPU cache pollution, and OOM kills. | Linux `buffered io_uring`, POSIX `mmap`, `io_uring` ring buffers. | 64-byte aligned slab memory arenas (`RamArena`) mapped to expert parameter dimensions with kernel-bypass `io_uring` DMA. | **Engineering optimization and robust systems design** | Eliminates double-buffering; stable process RSS below 7.12 GB over 32,768-token sequences. |
