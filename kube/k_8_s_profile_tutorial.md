# Kubernetes Multi-Service App Tutorial (Funny + Hands-On)

Arre doston! 😎 Swagat hai aapka is **Kubernetes masala project tutorial** me, jaha hum ek multi-service application ko cluster me deploy karne wale hain. Poora step-by-step, bina kuch miss kiye, ekdum hands-on style me. Toh chhodo boring theory aur shuru karte hain mazaak-mazaak me seekhna. 🚀

---

## 1. Source Code Overview

- Open repo:
  ```
  github.com/coder/profile-project
  ```
- Branch select karo: **cube-app**
- Ek aur branch hai: **skel-cube** (ye skeleton files hain, jisme hum likhenge). 😏
- Repo me folder: **kube-devs** → yahi pe sari YAML files hain.

### Clone Repo:

- VS Code open karo → Source Control → Clone Repo
- HTTPS URL paste karo → Save in F: drive (ya jaha mann kare)
- Branch switch: **cube-app**

### Install Extension:

- VS Code → Extensions → Search **Kubernetes** → Install
- Kubectl error ignore karo filhal. 😜

---

## 2. Secret Banana (Passwords Safe Rakhna!)

Password clear text me daalna = 😱 ghatiya practice.

### Docker Compose Reference:

- MySQL ko chahiye `MYSQL_ROOT_PASSWORD`
- RabbitMQ ko chahiye `RABBITMQ_DEFAULT_PASS`

### Solution: **Kubernetes Secret (Opaque type)**

#### Encode Password:

```bash
echo -n "probpass" | base64   # DB ka password
echo -n "guest" | base64     # RabbitMQ ka password
```

#### Secret YAML:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  db-pass: cHJvYnBhc3M=   # encoded probpass
  rmq-pass: Z3Vlc3Q=      # encoded guest
```

Save as: `secret.yaml`

---

## 3. Persistent Volume Claim (PVC)

Database ka data safe rehna chahiye → Pod delete ho jaye to bhi data na ude. 💾

#### PVC YAML:

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

Save as: `db-pvc.yaml`

---

## 4. MySQL Deployment (DB)

Deployment ka kaam = agar pod down ho gaya → dobara create karo. 😎

#### Deployment YAML:

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

Tomcat app ko DB ke IP kaise milega? → Service banate hain! ⚡

#### Service YAML:

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

Save as: `db-service.yaml`

---

## 6. Memcache Deployment + Service

### Deployment:

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

### Service:

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

### Deployment:

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
            - name: mq-port
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

### Service:

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
      targetPort: mq-port
  type: ClusterIP
```

---

## 8. Tomcat App (Wipro App)

Same funda → Deployment + Service banayenge. App ko DB, Memcache, RabbitMQ se connect karna hai jo abhi services ke naam se milenge. 👌

(YAML skeleton aapke cube-app branch me milega → bas service names aur environment variables match karne hain.)

---

## 9. Ingress (Frontend Access)

- Saare services internal hain (ClusterIP).
- External user kaise access kare? → Ingress + LoadBalancer.

Ingress rule: agar user `wiproapp.com` hit kare → route request to `wipro-app-service`.

Ingress controller: **Nginx** use karenge.

---

## Recap (Shortcut in Bhoomika Mnemonic Style 😄)

**S-P-D-S-M-R-T-I** = Project ke steps:

- **S**ecret
- **P**VC
- **D**eployment (DB)
- **S**ervice (DB)
- **M**emcache setup
- **R**abbitMQ setup
- **T**omcat App
- **I**ngress

Ho gaya pura cluster setup ready! 🎉

---

👉 Next step: `kubectl apply -f` har file ke liye run karo aur tumhara app cluster me chal jayega ekdum bindaas. 🔥

