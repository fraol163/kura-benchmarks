# Kura Production API Reference

**Runtime Version**:- `v0.1.0`  
**Protocol Compliance**:- OpenAI API Specification (`v1`), Server-Sent Events (SSE, RFC 8895), Prometheus Exposition (`v0.0.4`)  
**Architecture Target**:- Storage-Native High-Throughput Inference Engine

---

## 1. Overview

Kura exposes a production-ready HTTP server engineered for low-latency, memory-constrained inference over local storage. The server provides 100% drop-in API compatibility with the OpenAI SDK and ecosystem tools, enabling seamless integration into existing AI applications, agent frameworks, and monitoring pipelines.

### Key Capabilities
- **OpenAI Compatible**:- Native support for `/v1/completions`, `/v1/chat/completions`, and `/v1/models`.
- **Zero-Allocation SSE Streaming**:- Token-by-token streaming with Server-Sent Events (`stream: true`), unblocking frontend token display.
- **Enterprise Telemetry**:- Production `/health` endpoint for Kubernetes/systemd liveness probes and Prometheus `/metrics` exposition for Grafana dashboards.
- **Transient Error Resilience**:- Automated 3-retry exponential backoff on storage reads (`pread64`), eliminating transient kernel I/O drops.
- **Memory Pressure Protection**:- Autonomous force-eviction of Cold/Warm weight tiers when RSS >= 95% of cgroup limit, preventing OOM kills.
- **Graceful Draining & Shutdown**:- Signal listeners (`SIGTERM`, `SIGINT`) that stop accepting traffic, drain in-flight requests within a 10s deadline, flush metrics, and unmap staging buffers cleanly.

---

## 2. Server Startup (`kura serve`)

The server is initiated via the `kura serve` subcommand.

```bash
kura serve \
  --model /path/to/model.gguf \
  --port 8080 \
  --host 0.0.0.0 \
  --memory-budget 7500M \
  --threads 4
```

### Command-Line Arguments
| Flag | Short | Default | Description |
|---|---|---|---|
| `--model <PATH>` | `-m` | *Required* | Absolute or relative path to GGUF model file. Auto-detects Loom `.kura` coalesced layouts. |
| `--port <PORT>` | `-p` | `8080` | TCP port to bind the HTTP server to. |
| `--host <IP>` | | `0.0.0.0` | Network interface to bind (`0.0.0.0` for all interfaces, `127.0.0.1` for localhost only). |
| `--memory-budget <SIZE>` | | `8G` | Working RAM budget (e.g. `7500M`, `8G`, `4096MB`). Controls layer residency and KV cache allocation. |
| `--threads <NUM>` | | `4` | Number of worker threads allocated for parallel GEMV compute. |

---

## 3. Endpoints

### 3.1. Text Completions (`POST /v1/completions`)

Generates text completions given a text prompt. Supports both synchronous JSON and streaming SSE output.

#### Request Headers
```http
Content-Type: application/json
```

#### Request Body Schema
```json
{
  "model": "qwen2.5-7b",
  "prompt": "The fundamental law of memory hierarchy states that",
  "max_tokens": 64,
  "temperature": 0.0,
  "stream": false
}
```

#### Parameters
| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `model` | string | Optional | Current model ID | Identifier of the target model. |
| `prompt` | string | Optional | `""` | The input context to generate completions for. |
| `max_tokens` | integer | Optional | `64` | Maximum number of tokens to decode (capped at 2048). |
| `temperature` | float | Optional | `0.0` | Sampling temperature (`0.0` for greedy deterministic argmax). |
| `stream` | boolean | Optional | `false` | When `true`, tokens are streamed via Server-Sent Events. |

---

#### Synchronous Response (`stream: false`)
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "cmpl-18d9bb49223f580c",
  "object": "text_completion",
  "created": 1790668249,
  "model": "qwen2.5-7b",
  "choices": [
    {
      "text": " access time increases monotonically with capacity across storage tiers.",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 9,
    "completion_tokens": 12,
    "total_tokens": 21
  }
}
```

#### Streaming Response (`stream: true`)
```http
HTTP/1.1 200 OK
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive

