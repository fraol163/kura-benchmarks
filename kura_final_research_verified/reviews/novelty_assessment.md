# Kura: Comprehensive Research Novelty Assessment

**Author**: Fraol Teshome (Independent Researcher)  
**Date**: November 20, 2026  
**Scope**: Verification of academic novelty against peer-reviewed literature and prior art.

---

## 1. Executive Summary

A critical objective of this forensic audit is establishing what aspects of Kura represent genuine scientific and architectural novelty versus established systems engineering practices, ensuring that all claims of originality are fully substantiated.

The assessment confirms that Kura introduces **two primary scientific novelties** and **one major methodological contribution**:
1. **Physical Layout Compilation for Sparse MoE Weights (Loom)**: Mapping expert co-activation Markov graphs to contiguous NVMe block addresses via spectral graph clustering (Fiedler vector relaxation) is genuinely novel. Prior systems treat model storage layout as fixed or serial.
2. **Convex Scarcity Auction Formulation for DRAM Residency (KAEF)**: Formulating memory residency as an economic market clearing problem with exponential barrier pricing and Marginal Execution Contribution (MEC) ranking represents a novel departure from classical heuristic eviction algorithms (LRU, LFU, ARC).
3. **Rigorous Characterization of Memory Inversion Regimes**: The empirical documentation of non-monotonic performance boundaries—specifically demonstrating that predictive economics can cause net performance regressions at intermediate memory budgets due to synchronous arena mutation—is a distinctive contribution to systems research.

---

## 2. Comparative Matrix Against Prior Art

| System / Paper | Target Subsystem | Memory Mechanism | Storage Awareness | Key Distinctions from Kura |
| :--- | :--- | :--- | :--- | :--- |
| **vLLM / PagedAttention**<br>*(Kwon et al., SOSP 2023)* | KV-Cache Paging | GPU Virtual Memory Pages | None (In-Memory GPU Only) | Solves dynamic KV-cache fragmentation in GPU VRAM. Kura solves sparse model weight paging from NVMe to CPU host DRAM. |
| **DeepSpeed-MoE / ZeRO**<br>*(Rajbhandari et al., 2022)* | Distributed MoE Serving | All-to-all communication; parameter sharding | None (Assumes distributed DRAM/HBM) | Targets cluster-scale multi-GPU training/serving. Kura targets single-node out-of-RAM workstation execution. |
| **MoE-Infinity**<br>*(Gao et al., 2024)* | Out-of-Core MoE Offloading | Dynamic prefetching into GPU memory | Standard POSIX / Cached OS file access | Uses greedy activation tracking with standard serial model files. Lacks physical on-disk layout compilation (Loom) and economic market auctions (KAEF). |
| **FlexGen**<br>*(Sheng et al., ICML 2023)* | High-Throughput Batch Offloading | Linear programming tensor placement | Coarse block offloading | Optimized for batched throughput over long sequences; incurs multi-second latency per token. Kura targets interactive low-latency single-token generation. |
| **FMoE / FastMoE**<br>*(He et al., 2021)* | Sparse Gating Kernels | GPU Stream parallelization | None (In-Memory) | Focuses on CUDA stream efficiency for gating; does not address storage-to-memory paging or physical NVMe bottlenecks. |
| **SVD-LLM**<br>*(Wang et al., 2024)* | Weight Compression | Static low-rank truncation | Static model file compression | Uses SVD strictly as a one-time lossy compression technique. Kura's Ember uses SVD dynamically as a progressive tiered preview mode (Mode C). |

---

## 3. Detailed Novelty Breakdown by Subsystem

### 3.1. Loom: Offline Physical Layout Compilation
- **Prior State of the Art**: Existing model container formats (GGUF, SafeTensors, PyTorch checkpoints) arrange tensor parameters in serial topological order ($\text{layer}_0.\text{expert}_0, \text{layer}_0.\text{expert}_1, \dots$). When an inference engine faults on non-adjacent experts (e.g., Expert 2 and Expert 47), the operating system issues disjoint random 4 KB I/O requests. On NVMe SSDs, this causes severe read amplification, I/O queue bottlenecks, and PCIe bus stalling.
- **Kura's Novelty**: Loom formulates physical tensor layout on block storage as a 1D Minimum Linear Arrangement (1D-MLA) problem over an empirical co-activation graph $G = (V, E, W)$. By computing the continuous spectral relaxation via the graph Laplacian $L = D - W$ and sorting expert offsets along the Fiedler vector $v_2$, Loom clusters frequently co-activated expert tensors into contiguous physical block extents. 
- **Empirical Validation**: Loom collapses random reads by $67.13\%$ on OLMoE-1B-7B and $69.35\%$ on Synthetic MoE, replacing them with high-bandwidth multi-channel sequential streaming bursts.

### 3.2. KAEF: Market-Based Predictive Memory Economics
- **Prior State of the Art**: Virtual memory and caching systems rely on reactive heuristics (LRU, 2Q, ARC) or static heuristic prefetchers. In MoE models, routing dynamics are non-stationary and dependent on semantic prompt state, leading reactive policies to thrash.
- **Kura's Novelty**: KAEF models host DRAM residency as a micro-economic clearing market:
  1. *Convex Scarcity Pricing*: Memory price scales exponentially as utilization approaches capacity ($P_0 \exp(\beta / (1-U))$), guaranteeing capacity preservation without OS OOM faults.
  2. *Marginal Execution Contribution (MEC)*: Each expert's bid incorporates lookahead activation probability, routing weight norm, and NVMe latency penalty avoided.
  3. *Router Entropy Tracking & Quantile Forecasting*: Prefetch horizons dynamically adapt based on Shannon entropy of preceding gating decisions.
  4. *Counterfactual Execution Search (CES) with $\lambda$-Pruning*: Evaluates eviction/admission trees in $<0.54$ ms, pruning unviable allocation states.

### 3.3. Ember: Progressive Tiered-Fidelity Preview
- **Prior State of the Art**: Model compression techniques either execute fully in compressed precision (inducing permanent quality degradation) or require full decompression before execution.
- **Kura's Novelty**: Ember establishes a progressive execution paradigm for out-of-RAM MoE models: precompiled low-rank SVD sketches reside persistently in a tiny 25 MB DRAM tier, synthesizing a speculative draft preview in $0.16$ ms ($4{,}621\times$ lower latency) with $1.99\%$ divergence, while exact full-rank weights load asynchronously via Direct I/O in $739.40$ ms.
- **Negative Result Novelty**: The manuscript also definitively demonstrates that online SVD decomposition (Mode B) introduces a $3{,}018.2$ ms CPU bottleneck ($+892.1\%$ cold TTFT regression), establishing that low-rank sketches *must* be precompiled offline.

---

## 4. Unsupported or Overstated Claims Removed

To preserve scientific rigor, all exaggerated or historically inaccurate claims were purged during the audit:
- **Removed**: "World's first storage-native runtime" $\to$ replaced with specific technical comparisons against prior offloading runtimes.
- **Removed**: Attributions of benchmark variance to "PCIe ASPM transitions" or "SLC cache exhaustion" $\to$ replaced with transparent statements acknowledging that firmware telemetry was not captured.
- **Removed**: Claims of universal bit-level invariance $\to$ restricted explicitly to the 262 deterministic test assertions covering tested SIMD kernels.
- **Corrected**: Claims that Fiedler vector sorting is "globally optimal" $\to$ clarified as a continuous spectral relaxation heuristic for an NP-hard graph arrangement problem.
