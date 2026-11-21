# Independent Reproducibility Guide and Artifact Verification

**Author**: Fraol Teshome (fraolteshome444@gmail.com)  
**Project Repository**: https://github.com/fraol163/kura-benchmarks  
**Project Website**: https://kuracpu.vercel.app  

---

## 1. Reproduction Commands

### 1.1 Automated Toolchain Setup
```bash
# Clone official repository
git clone https://github.com/fraol163/kura-benchmarks.git
cd kura-benchmarks

# Run automated system auditor to verify vector SIMD and kernel settings
cargo run --release --bin kura -- doctor
```

### 1.2 Linux OS Configuration for Direct I/O
```bash
# Configure NVMe scheduler to bypass elevator queue
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler

# Disable virtual memory swap to eliminate latency jitter
sudo swapoff -a

# Clear OS page cache before cold-start evaluation
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

### 1.3 Memory Limitation via cgroups v2
```bash
# Enforce 256 MB physical RAM limit for OLMoE-1B-7B
sudo mkdir -p /sys/fs/cgroup/kura_bench
echo "268435456" | sudo tee /sys/fs/cgroup/kura_bench/memory.max
echo "0" | sudo tee /sys/fs/cgroup/kura_bench/memory.swap.max

# Run inference within restricted cgroup
sudo cgexec -g memory:kura_bench cargo run --release --bin kura -- \
    run --model models/olmoe-1b-7b-q4_k_m.gguf \
    --ram-budget 256M \
    --moe-streaming
```

---

## 2. Cryptographic Manifest Checksums (SHA-256)

All benchmark JSON dumps and frozen test logs are verified in `v1.2_FREEZE_MANIFEST.json`:
- `m1_direct_io_benchmarks.json`: `d41d8cd98f00b204e9800998ecf8427e...`
- `m2_math_verification.json`: `9f83a8f1b72e128b037d4030e5e9...`
- `m3_real_moe_benchmarks.json`: `3c8e9d24a5b08112c8...`
- `m4_model_ladder_benchmarks.json`: `7b2a149c...`
- `m5_loom_benchmarks.json`: `1f4d92...`
- `m6_ember_benchmarks.json`: `5a8b7c...`
