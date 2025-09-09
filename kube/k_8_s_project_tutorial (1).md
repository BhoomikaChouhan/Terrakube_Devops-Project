# Kubernetes Multi-Tier Project Tutorial

Yeh tutorial tumhe step by step guide karega ek multi-tier project banane ke liye Kubernetes par. Har ek transcript ke saare steps cover kiye gaye hain, kuch bhi miss nahi hua hai. Chal shuru karte hain:

---

## 1. Source Code Overview
- Source code GitHub repo: `github.com/coder/profile-project`
- Branches:
  - `cube-app` (abhi ke liye use karna hai)
  - `skele-cube` (next lecture mein skeleton files likhne ke liye)
- `cube-app` branch ke andar:
  - `cube-devs` folder jisme sabhi Kubernetes manifests hain.
  - Files include: Dockerfile, docker-compose.yml, aur manifests.
- Clone karna:
  1. GitHub repo kholkar HTTPS clone link copy karo.
  2. VS Code → Source Control → Clone Repository.
  3. URL paste karo → Location select karo (e.g., `F:/CubeApp`).
  4. Branch switch karo: `cube-app`.
- VS Code mein Kubernetes extension install karo (ignore kubectl error abhi).
- Architecture overview:
  - 1 Secret (DB & RabbitMQ password ke liye)
  - 1 PVC (3GB storage ke liye)
  - Deployments: Tomcat App, MySQL DB, RabbitMQ, Memcache
  - Services: ClusterIP type for internal communication
  - Ingress: external communication ke liye Nginx ingress controller

---

## 2. Secrets
- Passwords ko source code mein directly store karna unsafe hota hai.
- Kubernetes `Secret` object use karte hain encoded values store karne ke liye (Base64 encoding).
- Example encode command:
  ```bash
echo -n "propass" | base64
# Output: cHJvcGFzcw==

echo -n "guest" | base64
# Output: Z3Vlc3Q=
```
- Secret YAML (`secret.yaml`):
  ```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: app-secret
  type: Opaque
  data:
    db-pass: cHJvcGFzcw==
    rmq-pass: Z3Vlc3Q=
  ```

---

## 3. Persistent Volume Claim (PVC)
- DB data ko persist karne ke liye PVC use karenge.
- Default storage class (AWS EBS) available hai COPS cluster ke saath.
- PVC YAML (`db-pvc.yaml`):
  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: db-pv-claim
    labels:
      app: wipro-db
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 3Gi
    storageClassName: default
  ```

---

## 4. MySQL Deployment
- DB deployment mein secret aur PVC dono use honge.
- Deployment YAML (`db-deploy.yaml`):
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: wipro-db
    labels:
      app: wipro-db
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: wipro-db
    template:
      metadata:
        labels:
          app: wipro-db
      spec:
        containers:
        - name: wipro-db
          image: wiprocontainer/vprofiledb
          ports:
          - name: db-port
            containerPort: 3306
          env:
          - name: MYSQL_ROOT_PASSWORD
            valueFrom:
              secretKeyRef:
                name: app-secret
                key: db-pass
          volumeMounts:
          - mountPath: /var/lib/mysql
            name: db-data
        volumes:
        - name: db-data
          persistentVolumeClaim:
            claimName: db-pv-claim
        initContainers:
        - name: busybox
          image: busybox:latest
          command: ["rm", "-rf", "/var/lib/mysql/lost+found"]
          volumeMounts:
          - mountPath: /var/lib/mysql
            name: db-data
  ```

---

## 5. MySQL Service
- Internal communication ke liye ClusterIP service.
- Service YAML (`db-service.yaml`):
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: wipro-db
  spec:
    selector:
      app: wipro-db
    ports:
    - port: 3306
      targetPort: db-port
    type: ClusterIP
  ```

---

## 6. Memcache Deployment + Service
- Deployment YAML (`memcache-deploy.yaml`):
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: wipro-mc
    labels:
      app: wipro-mc
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: wipro-mc
    template:
      metadata:
        labels:
          app: wipro-mc
      spec:
        containers:
        - name: wipro-mc
          image: memcached
          ports:
          - name: mc-port
            containerPort: 11211
  ```

- Service YAML (`memcache-service.yaml`):
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: wipro-cache01
  spec:
    selector:
      app: wipro-mc
    ports:
    - port: 11211
      targetPort: mc-port
    type: ClusterIP
  ```

---

## 7. RabbitMQ Deployment + Service
- Deployment YAML (`rabbitmq-deploy.yaml`):
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: wipro-mq
    labels:
      app: wipro-mq
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: wipro-mq
    template:
      metadata:
        labels:
          app: wipro-mq
      spec:
        containers:
        - name: wipro-mq
          image: rabbitmq
          ports:
          - name: rmq-port
            containerPort: 5672
          env:
          - name: RABBITMQ_DEFAULT_USER
            value: guest
          - name: RABBITMQ_DEFAULT_PASS
            valueFrom:
              secretKeyRef:
                name: app-secret
                key: rmq-pass
  ```

- Service YAML (`rabbitmq-service.yaml`):
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: wipro-mq
  spec:
    selector:
      app: wipro-mq
    ports:
    - port: 5672
      targetPort: rmq-port
    type: ClusterIP
  ```

---

## Next Steps
- Tomcat (App) Deployment & Service likhna hai.
- Ingress setup karna hai external communication ke liye.
- Saare pods ko architecture diagram ke hisaab se connect karna hai.

---

⚡ Ab tak ke steps complete karne ke baad tumhare paas DB, Memcache aur RabbitMQ services ready ho jayenge. Next lecture mein Tomcat App aur Ingress setup karenge.

