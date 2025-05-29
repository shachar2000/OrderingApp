# Monitoring Stack: Prometheus & Grafana

This Docker Compose file sets up **Prometheus** for monitoring and **Grafana** for visualization. It includes automatic configuration of data sources and dashboards.

---

## 📦 Services

### 🔍 Prometheus

- **Image**: `prom/prometheus:latest`
- **Port**: `9090`
- **Config File**: Mounts `./prometheus.yml` into the container
- **Container Name**: `prometheus`
- **Restart Policy**: Always restarts on failure or reboot

### 📊 Grafana

- **Image**: `grafana/grafana:latest`
- **Port**: Maps internal port `3000` to host port `3001`
- **Environment Variable**:
  - `GF_SECURITY_ADMIN_PASSWORD=admin` — sets admin password
- **Volumes**:
  - `./provisioning/datasources` → predefined Prometheus data source
  - `./provisioning/dashboards` → custom dashboard JSON files
  - `./provisioning/dashboard.yaml` → dashboard provisioning config
- **Container Name**: `grafana`
- **Depends on**: `prometheus` (Grafana starts after Prometheus)
- **Restart Policy**: Always

---

## 📁 Directory Structure

```plaintext
.
├── docker-compose.yml
├── prometheus.yml
└── provisioning/
    ├── datasources/
    │   └── prometheus.yml
    ├── dashboards/
    │   └── your-dashboard.json
    └── dashboard.yaml