data: {"id":"cmpl-18d9bb617f3e7baf","object":"text_completion","created":1790668354,"model":"qwen2.5-7b","choices":[{"text":" access","index":0,"logprobs":null,"finish_reason":null}]}

data: {"id":"cmpl-18d9bb617f3e7baf","object":"text_completion","created":1790668354,"model":"qwen2.5-7b","choices":[{"text":" time","index":0,"logprobs":null,"finish_reason":null}]}

data: {"id":"cmpl-18d9bb617f3e7baf","object":"text_completion","created":1790668354,"model":"qwen2.5-7b","choices":[{"text":"","index":0,"logprobs":null,"finish_reason":"stop"}]}

data: [DONE]
```

#### cURL Examples
```bash
# Non-streaming request
curl -s -X POST http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Artificial intelligence systems require",
    "max_tokens": 32,
    "temperature": 0.0
  }'

# Streaming request (unbuffered output)
curl -N -s -X POST http://localhost:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Artificial intelligence systems require",
    "max_tokens": 32,
    "temperature": 0.0,
    "stream": true
  }'
```

---

### 3.2. Chat Completions (`POST /v1/chat/completions`)

Generates structured conversational assistant responses using standard OpenAI message formatting. Messages are automatically formatted using the high-performance ChatML template (`<|im_start|>role\ncontent<|im_end|>`).

#### Request Body Schema
```json
{
  "model": "qwen2.5-7b",
  "messages": [
    {
      "role": "system",
      "content": "You are a concise systems engineering assistant."
    },
    {
      "role": "user",
      "content": "What is the primary bottleneck in Dense 70B inference?"
    }
  ],
  "max_tokens": 64,
  "temperature": 0.0,
  "stream": false
}
```

#### Parameters
| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `model` | string | Optional | Current model ID | Identifier of the target model. |
| `messages` | array | Required | - | List of chat messages with `role` (`"system"`, `"user"`, `"assistant"`) and `content`. |
| `max_tokens` | integer | Optional | `64` | Maximum completion tokens to generate. |
| `temperature` | float | Optional | `0.0` | Sampling temperature. |
| `stream` | boolean | Optional | `false` | When `true`, returns an SSE chunk stream. |

---

#### Synchronous Response (`stream: false`)
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "chatcmpl-18d9bb6319bcd54b",
  "object": "chat.completion",
  "created": 1790668361,
  "model": "qwen2.5-7b",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Single-drive sequential NVMe bandwidth (~1,500-5,000 MB/s) streaming 38.6 GB of weights per token."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 28,
    "completion_tokens": 24,
    "total_tokens": 52
  }
}
```

#### Streaming Response (`stream: true`)
```http
HTTP/1.1 200 OK
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive

data: {"id":"chatcmpl-18d9bb64f46372f7","object":"chat.completion.chunk","created":1790668369,"model":"qwen2.5-7b","choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"id":"chatcmpl-18d9bb64f46372f7","object":"chat.completion.chunk","created":1790668369,"model":"qwen2.5-7b","choices":[{"index":0,"delta":{"content":"Single"},"finish_reason":null}]}

data: {"id":"chatcmpl-18d9bb64f46372f7","object":"chat.completion.chunk","created":1790668369,"model":"qwen2.5-7b","choices":[{"index":0,"delta":{"content":"-drive"},"finish_reason":null}]}

data: {"id":"chatcmpl-18d9bb64f46372f7","object":"chat.completion.chunk","created":1790668369,"model":"qwen2.5-7b","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

#### cURL Examples
```bash
# Non-streaming chat completion
curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Explain Decoupled Memory in two sentences."}
    ],
    "max_tokens": 48
  }'

# Streaming chat completion
curl -N -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Count from 1 to 10."}
    ],
    "max_tokens": 32,
    "stream": true
  }'
```

---

### 3.3. System Health Check (`GET /health`)

Returns real-time operating health, process RSS, cgroup v2 limits, active memory pressure, and total request counts. Used by container orchestrators (Kubernetes liveness/readiness probes) and systemd watchdogs.

#### Response Schema
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "status": "healthy",
  "uptime_seconds": 1284,
  "rss_bytes": 541806592,
  "rss_human": "516.7 MB",
  "cgroup_memory_limit_bytes": 7864320000,
  "cgroup_memory_current_bytes": 541806592,
  "memory_pressure_ratio": 0.0689,
  "active_requests": 0,
  "total_requests_served": 428
}
```

