import json

m3_path = "/home/renan/Downloads/projects/Kura/Kura-kura-phase34-tui-product-layer-v1/results/raw/m3_real_moe_benchmarks.json"
m4_path = "/home/renan/Downloads/projects/Kura/Kura-kura-phase34-tui-product-layer-v1/results/raw/m4_regime_maps.json"
m5_path = "/home/renan/Downloads/projects/Kura/Kura-kura-phase34-tui-product-layer-v1/results/raw/m5_ablations.json"
m6_path = "/home/renan/Downloads/projects/Kura/Kura-kura-phase34-tui-product-layer-v1/results/raw/m6_ember_gate.json"
m2_path = "/home/renan/Downloads/projects/Kura/Kura-kura-phase34-tui-product-layer-v1/results/raw/m2_correctness_determinism.json"

print("=================================================================")
print("INDEPENDENT RECALCULATION & ARITHMETIC VERIFICATION OF KURA CLAIMS")
print("=================================================================")

# -------------------------------------------------------------
# 1. Random-Read Reductions (Loom)
# -------------------------------------------------------------
print("\n--- 1. RANDOM READ REDUCTION (Claim 1) ---")
with open(m3_path) as f:
    m3 = json.load(f)

# Primary Model: shared-small.gguf (166 MB @ 24 MB RAM)
pm_metrics = m3["primary_model"]["metrics"]
print("Primary model available stages:", list(pm_metrics.keys()))
pm_lru = pm_metrics["baseline_lru"]
pm_loom = pm_metrics.get("c1_loom", pm_metrics.get("loom_only", {}))
pm_kaef = pm_metrics.get("b0_kaef", pm_metrics.get("kaef_only", {}))
pm_kaef_loom = pm_metrics.get("c3_kaef_loom", pm_metrics.get("kaef_loom", {}))

print("Primary Model stage names:")
for k, v in pm_metrics.items():
    rr = v.get("rand_reads")
    sr = v.get("seq_reads")
    tt = v.get("ttft_ms")
    th = v.get("tokens_per_s")
    print(f"  {k}: rand_reads={rr}, seq_reads={sr}, ttft_ms={tt}, tok/s={th}")

# Secondary Model: shared-olmoe.gguf (1.21 GB @ 256 MB RAM)
sm_metrics = m3["secondary_model"]["metrics"]
print("\nSecondary Model stage names:")
for k, v in sm_metrics.items():
    rr = v.get("rand_reads")
    sr = v.get("seq_reads")
    tt = v.get("ttft_ms")
    th = v.get("tokens_per_s")
    print(f"  {k}: rand_reads={rr}, seq_reads={sr}, ttft_ms={tt}, tok/s={th}")
