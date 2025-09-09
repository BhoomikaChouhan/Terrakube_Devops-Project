# 🌟 Tutorial: AWS par Kubernetes Cluster setup with Kops (Cost-Friendly Setup)

---

## 🛠️ Step 1: Prerequisites (Bina ye kare to game start hi nahi hoga)

1. **Domain**: Aapke paas ek domain hona chahiye (jaise GoDaddy se kharida hua).

   - Example: `hcinfotech.xyz`
   - Is domain ka use hoga **Kubernetes DNS records** ke liye.

2. **Linux VM (Base Machine)**

   - Ye cluster ka part nahi hoga, sirf ek *control room* ki tarah kaam karega.
   - Yaha pe hum install karenge:
     - **kops**
     - **kubectl**
     - **aws cli**
     - Generate karenge **SSH keys**

   Options:

   - Vagrant VM use kar sakte ho
   - Ya phir **AWS EC2 instance** (yahi hum karenge).

3. **AWS Resources Needed**:

   - **IAM User** with **Administrator Access** (kyunki Kops bohot services ko touch karega: VPC, EC2, S3, Route53).
   - **S3 Bucket** → jisme cluster ka state store hoga.
   - **Route53 Hosted Zone** → Subdomain ke liye.

---

## 💻 Step 2: EC2 Instance Launch for Kops

1. AWS Console → Region: **N. Virginia (us-east-1)**
2. EC2 → **Launch Instance**
   - Name: `kops`
   - AMI: `Ubuntu 24` (Free Tier eligible)
   - Instance Type: `t2.micro`
   - Key Pair: Create new → `kops-key.pem`
   - Security Group: `kops-SG` → Allow SSH (22) from My IP only.
3. Launch instance 🎉

👉 Ye instance cluster ka part nahi hai, sirf commands execute karne ke liye hai.

---

## 🛡️ Step 3: IAM User Setup for Kops

1. AWS Console → IAM → Users → **Create User**
   - Name: `kops-admin`
   - Attach Policy: **AdministratorAccess**
2. Create user → Generate **Access Keys** for CLI.
3. Download CSV / copy keys.

---

## 🔑 Step 4: SSH into Kops Instance

```bash
ssh -i /path/to/kops-key.pem ubuntu@<EC2-Public-IP>
```

Switch to root:

```bash
sudo -i
```

Update system:

```bash
apt update
```

---

## 📆 Step 5: Install AWS CLI & Configure

Install AWS CLI:

```bash
snap install aws-cli --classic
```

Configure CLI:

```bash
aws configure
```

- Access Key ID: (IAM user ka access key)
- Secret Access Key: (IAM user ka secret)
- Region: `us-east-1`
- Output format: `json`

---

## 🔑 Step 6: Generate SSH Keys

```bash
ssh-keygen
```

👉 Multiple `enter` daba do, keys ban jayengi:

- Public Key → `~/.ssh/id_rsa.pub`
- Private Key → `~/.ssh/id_rsa`

---

## 📅 Step 7: Install Kops

```bash
curl -LO https://github.com/kubernetes/kops/releases/latest/download/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops
```

Check installation:

```bash
kops version
```

---

## 📅 Step 8: Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
kubectl version --client
```

---

## 🪣 Step 9: Create S3 Bucket for Cluster State

```bash
aws s3 mb s3://kops-state-<unique-id>
```

(Unique ID add karo warna error ayega)

---

## 🌍 Step 10: Setup Route53 Hosted Zone

1. AWS Console → Route 53 → Hosted Zones → **Create Hosted Zone**

   - Name: `kube.yourdomain.com`
   - Type: Public Hosted Zone

2. Ye Hosted Zone aapko 4 **Name Servers (NS Records)** dega.

3. GoDaddy (or domain registrar) → Add DNS Records:

   - Record Type: NS
   - Name: `kube`
   - Values: Route53 se diye gaye 4 NS servers.

👉 Matlab:

- `yourdomain.com` GoDaddy par hai.
- `kube.yourdomain.com` Route53 pe manage hoga.

---

## ⚡ Step 11: Create Kubernetes Cluster with Kops

Command:

```bash
kops create cluster \
  --name=kube.yourdomain.com \
  --state=s3://kops-state-<unique-id> \
  --zones=us-east-1a,us-east-1b \
  --node-count=2 \
  --node-size=t3.small \
  --master-size=t3.medium \
  --node-volume-size=12 \
  --master-volume-size=12 \
  --ssh-public-key=~/.ssh/id_rsa.pub
```

Apply config:

```bash
kops update cluster --name=kube.yourdomain.com --state=s3://kops-state-<unique-id> --yes
```

👉 Ye process \~15 min lega. Coffee pe lo ☕.

---

## ✅ Step 12: Validate Cluster

```bash
kops validate cluster --name=kube.yourdomain.com --state=s3://kops-state-<unique-id>
```

If success: `"Cluster is ready"` 🎉

---

## 🧑‍💻 Step 13: Test with kubectl

Check nodes:

```bash
kubectl get nodes
```

👉 Output: 1 master + 2 worker nodes.

Check kube config:

```bash
cat ~/.kube/config
```

---

## 🔍 Step 14: Verify DNS in Route53

- Hosted Zone → Check record:
  - `api.kube.yourdomain.com` → Public IP of Master Node
  - `api.internal.kube.yourdomain.com` → Private IP of Master Node

---

## 🗑️ Step 15: Delete Cluster (Cost Saving 💸)

Jab use nahi ho:

```bash
kops delete cluster --name=kube.yourdomain.com --state=s3://kops-state-<unique-id> --yes
```

---

# 🎯 Summary

1. Domain setup → Subdomain in Route53
2. EC2 base machine → Install AWS CLI, kops, kubectl
3. IAM user + S3 bucket + Hosted Zone ready
4. Run `kops create cluster` → Apply with `kops update cluster`
5. Validate cluster with `kops validate cluster`
6. Manage cluster with kubectl
7. Delete cluster to save money

