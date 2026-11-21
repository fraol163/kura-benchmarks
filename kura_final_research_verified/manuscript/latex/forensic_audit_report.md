# FORENSIC PDF AUDIT REPORT

**Target**: `/home/renan/Downloads/projects/Kura/kura_final_research_verified/manuscript/latex/main.pdf`
**Total Pages Processed**: 15

## 1. Ghost Match Matrix

| Page | Ghost Category | Surrounding Match Text |
|---|---|---|
| Page 1 | Anonymous | `5                             Anonymous Author(s)                           60` |
| Page 1 | Anonymous | `Preprint, Anonymous` |
| Page 1 | Anonymous | `55                                    1                                     110  Kura: Storage-Native Decoupled Inferenc` |
| Page 1 | Anonymous | `50 Existing systems address this memory deficit through 105 Preprint, Anonymous 51 operating system virtual memory swapp` |
| Page 13 | Conference | `In International Conference on Machine Learning` |
| Page 13 | Conference | `ExpertsModels.InTheThirteenthInternationalConference` |
| Page 13 | Conference | `In International Conference on Machine Learning establishatransparent,reproduciblebenchmarkbaseline (ICML).31094–31116.` |
| Page 13 | Conference | `ExpertsModels.InTheThirteenthInternationalConference ∙ Operating System: Linux kernel 6.8+ (x86_64) on Learning Represen` |

## 2. Vector Graphic & Figure Text Extraction

Audited vector objects across all 15 pages.
- Page 6 (Figure region): contains 'pread64'

**Figure 1 Standalone Vector Asset Raw Text**:
`OFFLINE COMPILATION (Loom) ONLINE RUNTIME ENGINE (KAEF) Model Weights SENSE Hardware Probe COMMODITY STORAGE (GGUF / SafeTensors) R=Model Size/ RAM Contiguous Blocks (Clustered Experts) Economic Scarcity Auction Co-Activation Markov Graph MEC + Exponential Pricing Laplacian L=D−W Linux Buffered I/O io_uring / pread64 RamArena Slab Allocator 64-byte Aligned DMA Buffers Fiedler Spectral Ordering Clustered Extents (.sidecar) SIMD Kernels (AVX-512 VNNI / AVX2)`

✅ **FIGURE 1 CLEAN**: O_DIRECT is absent from standalone vector asset.

## 3. Abbreviation & Nomenclature Audit

**Defined Terms in Nomenclature Table (41)**:
AVX, AVX/AVX2, AVX2, CES, CPU, CRF, DMA, DRAM, Ember, FMA, FTL, GGUF, GPU, IOPS, KAEF, Kura, LFU, LLM, LRU, LRU/LFU, Loom, MEC, MLP, MoE, NVMe, OOM, OS, PCIe, POSIX, RSS, RamArena, SATA, SIMD, SSD, SVD, Sense, TTFT, VFS, VNNI, VRAM, lambda-pruning

**Acronyms Used in Document Missing from Nomenclature Table (28)**:
A2, ACM, AMD, BW, CQ, DDR4, ENGINE, GPT, HOBBIT, IBM, ICLR, ISCA, JSON, L3, MIN, NSDI, OFFLINE, ONLINE, PRO, Q4_K_M, Q8_0, REJ, RUNTIME, SHA, SQ, STORAGE, USENIX, YYYY

## 4. Layout & Whitespace Audit

- **Final Page (Page 15) Empty Whitespace**: 17.10%
  - ✅ **Status**: Passed (<=40% whitespace)
- **Top Margin (0-50pt) Header Audit**:
  - ✅ **Status**: Zero running header ghosts detected across all pages.

