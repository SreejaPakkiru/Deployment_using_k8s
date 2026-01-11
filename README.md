# Cloud Native Application Deployment: Docker Compose → Amazon EKS

## 📌 Project Overview

This capstone project demonstrates the complete migration of a containerized Node.js application from a simple Docker Compose setup on EC2 to a **production-grade Amazon EKS (Elastic Kubernetes Service)** infrastructure using **Terraform** and **Kubernetes**.

### Application Stack
- **Backend**: Node.js (Express) web application
- **Database**: Redis (for session/visit counting)
- **Load Balancer**: NGINX reverse proxy
- **Container Registry**: Amazon ECR
- **Infrastructure**: AWS (VPC, EKS, EC2, NLB/ALB)
- **IaC Tool**: Terraform
- **Orchestration**: Kubernetes

---

## 🎯 Project Goals

✅ Convert Docker Compose services to Kubernetes resources  
✅ Provision production-grade AWS infrastructure using Terraform  
✅ Implement auto-scaling (Horizontal Pod Autoscaler + Cluster Autoscaler)  
✅ Enable high availability with multi-AZ deployment  
✅ Demonstrate ECR → EKS deployment workflow  
✅ Apply production best practices (security, monitoring, IaC)  

---

## 📁 Repository Structure

```
.
├── k8s/                              # Kubernetes Manifests
│   ├── namespace.yaml                # Application namespace
│   ├── redis-deployment.yaml         # Redis database
│   ├── web-deployment.yaml           # Node.js app (3-10 replicas)
│   ├── nginx-configmap.yaml          # NGINX configuration
│   ├── nginx-deployment.yaml         # NGINX load balancer
│   ├── ingress.yaml                  # ALB Ingress (optional)
│   └── hpa.yaml                      # Horizontal Pod Autoscaler
│
├── terraform-eks/                    # Terraform Infrastructure Code
│   ├── provider.tf                   # AWS provider configuration
│   ├── variables.tf                  # Input variables
│   ├── vpc.tf                        # VPC with 3 AZs, NAT, VPC endpoints
│   ├── eks-cluster.tf                # EKS cluster, node groups, IRSA
│   ├── eks-addons.tf                 # ALB controller, metrics, autoscaler
│   ├── ecr.tf                        # ECR repository setup
│   ├── outputs.tf                    # Infrastructure outputs
│   └── terraform-backend-setup.tf    # S3 + DynamoDB backend
│
├── web/                              # Node.js Application
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
├── nginx/                            # NGINX Proxy
│   ├── Dockerfile
│   └── nginx.conf
│
├── terraform/                        # Legacy EC2 Terraform (reference)
├── tests/                            # Integration tests
│
├── deploy-eks.sh                     # Automated deployment script
├── update-app.sh                     # Application update script
├── cleanup-eks.sh                    # Resource cleanup script
│
├── EKS-DEPLOYMENT-GUIDE.md          # Complete deployment guide
├── ARCHITECTURE-COMPARISON.md        # Before/After comparison
├── compose.yaml                      # Original Docker Compose setup
└── README.md                         # This file
```

---

## 🏗️ Architecture

