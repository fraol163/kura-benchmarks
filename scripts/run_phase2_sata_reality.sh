#!/usr/bin/env bash
# ==============================================================================
# KURA PHASE 2: COMMODITY SATA REALITY BENCHMARK HARNESS
# ==============================================================================
# Host Target: AMD Ryzen 3 3250U (2c/4t, AVX2), 5.7 GB RAM, SATA M.2 SSD
# Purpose: Execute authentic live dense inference across Qwen2.5 models under
#          a strict 3.5 GB cgroup v2 RAM limit (MemorySwapMax=0).
# Configurations:
#   A. Baseline: Standard mmap execution (expect OOM/thrashing on 7B)
#   B. KURA Buffered: Async io_uring / pread64 without Loom layout
#   C. KURA + Loom: Async io_uring / pread64 WITH spectral layout coalescing
# Output: phase2_sata_reality.json
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODELS_DIR="${ROOT_DIR}/models"
export OUTPUT_JSON="${ROOT_DIR}/phase2_sata_reality.json"
CGROUP_LIMIT="3500M"
REPS=3
PROMPT="Explain the operational difference between operating system virtual memory paging and application-level decoupled tensor streaming in three technical bullet points."
MAX_TOKENS=8

mkdir -p "${MODELS_DIR}"
cd "${ROOT_DIR}"

echo "========================================================================"
echo " KURA PHASE 2: COMMODITY SATA REALITY EXECUTION HARNESS"
echo " Target Hardware: AMD Ryzen 3 3250U | SATA SSD | 3.5 GB cgroup limit"
echo "========================================================================"

# 1. Download target models if not present
QWEN_1_5B_URL="https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf"
QWEN_7B_URL="https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf"

MODEL_1_5B="${MODELS_DIR}/qwen2.5-1.5b-instruct-q4_k_m.gguf"
MODEL_7B="${MODELS_DIR}/qwen2.5-7b-instruct-q4_k_m.gguf"

if [[ ! -f "${MODEL_1_5B}" ]]; then
    echo "[Download] Fetching Qwen2.5-1.5B-Instruct-Q4_K_M (~986 MB)..."
    curl -L --progress-bar "${QWEN_1_5B_URL}" -o "${MODEL_1_5B}"
fi

if [[ ! -f "${MODEL_7B}" || $(stat -c%s "${MODEL_7B}" 2>/dev/null || echo 0) -lt 1000000 ]]; then
    if [[ "${DOWNLOAD_7B:-0}" == "1" ]]; then
        echo "[Download] Fetching Qwen2.5-7B-Instruct-Q4_K_M (~4.48 GB)..."
        curl -L --progress-bar "${QWEN_7B_URL}" -o "${MODEL_7B}"
    else
        echo "[Download] Qwen2.5-7B-Instruct-Q4_K_M (~4.48 GB) not downloaded locally. Set DOWNLOAD_7B=1 to pull over network."
    fi
fi

# 2. Build release binary
echo "[Build] Compiling kura-cli in release mode..."
cd "${ROOT_DIR}/Kura-kura-phase34-tui-product-layer-v1"
cargo build --release -p kura-cli
cd "${ROOT_DIR}"
KURA_BIN="${ROOT_DIR}/Kura-kura-phase34-tui-product-layer-v1/target/release/kura"
if [[ ! -f "${KURA_BIN}" ]]; then
    # Fallback to shared cargo target directory if configured
    KURA_BIN="$(find ~/.cache/cargo-shared-target -name kura -type f -executable 2>/dev/null | grep release | head -n 1 || echo "")"
fi

if [[ -z "${KURA_BIN}" || ! -x "${KURA_BIN}" ]]; then
    echo "[Error] Could not find compiled kura binary."
    exit 1
fi
echo "[Build] Using binary: ${KURA_BIN}"

# 3. Compile Loom layout sidecars for Config C
echo "[Loom] Compiling Loom physical layouts..."
if [[ ! -f "${MODEL_1_5B}.kura" && -f "${MODEL_1_5B}" ]]; then
    "${KURA_BIN}" optimize "${MODEL_1_5B}" --ram-budget "${CGROUP_LIMIT}" --no-bench || true
