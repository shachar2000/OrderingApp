# 📊 Elasticsearch & Kibana Docker Setup

This setup uses Docker Compose to deploy a local **Elasticsearch** and **Kibana** stack for data analysis, logging, and monitoring. It's designed for local development and testing purposes.

---

## 📦 Services Included

### 1. **Elasticsearch**
- **Image**: `docker.elastic.co/elasticsearch/elasticsearch:8.13.4`
- **Port**: Exposes Elasticsearch on **`9201`**
- **Authentication**: Disabled (`xpack.security.enabled=false`)
- **Memory Settings**: Configured with 512MB heap
- **Volume**: Persists data to `elasticsearch_data` volume

### 2. **Kibana**
- **Image**: `docker.elastic.co/kibana/kibana:8.13.4`
- **Port**: Exposes Kibana on **`5601`**
- **Elasticsearch Host**: Connects to the local Elasticsearch container
- **Authentication**: Disabled (`xpack.security.enabled=false`)
- **Depends on**: Elasticsearch (starts only after Elasticsearch is running)

---

## 🔧 How to Use

1. **Clone the Repository or Save the Files**

2. **Run the Stack**

   ```bash
   docker-compose up -d
