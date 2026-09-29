# Kura Production Deployment Guide

**Runtime**: Kura Storage-Native Inference Engine  
**Target Environment**: Linux (Ubuntu 22.04 / 24.04 LTS, RHEL 9, Debian 12)  
**Hardware Profile**: Commodity NVMe SSD (PCIe Gen3/Gen4/Gen5) + DDR4/DDR5 RAM + Modern CPU (AVX2, AVX-512, or ARM NEON)

---

## 1. System Requirements & Host Tuning

Kura achieves high throughput on budget hardware by bypassing traditional page-cache virtual memory buffering and orchestrating sequential storage streaming. Optimal operation requires minimal host tuning.

### 1.1. Operating System & Kernel
- **Kernel Version**: Linux `5.15` or higher (Linux `6.8+` recommended).
- **Cgroup Architecture**: Cgroup v2 unified hierarchy (`/sys/fs/cgroup`).
- **Filesystem**: `ext4` or `xfs` mounted with standard options (`noatime` recommended for model directories).

### 1.2. Storage Device Tuning
For optimal pread / direct I/O performance on NVMe devices:
```bash
# Verify NVMe I/O scheduler is set to none (bypasses OS elevator queues)
cat /sys/block/nvme0n1/queue/scheduler
# [none] mq-deadline

# If not set to none, configure persistently:
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler

# Set udev rule for persistent storage queue discipline
sudo tee /etc/udev/rules.d/60-kura-nvme.rules << 'EOF'
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/read_ahead_kb}="128"
EOF
sudo udevadm control --reload && sudo udevadm trigger
```

### 1.3. Swap Configuration
> [!WARNING]
> Swap degradation destroys deterministic token generation latency. Kura's memory manager is designed to stay completely within physical RAM. Ensure `MemorySwapMax=0` in cgroups or disable system swap on dedicated inference hosts:

```bash
# Disable swap immediately
sudo swapoff -a

# Ensure swappiness is low
sudo sysctl -w vm.swappiness=1
echo "vm.swappiness=1" | sudo tee -a /etc/sysctl.d/99-kura.conf
```

---

## 2. Model Preparation & Loom Pre-Layout

To achieve peak token generation speed, reorder the model's physical byte layout into sequential forward-pass spans before deployment:

```bash
# 1. Compile the machine execution plan and inspect residency tiers
kura plan --model /models/Qwen2.5-7B-Instruct-Q4_K_M.gguf --budget 7500M

# 2. (Optional) Reorganize physical layout for zero-seek forward pass
kura optimize /models/Qwen2.5-7B-Instruct-Q4_K_M.gguf --ram-budget 7500M
# Generates /models/Qwen2.5-7B-Instruct-Q4_K_M.gguf.kura sidecar
```

---

## 3. Production Service Deployment (systemd)

A standard, production-hardened systemd service file enforces strict cgroup limits, sets user boundaries, configures restart logic, and handles graceful shutdowns.

### 3.1. Installation of Binary & Model
```bash
sudo cp target/release/kura /usr/local/bin/kura
sudo chmod 755 /usr/local/bin/kura

sudo mkdir -p /var/lib/kura/models
sudo mkdir -p /var/log/kura
sudo useradd -r -s /bin/false -d /var/lib/kura kura
sudo chown -R kura:kura /var/lib/kura /var/log/kura
```

### 3.2. Systemd Unit File (`/etc/systemd/system/kura.service`)
```ini
[Unit]
Description=Kura Storage-Native AI Inference Engine
Documentation=https://github.com/fraol163/Kura
After=network.target local-fs.target
Wants=network-online.target

[Service]
Type=simple
User=kura
Group=kura
WorkingDirectory=/var/lib/kura
Environment="RUST_LOG=info"

# Execution command
ExecStart=/usr/local/bin/kura serve \
    --model /var/lib/kura/models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
    --host 127.0.0.1 \
    --port 8080 \
    --memory-budget 7500M \
    --threads 8

# Process Lifecycle & Graceful Drain
Restart=always
RestartSec=5s
KillSignal=SIGTERM
TimeoutStopSec=20s

# Strict Cgroup v2 Isolation (No Swap, Hard RAM Cap)
MemoryAccounting=yes
MemoryMax=7500M
MemoryHigh=7125M
MemorySwapMax=0
IOAccounting=yes
IOWeight=1000

# Security and Sandbox Restrictions
LimitNOFILE=65536
LimitMEMLOCK=infinity
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/kura /var/log/kura

[Install]
WantedBy=multi-user.target
```