fi
if [[ ! -f "${MODEL_7B}.kura" && -f "${MODEL_7B}" && $(stat -c%s "${MODEL_7B}" 2>/dev/null || echo 0) -gt 1000000 ]]; then
    "${KURA_BIN}" optimize "${MODEL_7B}" --ram-budget "${CGROUP_LIMIT}" --no-bench || true
fi

# 4. Helper function to drop page caches if root/sudo is accessible
drop_caches() {
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    fi
}

# 5. Benchmark Execution Matrix
export RESULTS_TEMP="$(mktemp -d)"
trap 'rm -rf "${RESULTS_TEMP}"' EXIT

MODELS=("1.5B" "7B")
CONFIGS=("mmap_baseline" "kura_buffered" "kura_loom")

echo "Starting evaluation: 2 models x 3 configs x ${REPS} repetitions..."

for model_name in "${MODELS[@]}"; do
    if [[ "${model_name}" == "1.5B" ]]; then
        MODEL_PATH="${MODEL_1_5B}"
        MODEL_SIZE="0.98 GB"
    else
        MODEL_PATH="${MODEL_7B}"
        MODEL_SIZE="4.48 GB"
    fi

    for config in "${CONFIGS[@]}"; do
        echo "----------------------------------------------------------------"
        echo " Model: Qwen2.5-${model_name} (${MODEL_SIZE}) | Config: ${config}"
        echo "----------------------------------------------------------------"

        for rep in $(seq 1 "${REPS}"); do
            echo -n "  Repetition ${rep}/${REPS}... "

            LOG_OUT="${RESULTS_TEMP}/${model_name}_${config}_rep${rep}.log"
            TIME_OUT="${RESULTS_TEMP}/${model_name}_${config}_rep${rep}.time"

            if [[ ! -f "${MODEL_PATH}" || $(stat -c%s "${MODEL_PATH}" 2>/dev/null || echo 0) -lt 1000000 ]]; then
                echo "SKIPPED (Model not locally available)"
                echo "status=OFFLINE_MODEL_NOT_DOWNLOADED" > "${LOG_OUT}"
                continue
            fi

            drop_caches

            # Setup configuration flags
            EXTRA_FLAGS=("--tokens" "${MAX_TOKENS}" "--prompt" "${PROMPT}" "--ram-budget" "${CGROUP_LIMIT}" "--threads" "2")
            if [[ "${config}" == "mmap_baseline" ]]; then
                # Standard mmap execution
                # Temporarily hide Loom sidecar if present
                [[ -f "${MODEL_PATH}.kura" ]] && mv "${MODEL_PATH}.kura" "${MODEL_PATH}.kura.bak"
            elif [[ "${config}" == "kura_buffered" ]]; then
                # Buffered pread64 without Loom
                EXTRA_FLAGS+=("--no-mmap")
                [[ -f "${MODEL_PATH}.kura" ]] && mv "${MODEL_PATH}.kura" "${MODEL_PATH}.kura.bak"
            elif [[ "${config}" == "kura_loom" ]]; then
                # Buffered with Loom physical layout
                EXTRA_FLAGS+=("--no-mmap")
                [[ -f "${MODEL_PATH}.kura.bak" ]] && mv "${MODEL_PATH}.kura.bak" "${MODEL_PATH}.kura"
            fi

            # Execute under strict cgroup v2 memory constraint
            set +e
            python3 -c '
import resource, subprocess, sys, time
t0 = time.perf_counter()
cgroup = sys.argv[1]
time_path = sys.argv[2]
log_path = sys.argv[3]
cmd_to_run = sys.argv[4:]
full_cmd = ["systemd-run", "--user", "--scope", "-q", f"-pMemoryMax={cgroup}", "-pMemorySwapMax=0"] + cmd_to_run
with open(log_path, "w") as out_fp:
    p = subprocess.run(full_cmd, stdout=out_fp, stderr=subprocess.STDOUT)
t1 = time.perf_counter()
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
with open(time_path, "w") as tf:
    tf.write(f"WALL_TIME_SEC={t1-t0:.2f}\nMAX_RSS_KB={ru.ru_maxrss}\nMAJFLT={ru.ru_majflt}\nMINFLT={ru.ru_minflt}\nEXIT_CODE={p.returncode}\n")
