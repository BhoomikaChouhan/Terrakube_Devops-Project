# 🚀 Tutorial: Deploying Web Application on Kubernetes Cluster

---

## 🎬 Introduction

Welcome to the project! 👋

This project is about **deploying a web application on a Kubernetes cluster**.

👉 Situation:
- We already have a **multi-tier web application stack**, containerized earlier (V Profile Web App).
- Now it’s time to **host it for production**.
- Production means:
  - High availability 🟢
  - Fault tolerance ⚡
  - Auto-healing 🩹
  - Easy scaling of both containers and compute resources 📈
  - Platform independence 🌍

👉 Tool of choice: **Kubernetes** (the king of container orchestration 👑).
- Very mature & rock solid for production workloads.
- Fun fact: **77% of containers today run on Kubernetes** (and if you include RedShift & Rancher → 89%).

🎯 Goal: Run the **Java V Profile Web Application** on a Kubernetes cluster using **Kops**.

### Requirements:
1. **Kubernetes Cluster** → created using **Kops** (check Kubernetes setup project).
2. **Containerized Application** → V Profile app (already done in containerization project).

👉 Database (MySQL container) needs persistent data → we’ll use **AWS EBS Volume**.
👉 To ensure DB pod runs in the right zone → we’ll **label nodes with zone names**.

Finally, we’ll write **Kubernetes definition files** for:
- Deployment
- Service
- Secret
- Volume

---

## 🏗️ Architecture

Now let’s understand the **architecture** of our setup.

### 1. Backend Components
- **Pods** → MySQL, Memcache, RabbitMQ, Tomcat
- But… in Kubernetes we don’t run pods directly → we use **Deployments**.
  - 1 Deployment each for: Tomcat, RabbitMQ, Memcache, MySQL.

### 2. Communication
- Pods don’t talk directly → they connect via **Service (ClusterIP)**.
  - Example: Tomcat → Database → through **DB Service**.
  - Service acts like a **load balancer** inside the cluster.

### 3. Stateful Applications (MySQL)
- DB needs to **store data** at `/var/lib/mysql`.
- Problem: If pod dies, data vanishes 🚨
- Solution: **Persistent Volume Claim (PVC)** connected to **EBS (via StorageClass)**.
  - StorageClass = driver that connects Kubernetes to AWS EBS.
  - PVC requests storage → StorageClass provisions it → Pod uses it.

### 4. Secrets
- Need to store **passwords** securely (DB + RabbitMQ).
- Use **Secret object** in Kubernetes.

### 5. Services
- ClusterIP services for **RabbitMQ, Memcache, MySQL, Tomcat** (internal comms).
- But Tomcat (V Profile App) must be exposed to external users 🌎
  - Use **Ingress Controller (Nginx)**.
  - Ingress Controller creates an **Application Load Balancer (ALB)** on AWS.
  - Ingress Rule → Routes request like: `vprofile.infotech.com` → Tomcat Service.
  - GoDaddy DNS record maps domain → ALB endpoint.

### 6. Summary of Manifests Needed
1. **Secret manifest** (store passwords 🔑)
2. **Persistent Volume Claim manifest** (DB storage)
3. **Deployment manifests**:
   - MySQL
   - RabbitMQ
   - Memcache
   - Tomcat
4. **Service manifests**:
   - MySQL
   - RabbitMQ
   - Memcache
   - Tomcat
5. **Ingress manifest** (route external traffic)

---

## 🔑 Final Flow

1. User hits → `vprofile.infotech.com` (GoDaddy DNS)
2. Request goes → AWS ALB (created by Ingress Controller)
3. Ingress Rule forwards → Tomcat Service
4. Tomcat Pod communicates internally with DB, RabbitMQ, Memcache via ClusterIP Services
5. DB Pod stores data → Persistent Volume Claim → EBS Volume

🎉 Result: **Highly available, fault tolerant, auto-healing, production-ready web app!**

---

## ✅ What You Need Before Proceeding
- Kubernetes cluster (via Kops)
- Docker images (Tomcat, MySQL, Nginx, RabbitMQ, Memcache)
- AWS EBS for persistent storage
- Domain (GoDaddy) + Route53 for DNS

---

👉 In the next steps, you’ll actually **write Kubernetes definition files** and deploy all components step by step!