### Current EKS Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS Cloud (ap-south-1)                     │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                         │  │
│  │                                                              │  │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐               │  │
│  │  │  AZ-1a    │  │  AZ-1b    │  │  AZ-1c    │               │  │
│  │  │ (Public + │  │ (Public + │  │ (Public + │               │  │
│  │  │  Private) │  │  Private) │  │  Private) │               │  │
│  │  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘               │  │
│  │        │              │              │                       │  │
│  │  ┌─────▼──────────────▼──────────────▼─────┐               │  │
│  │  │         EKS Cluster (Kubernetes)         │               │  │
│  │  │                                           │               │  │
│  │  │  ┌─────────────────────────────────────┐ │               │  │
│  │  │  │  NGINX (2 pods) → LoadBalancer     │ │               │  │
│  │  │  └─────────────┬───────────────────────┘ │               │  │
│  │  │                │                          │               │  │
│  │  │  ┌─────────────▼───────────────────────┐ │               │  │
│  │  │  │  Web App (3-10 pods) with HPA      │ │               │  │
│  │  │  └─────────────┬───────────────────────┘ │               │  │
│  │  │                │                          │               │  │
│  │  │  ┌─────────────▼───────────────────────┐ │               │  │
│  │  │  │  Redis (1 pod) - Database          │ │               │  │
│  │  │  └─────────────────────────────────────┘ │               │  │
│  │  │                                           │               │  │
│  │  │  Managed Node Group: 2-6 EC2 instances  │               │  │
│  │  └───────────────────────────────────────────┘               │  │
│  │                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Amazon ECR: 954692414134.dkr.ecr.ap-south-1...             │  │
│  │  • capstone-repo:web-latest                                 │  │
│  │  • capstone-repo:nginx-latest                               │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**See [ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md) for detailed before/after comparison**

---

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- kubectl >= 1.28
- Docker (for building images)

### Deploy Infrastructure

```bash
# 1. Clone repository
git clone <repository-url>
cd Deployment_using_k8s

# 2. Setup Terraform backend (one-time)
cd terraform-eks
terraform init
terraform apply -target=aws_s3_bucket.terraform_state
terraform apply -target=aws_dynamodb_table.terraform_state_lock

# 3. Deploy EKS cluster
terraform init -migrate-state
terraform plan
terraform apply

# 4. Configure kubectl
aws eks update-kubeconfig --region ap-south-1 --name capstone-eks-cluster
kubectl get nodes
```

### Deploy Application

```bash
# 5. Push images to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 954692414134.dkr.ecr.ap-south-1.amazonaws.com

cd ../web
docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-latest .
docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-latest

cd ../nginx
docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-latest .
docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-latest

# 6. Deploy to Kubernetes
cd ..
kubectl apply -f k8s/

# 7. Get application URL
kubectl get svc nginx-service -n capstone-app
```

**For detailed step-by-step instructions, see [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md)**

---

## 🔄 Deployment Flow

```
┌─────────────────┐
│  1. Terraform   │  Provision VPC, EKS cluster, node groups
│   Provision    │  Install add-ons (ALB controller, metrics)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  2. CI/CD       │  Build Docker images
│   Build         │  Push to Amazon ECR
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  3. Kubernetes  │  Apply manifests (Deployments, Services)
│   Deploy        │  kubectl apply -f k8s/
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  4. EKS Nodes   │  Pull images from ECR (via IAM role)
│   Pull Images   │  Start containers in pods
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  5. Application │  Pods running across multiple nodes
│   Running       │  LoadBalancer exposes application
└─────────────────┘
```

### How ECR Images Deploy to EKS

1. **Build Phase**: CI/CD builds images and tags them
2. **Push to ECR**: Images pushed to Amazon ECR repository
3. **Kubernetes Manifest**: References ECR image URL
4. **Node IAM Role**: EKS nodes have IAM permissions to pull from ECR (via IRSA)
5. **Image Pull**: kubelet authenticates to ECR using node credentials
6. **Container Start**: Container runtime (containerd) pulls and runs the image

**Example Deployment Update:**
```bash
# Update to new version
kubectl set image deployment/web-app \
  web-app=954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-v2.0 \
  -n capstone-app

# Rolling update automatically happens with zero downtime
kubectl rollout status deployment/web-app -n capstone-app
```

---

## 📊 Key Features

### Production-Ready Infrastructure

✅ **High Availability**
- Multi-AZ deployment (3 availability zones)
- Self-healing pods (automatic restart on failure)
- LoadBalancer with health checks

✅ **Auto-Scaling**
- Horizontal Pod Autoscaler (3-10 pods based on CPU/memory)
- Cluster Autoscaler (2-6 nodes based on demand)
- Metrics-driven scaling decisions

✅ **Security**
- IRSA (IAM Roles for Service Accounts) for pod-level permissions
- Private subnets for worker nodes
- VPC endpoints for ECR (no internet routing)
- Security groups with least privilege
- Encrypted secrets at rest

