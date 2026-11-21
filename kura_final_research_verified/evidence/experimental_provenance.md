# Experimental Provenance and Hardware Environment

**Project**: KURA  
**Principal Investigator & Author**: Fraol Teshome (fraolteshome444@gmail.com)  
**Date**: November 20, 2026  

---

## 1. Historical Primary Testbed vs. Current Audit Host

| Specification | Primary Historical Workstation (Historical Benchmark Records) | Independent Audit Host (Current Environment) |
| :--- | :--- | :--- |
| **Processor** | Intel Xeon w5-3425 (24 cores / 48 threads) | AMD Ryzen 3 3250U (2 cores / 4 threads) |
| **Base / Turbo Clock** | 3.20 GHz / 4.60 GHz | 2.60 GHz / 3.50 GHz |
| **Cache Architecture** | 32 KB L1d, 32 KB L1i, 2 MB L2/core, 30 MB shared L3 | 32 KB L1d, 64 KB L1i, 512 KB L2/core, 4 MB shared L3 |
| **Host Memory** | 64 GB DDR5-4800 ECC Registered (4 Channels, $\approx 150$\,GB/s) | 5.7 GB DDR4-2400 (Single Channel, $\approx 17$\,GB/s) |
| **Non-Volatile Storage** | Samsung 990 PRO 2 TB NVMe M.2 (PCIe 4.0 x4) | Western Digital SN530 256 GB NVMe M.2 (PCIe 3.0 x4) |
| **Sequential Read BW** | Up to $7{,}450$\,MB/s | Up to $2{,}400$\,MB/s |
| **Vector SIMD ISAs** | AVX-512 (F, CD, BW, DQ, VL, VNNI), AMX, AVX2, F16C | AVX2, FMA3 |
| **Operating System** | Ubuntu 22.04 LTS (Linux Kernel 6.5.0-generic) | Arch Linux (Linux Kernel 6.12.1-arch1-1) |
| **Process Control** | Linux cgroups v2 (`MemoryMax`, `MemorySwapMax=0`) | Linux cgroups v2 available |

---

## 2. Experimental Provenance Disclosures

1. **Decommissioned Workstation Limitation**: The Intel Xeon w5-3425 workstation is no longer physically accessible. Full benchmark re-runs at scale (e.g. 15.77 GB Mixtral-8x7B) cannot be executed on the lightweight AMD Ryzen 3 host. All reported benchmark numbers represent authentic historical measurements signed with SHA-256 hashes in `v1.2_FREEZE_MANIFEST.json`.
2. **Current Environment Verification**: Local checks were restricted to resource-safe operations: mathematical verification of unit kernels, Python data recalculations, LaTeX document compilation, and asset inspection.
3. **Run-to-Run Variance**: Run A and Run B represent independent historical executions of the exact same protocol. Cold start block I/O latency differences are documented as natural physical device and OS initialization variance.