### 3.3. Activating and Managing the Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now kura.service

# Check live service status and cgroup metrics
sudo systemctl status kura.service

# Inspect live streaming logs
sudo journalctl -u kura.service -f
```

---

## 4. Reverse Proxy Setup (Nginx)

Nginx sits between client traffic and Kura to provide SSL/TLS termination, HTTP/2 multiplexing, rate limiting, and unbuffered SSE token streaming.

> [!IMPORTANT]
> `proxy_buffering off;` and `proxy_cache off;` are mandatory. If proxy buffering is enabled, Nginx will buffer Server-Sent Events, breaking token-by-token streaming in the client.

### 4.1. Nginx Configuration (`/etc/nginx/sites-available/kura.conf`)
```nginx
upstream kura_backend {
    server 127.0.0.1:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name ai.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ai.example.com;

    ssl_certificate /etc/letsencrypt/live/ai.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ai.example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Client payload size (accommodates large context prompts)
    client_max_body_size 64M;

    # OpenAI-compatible API reverse proxy
    location /v1/ {
        proxy_pass http://kura_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Critical SSE streaming directives
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
        chunked_transfer_encoding on;
    }

    # Health check endpoint for external monitoring
    location /health {
        proxy_pass http://kura_backend/health;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        access_log off;
    }

    # Prometheus metrics scraper endpoint (restrict to internal network)
    location /metrics {
        allow 10.0.0.0/8;
        allow 172.16.0.0/12;
        allow 192.168.0.0/16;
        allow 127.0.0.1;
        deny all;

        proxy_pass http://kura_backend/metrics;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

### 4.2. Verify and Reload Nginx
```bash
sudo ln -s /etc/nginx/sites-available/kura.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 5. Standalone Container / Cgroup v2 Testing

To verify execution directly under cgroup limits without configuring systemd services, use `systemd-run`:

```bash
# Execute isolated test with 7.5 GB RAM cap and zero swap
systemd-run --user --scope \
  -p MemoryMax=7500M \
  -p MemorySwapMax=0 \
  kura serve \
    --model /models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
    --port 8080 \
    --memory-budget 7500M
```

---

## 6. Production Health Monitoring & Observability

### 6.1. Automated Health Check Probe
Configure Kubernetes or uptime monitors with:
- **HTTP Path**: `GET http://ai.example.com/health`
- **Expected Status**: `200 OK`
- **Response Validation**: JSON field `status == "healthy"` and `memory_pressure_ratio < 0.95`.

### 6.2. Prometheus Alerting Rules (`kura_alerts.yml`)
```yaml
groups:
  - name: kura_inference_alerts
    rules:
      - alert: KuraServerDegradedMemoryPressure
        expr: kura_memory_rss_bytes / 7864320000 >= 0.95
        for: 30s
        labels:
          severity: warning
        annotations:
          summary: "Kura engine operating under critical memory pressure (>= 95%)"
          description: "Process RSS has reached {{ $value | humanizePercentage }} of cgroup ceiling."

      - alert: KuraThroughputDrop
        expr: kura_tokens_per_second < 1.0 and kura_active_requests > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Inference throughput dropped below 1.0 tok/s"
          description: "Decode throughput is {{ $value }} tok/s, indicating storage throttling or contention."

      - alert: KuraServiceDown
        expr: up{job="kura_inference"} == 0
        for: 15s
        labels:
          severity: page
        annotations:
          summary: "Kura inference server is unreachable"
```

---

## 7. Verification Checklist

Prior to routing production client traffic, execute this verification run:

- [ ] `kura profile` passes and detects CPU SIMD, RAM channels, and NVMe bandwidth.
- [ ] `kura plan --model <path> --budget <MB>` verifies layer allocation without memory overflow.
- [ ] `GET /health` returns HTTP 200 with `status: "healthy"`.
- [ ] `GET /metrics` returns valid Prometheus exposition data.
- [ ] `POST /v1/completions` generates valid tokens under 1.0s TTFT.
- [ ] `POST /v1/chat/completions` with `stream: true` delivers tokens chunk-by-chunk over SSE.
- [ ] `SIGTERM` triggers graceful draining and clean exit within 10s.
- [ ] Process survives under strict cgroup ceiling with zero OOM events.