| Field | Type | Description |
|---|---|---|
| `status` | string | `"healthy"` when memory pressure ratio < 0.95, or `"degraded_memory_pressure"` when >= 0.95. |
| `uptime_seconds` | integer | Server process uptime in seconds. |
| `rss_bytes` | integer | Current resident set size (RSS) in bytes. |
| `rss_human` | string | Formatted human-readable RSS (e.g. `"516.7 MB"`). |
| `cgroup_memory_limit_bytes`| integer | Active cgroup v2 memory limit (`memory.max`) or configured budget. |
| `cgroup_memory_current_bytes`| integer | Active cgroup v2 memory consumption (`memory.current`). |
| `memory_pressure_ratio` | float | Ratio of current memory to limit (0.0 to 1.0). At >= 0.95, MPE triggers. |
| `active_requests` | integer | Number of requests currently executing in the engine. |
| `total_requests_served` | integer | Cumulative total of successfully served requests since boot. |

#### cURL Example
```bash
curl -s http://localhost:8080/health
```

---

### 3.4. Prometheus Metrics Exposition (`GET /metrics`)

Exposes standard Prometheus-compatible telemetry gauges and counters for scraping and ingestion into Prometheus, Grafana, and Datadog.

#### Response Headers
```http
Content-Type: text/plain; version=0.0.4; charset=utf-8
```

#### Response Body
```prometheus
# HELP kura_tokens_per_second Token generation throughput in tokens per second
# TYPE kura_tokens_per_second gauge
kura_tokens_per_second 14.85

# HELP kura_ttft_ms Time to first token in milliseconds
# TYPE kura_ttft_ms gauge
kura_ttft_ms 18.24

# HELP kura_cache_hit_rate Cache hit rate
# TYPE kura_cache_hit_rate gauge
kura_cache_hit_rate 0.9824

# HELP kura_memory_rss_bytes Current process RSS memory in bytes
# TYPE kura_memory_rss_bytes gauge
kura_memory_rss_bytes 541806592

# HELP kura_active_requests Number of currently active inference requests
# TYPE kura_active_requests gauge
kura_active_requests 0

# HELP kura_total_tokens_generated Total number of tokens generated
# TYPE kura_total_tokens_generated counter
kura_total_tokens_generated 12850

# HELP kura_total_requests_served Total number of requests served
# TYPE kura_total_requests_served counter
kura_total_requests_served 428
```

#### cURL Example
```bash
curl -s http://localhost:8080/metrics
```

#### Prometheus Scrape Config (`prometheus.yml`)
```yaml
scrape_configs:
  - job_name: 'kura_inference'
    scrape_interval: 5s
    static_configs:
      - targets: ['127.0.0.1:8080']
```

---

### 3.5. Model Listing (`GET /v1/models`)

Returns the current active model in OpenAI-compatible collection schema.

#### Response Schema
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "object": "list",
  "data": [
    {
      "id": "qwen2.5-7b",
      "object": "model",
      "created": 1700000000,
      "owned_by": "kura",
      "permission": [],
      "root": "qwen2.5-7b",
      "parent": null
    }
  ]
}
```

#### cURL Example
```bash
curl -s http://localhost:8080/v1/models
```

---

## 4. CLI Introspection Subcommands

Kura provides native CLI introspection tools to analyze hardware capabilities and inspect compiled LOOM execution plans prior to serving.

### 4.1. `kura profile`

Outputs the comprehensive SENSE hardware profile: CPU topology, SIMD ISA (AVX-512, AVX2, SSE4.2, NEON), NUMA domains, Unified Memory status, empirical GFLOPS probe, physical/available RAM, and storage device bandwidths.

#### Usage
```bash
# Human-readable output
kura profile

# Machine-readable JSON output
kura profile --json