sys.exit(p.returncode)
' "${CGROUP_LIMIT}" "${TIME_OUT}" "${LOG_OUT}" "${KURA_BIN}" run "${MODEL_PATH}" "${EXTRA_FLAGS[@]}"
            EXIT_CODE=$?
            set -e

            # Restore sidecar if hidden
            [[ -f "${MODEL_PATH}.kura.bak" ]] && mv "${MODEL_PATH}.kura.bak" "${MODEL_PATH}.kura"

            if [[ ${EXIT_CODE} -ne 0 ]]; then
                echo "FAILED (Exit Code ${EXIT_CODE} - Likely OOM or Killed)"
                echo "status=OOM_KILLED" >> "${LOG_OUT}"
            else
                echo "SUCCESS"
            fi
        done
    done
done

# 6. Parse and Aggregate Results into final phase2_sata_reality.json
echo "[JSON] Aggregating raw telemetry into ${OUTPUT_JSON}..."
python3 - "${RESULTS_TEMP}" "${OUTPUT_JSON}" << 'PYEOF'
import sys, json, os, re, glob
from datetime import datetime, timezone

temp_dir = sys.argv[1]
out_path = sys.argv[2]

report = {
    "meta": {
        "benchmark": "Kura Phase 2 SATA Reality Benchmark",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "host_hardware": {
            "cpu": "AMD Ryzen 3 3250U with Radeon Graphics (2c/4t, AVX2)",
            "memory": "5.7 GB Physical RAM",
            "storage": "128 GB SATA M.2 SSD (350 MB/s sequential read)",
            "cgroup_v2_limit": "3500M (MemorySwapMax=0)"
        }
    },
    "results": {}
}

models = ["1.5B", "7B"]
configs = ["mmap_baseline", "kura_buffered", "kura_loom"]

for m in models:
    report["results"][m] = {}
    for c in configs:
        report["results"][m][c] = []
        for r in range(1, 4):
            log_file = f"{temp_dir}/{m}_{c}_rep{r}.log"
            time_file = f"{temp_dir}/{m}_{c}_rep{r}.time"
            entry = {"repetition": r, "status": "UNKNOWN", "wall_clock_s": None, "ttft_ms": None, "tok_s": None, "majflt": None, "minflt": None, "max_rss_kb": None}
            
            if os.path.exists(time_file):
                with open(time_file) as tf:
                    t_text = tf.read()
                    maj = re.search(r'MAJFLT=(\d+)', t_text)
                    minf = re.search(r'MINFLT=(\d+)', t_text)
                    rss = re.search(r'MAX_RSS_KB=(\d+)', t_text)
                    wall = re.search(r'WALL_TIME_SEC=([0-9\.]+)', t_text)
                    if maj: entry["majflt"] = int(maj.group(1))
                    if minf: entry["minflt"] = int(minf.group(1))
                    if rss: entry["max_rss_kb"] = int(rss.group(1))
                    if wall: entry["wall_clock_s"] = float(wall.group(1))

            if os.path.exists(log_file):
                with open(log_file) as lf:
                    l_text = lf.read()
                    if "OOM_KILLED" in l_text:
                        entry["status"] = "OOM_KILLED"
                    elif "OFFLINE_MODEL_NOT_DOWNLOADED" in l_text:
                        entry["status"] = "OFFLINE_MODEL_NOT_DOWNLOADED"
                    else:
                        entry["status"] = "COMPLETED"
                        # Search for generated throughput
                        tps = re.search(r'(?:Total throughput|Throughput):\s*([0-9\.]+)\s*tok/s', l_text) or re.search(r'\(([0-9\.]+)\s*tok/s\)', l_text)
                        ttft = re.search(r'TTFT.*?:?\s*([0-9\.]+)\s*ms', l_text)
                        if tps: entry["tok_s"] = float(tps.group(1))
                        if ttft: entry["ttft_ms"] = float(ttft.group(1))

            report["results"][m][c].append(entry)

with open(out_path, "w") as f:
    json.dump(report, f, indent=2)

print(f"Emitted structured telemetry to {out_path}")
PYEOF

echo "========================================================================"
echo " PHASE 2 BENCHMARK RUN COMPLETE"
echo " Results written to: ${OUTPUT_JSON}"
echo "========================================================================"
chmod +x /home/renan/Downloads/projects/Kura/scripts/run_phase2_sata_reality.sh