✅ **Zero-Downtime Deployments**
- Rolling updates with maxSurge/maxUnavailable controls
- Health probes (liveness + readiness)
- Automatic rollback on failure

✅ **Infrastructure as Code**
- Complete Terraform modules for reproducibility
- Version-controlled infrastructure
- Multi-environment support (via workspaces)

✅ **Monitoring & Observability**
- Metrics Server for resource metrics
- CloudWatch Container Insights integration
- Cluster-wide logging capability
- HPA and Cluster Autoscaler metrics

---

## 🔐 Security Highlights

| Feature | Implementation |
|---------|----------------|
| **Network Isolation** | Private subnets, security groups, Network Policies |
| **IAM Best Practices** | IRSA for pod-level permissions, no hardcoded credentials |
| **Image Security** | ECR automatic vulnerability scanning |
| **Secrets Management** | Kubernetes Secrets, can integrate AWS Secrets Manager |
| **Encryption** | EBS encryption, secrets encrypted at rest |
| **Access Control** | Kubernetes RBAC, IAM authentication to cluster |
| **Compliance** | IMDSv2 enforced, pod security standards ready |

---

## 💰 Cost Estimate

### Production Setup (~$293/month)

| Resource | Monthly Cost |
|----------|--------------|
| EKS Control Plane | $73 |
| EC2 Nodes (3 x t3.medium) | $95 |
| NAT Gateways (3 AZ) | $97 |
| Network Load Balancer | $22 |
| EBS Volumes | $6 |

### Development Optimizations

- Use single NAT Gateway: **Save $65/month**
- Use t3.small instances: **Save $47/month**
- Use Spot Instances: **Save up to 70%**

**Optimized dev cost: ~$150/month**

---

## 🛠️ Useful Commands

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# View all resources
kubectl get all -n capstone-app

# Check pod logs
kubectl logs -f deployment/web-app -n capstone-app

# View HPA status
kubectl get hpa -n capstone-app

# Update application
./update-app.sh v2.0

# Scale manually (if needed)
kubectl scale deployment web-app --replicas=5 -n capstone-app

# Delete everything
./cleanup-eks.sh
```

---

## 📚 Documentation

- **[EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md)**: Complete deployment guide with architecture diagrams, step-by-step instructions, troubleshooting, and best practices
- **[ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md)**: Detailed comparison of Docker Compose vs EKS architectures, benefits, and migration guide

---

## 🎓 Learning Outcomes

This project demonstrates:

1. **Cloud Architecture**: Designing multi-AZ, highly available systems on AWS
2. **Infrastructure as Code**: Managing infrastructure with Terraform
3. **Container Orchestration**: Kubernetes concepts (Deployments, Services, ConfigMaps, HPA)
4. **AWS Services**: EKS, ECR, VPC, NLB, IAM
5. **DevOps Practices**: CI/CD integration, GitOps, automated deployments
6. **Production Operations**: Scaling, monitoring, security, cost optimization
7. **Problem Solving**: Migrating from development setup to production-grade infrastructure

---

## 🔗 Technologies Used

- **Container**: Docker, containerd
- **Orchestration**: Kubernetes 1.28
- **Cloud**: AWS (EKS, ECR, VPC, EC2, NLB/ALB)
- **IaC**: Terraform 1.6+
- **CI/CD**: GitHub Actions (example provided)
- **Monitoring**: Metrics Server, CloudWatch
- **Language**: Node.js, Bash

---

## 👨‍💻 Author

**Capstone Project - Production EKS Deployment**

Demonstrating enterprise-grade cloud infrastructure, container orchestration, and DevOps best practices.

---

## 📄 License

This project is for educational purposes as part of a DevOps capstone demonstration.

---

## 🙏 Acknowledgments

- AWS EKS Best Practices Guide
- Kubernetes Official Documentation
- Terraform AWS Provider Documentation
- HashiCorp Learn Tutorials
 








