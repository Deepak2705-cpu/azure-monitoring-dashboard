# azure-monitoring-dashboard

![Azure Monitor](https://img.shields.io/badge/Azure%20Monitor-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)

> End-to-end observability stack for Azure-hosted applications — combining Azure Monitor, Prometheus, Grafana, Log Analytics, and Application Insights into a unified monitoring and alerting platform.

---

## 📌 Project Overview

This project sets up a complete monitoring and observability solution for applications running on Azure (AKS + App Services). It gives real-time visibility into application performance, infrastructure health, and logs — all in one place.

**Key Achievements:**
- 📊 Unified Grafana dashboards pulling from Azure Monitor + Prometheus simultaneously
- 🔍 Custom KQL queries in Log Analytics for business-level and ops-level dashboards
- 🚨 Proactive alerting with <2 minute detection time for critical incidents
- 📈 Real-time APM (Application Performance Monitoring) via Application Insights

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Infrastructure                        │
│                                                                 │
│   ┌──────────────┐    ┌─────────────────┐    ┌──────────────┐  │
│   │  AKS Cluster │    │   App Service   │    │   Azure VMs  │  │
│   └──────┬───────┘    └────────┬────────┘    └──────┬───────┘  │
│          │                     │                    │           │
└──────────┼─────────────────────┼────────────────────┼───────────┘
           │                     │                    │
           ▼                     ▼                    ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Metrics & Logs Collection                   │
│                                                                  │
│  ┌──────────────┐    ┌────────────────────┐    ┌──────────────┐  │
│  │  Prometheus  │    │  Application       │    │   Azure      │  │
│  │  (AKS metrics│    │  Insights (APM)    │    │   Monitor    │  │
│  │  scraping)   │    │  SDK integrated    │    │  (platform   │  │
│  └──────┬───────┘    └────────┬───────────┘    │   metrics)   │  │
│         │                     │                └──────┬───────┘  │
│         └──────────┬──────────┘                       │          │
│                    ▼                                   │          │
│         ┌──────────────────────┐                       │          │
│         │  Log Analytics       │◄──────────────────────┘          │
│         │  Workspace           │                                  │
│         │  (KQL queries)       │                                  │
│         └──────────┬───────────┘                                  │
└────────────────────┼──────────────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────┐
          │     Grafana      │
          │  (Unified View)  │
          │  Dashboards +    │
          │  Alerts          │
          └──────────────────┘
                     │
                     ▼
          ┌──────────────────────────────────┐
          │     Azure Action Groups          │
          │  📧 Email + 🔔 Webhook (Teams/   │
          │  Slack/PagerDuty)                │
          └──────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| Azure Monitor | Platform-level metrics for Azure resources |
| Prometheus | AKS cluster and application metrics scraping |
| Grafana | Unified visualization and dashboarding |
| Log Analytics Workspace | Centralized log storage + KQL querying |
| Application Insights | Real-time APM — request rates, failures, latency |
| Azure Action Groups | Alert routing — email, webhook, SMS |

---

## 📁 Project Structure

```
azure-monitoring-dashboard/
├── terraform/
│   ├── main.tf                        # Provisions monitoring resources
│   ├── log-analytics.tf               # Log Analytics Workspace
│   ├── app-insights.tf                # Application Insights resource
│   ├── action-groups.tf               # Alert action groups
│   └── alerts.tf                      # Metric alert rules
│
├── prometheus/
│   ├── prometheus.yml                 # Prometheus scrape config
│   └── kubernetes/
│       ├── prometheus-deployment.yaml
│       ├── prometheus-service.yaml
│       └── clusterrole.yaml           # RBAC for metrics scraping
│
├── grafana/
│   ├── dashboards/
│   │   ├── aks-cluster-overview.json  # AKS nodes, pods, CPU/mem
│   │   ├── app-performance.json       # Response time, error rate
│   │   ├── infrastructure.json        # VM + LB metrics
│   │   └── log-analytics.json         # Log-based panels (KQL)
│   ├── datasources/
│   │   ├── azure-monitor.yaml         # Azure Monitor datasource
│   │   └── prometheus.yaml            # Prometheus datasource
│   └── grafana-deployment.yaml        # Grafana on AKS
│
├── kql-queries/
│   ├── error-rate.kql                 # Application error tracking
│   ├── slow-requests.kql              # P95/P99 latency queries
│   ├── pod-restarts.kql               # K8s pod crash tracking
│   └── custom-events.kql              # Business event tracking
│
└── README.md
```

---

## 📊 Dashboards

### 1. AKS Cluster Overview
- Node CPU and memory utilization (per node)
- Pod count, pending pods, and restart counts
- Network ingress/egress per namespace
- PVC storage usage

### 2. Application Performance (App Insights)
- Request rate (requests per second)
- Average response time + P95 / P99 latency
- Failed request rate and exception tracking
- Dependency call performance (DB, external APIs)

### 3. Infrastructure Health
- Azure VM CPU, memory, disk IOPS
- Load Balancer — health probe status, connections
- Storage Account — transaction rates and latency

### 4. Log Analytics (KQL-Powered)
- Error log trends over time
- Slow query detection
- Security audit events
- Custom application events

---

## 🔍 Sample KQL Queries

```kql
// Top 10 slowest requests in the last hour
requests
| where timestamp > ago(1h)
| order by duration desc
| take 10
| project timestamp, name, duration, resultCode, cloud_RoleName
```

```kql
// Error rate percentage by operation
requests
| where timestamp > ago(24h)
| summarize total = count(), failed = countif(success == false) by name
| extend error_rate = round(100.0 * failed / total, 2)
| order by error_rate desc
```

```kql
// Pod restart events from AKS
KubeEvents
| where Reason == "BackOff" or Reason == "OOMKilling"
| project TimeGenerated, Name, Namespace, Message
| order by TimeGenerated desc
```

---

## 🚨 Alerting Setup

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| High CPU | Node CPU > 85% for 5 min | Warning | Email |
| Pod CrashLoop | Pod restarts > 5 in 15 min | Critical | Email + Webhook |
| High Error Rate | Failed requests > 5% | Critical | Email + Webhook |
| High Latency | P95 response > 2000ms | Warning | Email |
| Disk Full | Disk usage > 90% | Critical | Email + Webhook |

All alerts route through **Azure Action Groups** — email notifications sent immediately, webhooks integrate with Teams/Slack.

---

## 🚀 Getting Started

### Prerequisites
- AKS cluster running (see [terraform-azure-infra-hub](https://github.com/deepak-tr/terraform-azure-infra-hub))
- kubectl configured
- Azure CLI logged in

### Step 1: Provision Monitoring Resources

```bash
cd terraform/
terraform init
terraform apply
```

This creates: Log Analytics Workspace, Application Insights, and Action Groups.

### Step 2: Deploy Prometheus to AKS

```bash
kubectl apply -f prometheus/kubernetes/
# Verify Prometheus is running
kubectl get pods -n monitoring
```

### Step 3: Deploy Grafana

```bash
kubectl apply -f grafana/grafana-deployment.yaml
# Get Grafana service URL
kubectl get svc grafana -n monitoring
```

### Step 4: Import Dashboards

1. Open Grafana UI → Dashboards → Import
2. Upload JSON files from `grafana/dashboards/`
3. Select the correct data sources when prompted

---

## 📚 Learnings

- Setting up Prometheus scraping in a Kubernetes environment
- Writing KQL queries for Log Analytics dashboards
- Configuring Grafana with multiple data sources (Azure Monitor + Prometheus)
- Building proactive alerting with Azure Action Groups
- Understanding APM concepts — request tracing, latency percentiles, error budgets

---

## 👤 Author

**Deepak T R**
- 📧 deepuraj0527@gmail.com
- 💼 [LinkedIn](https://linkedin.com/in/deepak-tr)
- 🐙 [GitHub](https://github.com/deepak-tr)
- 🏅 AZ-104 Certified | AZ-400 In Progress
