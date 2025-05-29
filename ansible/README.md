# 📦 Ansible Playbook: OrderAppServer & Monitoring Setup

This playbook installs and configures the OrderAppServer application and monitoring tools using Docker, node_exporter, and Logstash on Ubuntu servers.

---

## 🚀 What Does This Playbook Do?

1. **Installs Docker** and ensures the service is running.
2. **Runs the OrderAppServer container** from Docker Hub.
3. Creates an external log file at `/home/ubuntu/AppOrderServer.log` and mounts it to the container.
4. **Installs and starts node_exporter** on port `9200` for monitoring.
5. **Installs Logstash**, copies a configuration file, and sets up a `systemd` service for automatic execution.

---

## 🛠 Prerequisites

- Ubuntu 20.04/22.04 server
- `sudo` privileges (become: true)
- Logstash config file: `logstash-order-app.conf` (must be in the same directory as the playbook)
- The following environment variables must be defined (via `.env` or Ansible `extra-vars`):

```env
RdsEndpoint=
db_username=
db_password=
db_name=
secret_key=
prometheus_grafana_instance_ip=
