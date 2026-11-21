# KURA Website to Repository Cross-Check

**Audit Target**: Comparison between https://kuracpu.vercel.app and the local Kura codebase / release snapshots.

---

## 1. Subsystem Alignment

| Website Component | Codebase Crate / Path | Implementation Reality | Cross-Check Verdict |
| :--- | :--- | :--- | :---: |
| **SENSE Profiler** | `crates/kura-sense` / `src/hardware.rs` | CPUID vector checks, empirical block read probe, operational ratio $R$ | **VERIFIED** |
| **LOOM Coalescing** | `crates/kura-loom` | Co-activation matrix, spectral graph partitioning, sidecar serializer | **VERIFIED** |
| **EMBER 3-Tier Memory** | `crates/kura-memory` | Hot tier pinning, Warm tier caching, Cold tier streaming buffers | **VERIFIED** |
| **PREFETCH io_uring** | `crates/kura-io` | Linux `io_uring` submission/completion queues, buffered io_uring block alignment | **VERIFIED** |
| **SIMD Kernels** | `crates/kura-kernels` | AVX-512 VNNI, AVX2 FMA dot products, quantized dequantization | **VERIFIED** |
| **TUI Interface** | `crates/kura-tui` | Terminal user interface, real-time memory and token monitor | **VERIFIED** |
| **HTTP API Server** | `crates/kura-server` | OpenAI-compatible `/v1/chat/completions` endpoint | **VERIFIED** |
| **KAEF Predictive Lookahead** | `crates/kura-kaef` | Fully implemented, but flagged as REJECTED in Phase 24 audit due to arena allocation overhead | **VERIFIED (NEGATIVE RESULT)** |

---

## 2. GitHub Repository Pointer
- Website links to: `https://github.com/fraol163/kura-benchmarks`.
- Confirmed that Fraol Teshome is the owner and author (`fraol163`).