# Profile hardware with specific model metadata
kura profile /path/to/model.gguf
```

#### Example Output (`kura profile`)
```text
============================================================
KURA SENSE HARDWARE PROFILE
============================================================
CPU:         Intel(R) Xeon(R) w5-3425 (12 physical cores, 24 threads)
SIMD ISA:    AVX-512: YES | AVX2: YES | SSE4.2: YES | NEON: NO
L3 Cache:    30.0 MB (1 slices)
NUMA / UMA:  1 nodes | Unified Memory: NO (Discrete Storage / DRAM)
Compute:     35.1 GFLOPS (empirical probe: 112ms)
RAM:         66.62 GB total | 56.35 GB avail | 7.86 GB budget
Channels:    4 × DDR5 | Est. Bandwidth: 153.6 GB/s
Swap:        INACTIVE (Clean)
Storage:     NVMe SSD (PCIe) | 5367.7 MB/s seq read | seq write: 1863 MB/s
Capacity:    2014.0 GB total | 628.0 GB free
Scheduler:   none
OS / Kernel: Linux Ubuntu 24.04.4 LTS | Kernel: 6.8.0-142-generic | Arch: x86_64
Probe Time:  312ms (Detection Level: FULL)
============================================================
```

---

### 4.2. `kura plan`

Compiles and outputs the LOOM physical execution plan for a target model under a given memory budget. Shows resident/hot/warm/cold layer distributions, prefetch window (W), KV cache budget, and deterministic plan hash.

#### Usage
```bash
# Human-readable output
kura plan --model /path/to/model.gguf --budget 7500M

# Machine-readable JSON output
kura plan --model /path/to/model.gguf --budget 7500M --json
```

#### Example Output (`kura plan --model qwen2.5-7b.gguf --budget 7500M`)
```text
============================================================
KURA LOOM EXECUTION PLAN
============================================================
Model:           /home/Renan/models/qwen2.5-7b/Qwen2.5-7B-Instruct-Q4_K_M.gguf
Architecture:    28 layers | 1 experts (Dense)
Workload:        code
Memory Budget:   7.86 GB (7864320000 bytes)
Deterministic Hash: b246732608a5992c
------------------------------------------------------------
RESIDENCY TIER BREAKDOWN (Total units: 28)
  Hot (Resident):          2 units (7.1%)
  Warm (Cached):           0 units (0.0%)
  Cold (On-Demand NVMe):   0 units (0.0%)
  Compressed (Tiered):    26 units (92.9%)
  Router Layer:         boot
------------------------------------------------------------
PREFETCH & KV POLICY
  Prefetch Policy:      W=2 (2-layer lookahead (NVMe streaming))
  KV Cache Budget:      1572.9 MB (20.0% of RAM budget)
  Activation Share:     8.0%
  Storage Risk:         low
============================================================
```

---

## 5. Error Recovery Specifications

Kura implements fault tolerance at the storage and memory boundaries:-

### 5.1. Storage Read Retry with Exponential Backoff
All weight reads (`pread64`) are protected against transient kernel I/O pressure:-
- If a read returns `EAGAIN`, `EINTR`, `EIO`, `WouldBlock`, or `TimedOut`, Kura automatically retries up to **3 times** with exponential backoff (1 ms -> 2 ms -> 4 ms).
- Persistent failures after 3 attempts return a clear `500 Internal Server Error` without terminating the process or corrupting the global state.

### 5.2. Memory Pressure Eviction (MPE)
To guarantee zero Out-Of-Memory (OOM) kills under strict cgroup limits:-
- Prior to and during layer execution, the engine inspects current RSS against the cgroup memory limit (`/sys/fs/cgroup/memory.current` vs `memory.max`).
- When Usage / Limit >= 0.95 (95%), the engine automatically force-evicts all Cold and Warm cached weight tensors.
- The Hot tier (critical transformer backbone and vocabulary embeddings) is preserved, avoiding swap thrashing and keeping inference operational.

### 5.3. Graceful Draining & Shutdown
When receiving a termination signal (`SIGINT` / `SIGTERM`):-
1. **Traffic Gate Closed**:- The HTTP listener stops accepting new connections immediately.
2. **Active Request Drain**:- In-flight completions are allowed to finish decoding (timeout: 10 seconds).
3. **Telemetry Flush**:- Prometheus counters and access logs are flushed to disk.
4. **Clean Resource Deallocation**:- Staging arenas are unmapped and file descriptors are closed safely before process exit code 0.
