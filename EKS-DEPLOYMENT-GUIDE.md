# Production-Grade EKS Deployment - Capstone Project

## 🎯 Project Overview

This project demonstrates the migration of a containerized Node.js application from Docker Compose on EC2 to a production-grade AWS EKS (Elastic Kubernetes Service) infrastructure using Terraform and Kubernetes.

### Architecture Evolution

**Before (Docker Compose on EC2):**
- Single EC2 instance
- Docker Compose orchestration
- Manual scaling
- Limited high availability

**After (EKS Production Setup):**
- Managed Kubernetes cluster (EKS)
- Auto-scaling (HPA & Cluster Autoscaler)
- Multi-AZ deployment
- Infrastructure as Code (Terraform)
- Production-grade monitoring and security

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS Cloud (ap-south-1)                     │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                        VPC (10.0.0.0/16)                     │  │
│  │                                                              │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │  │
│  │  │   AZ-1a     │  │   AZ-1b     │  │   AZ-1c     │         │  │
│  │  │             │  │             │  │             │         │  │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │         │  │
│  │  │ │ Public  │ │  │ │ Public  │ │  │ │ Public  │ │         │  │
│  │  │ │ Subnet  │ │  │ │ Subnet  │ │  │ │ Subnet  │ │         │  │
│  │  │ └────┬────┘ │  │ └────┬────┘ │  │ └────┬────┘ │         │  │
│  │  │      │      │  │      │      │  │      │      │         │  │
│  │  │   [NAT]    │  │   [NAT]    │  │   [NAT]    │         │  │
│  │  │      │      │  │      │      │  │      │      │         │  │
│  │  │ ┌────▼────┐ │  │ ┌────▼────┐ │  │ ┌────▼────┐ │         │  │
│  │  │ │ Private │ │  │ │ Private │ │  │ │ Private │ │         │  │
│  │  │ │ Subnet  │ │  │ │ Subnet  │ │  │ │ Subnet  │ │         │  │
│  │  │ │         │ │  │ │         │ │  │ │         │ │         │  │
│  │  │ │ [Nodes] │ │  │ │ [Nodes] │ │  │ │ [Nodes] │ │         │  │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │         │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘         │  │
│  │                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    EKS Cluster Components                    │  │
│  │                                                              │  │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │  │
│  │  │   NGINX      │───▶│   Web App    │───▶│    Redis     │  │  │
│  │  │  (2 pods)    │    │  (3+ pods)   │    │   (1 pod)    │  │  │
│  │  │ LoadBalancer │    │   with HPA   │    │  StatefulSet │  │  │
│  │  └──────┬───────┘    └──────────────┘    └──────────────┘  │  │
│  │         │                                                   │  │
│  │    [NLB/ALB]                                               │  │
│  │         │                                                   │  │
│  └─────────┼───────────────────────────────────────────────────┘  │
│            │                                                       │
│  ┌─────────▼───────────────────────────────────────────────────┐  │
│  │                  Amazon ECR Repository                      │  │
│  │  • capstone-repo:web-latest                                │  │
│  │  • capstone-repo:nginx-latest                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                             │
                             │ CI/CD Pipeline
                             │
                    ┌────────▼─────────┐
                    │  Build & Push    │
                    │  Docker Images   │
                    └──────────────────┘
```

---

## 📦 Project Structure

```
.
├── k8s/                              # Kubernetes manifests
│   ├── namespace.yaml                # Namespace for isolation
│   ├── redis-deployment.yaml         # Redis database
│   ├── web-deployment.yaml           # Node.js web application
│   ├── nginx-configmap.yaml          # NGINX configuration
│   ├── nginx-deployment.yaml         # NGINX load balancer
│   ├── ingress.yaml                  # ALB Ingress (optional)
│   └── hpa.yaml                      # Horizontal Pod Autoscaler
│
├── terraform-eks/                    # Terraform infrastructure
│   ├── provider.tf                   # Provider configuration
│   ├── variables.tf                  # Input variables
│   ├── vpc.tf                        # VPC with 3 AZs
│   ├── eks-cluster.tf                # EKS cluster & node groups
│   ├── eks-addons.tf                 # Cluster addons (ALB, metrics, autoscaler)
│   ├── ecr.tf                        # ECR repository
│   ├── outputs.tf                    # Output values
│   └── terraform-backend-setup.tf    # Backend S3 & DynamoDB setup
│
├── deploy-eks.sh                     # Automated deployment script
├── update-app.sh                     # Application update script
├── cleanup-eks.sh                    # Cleanup script
│
├── web/                              # Node.js application
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
├── nginx/                            # NGINX proxy
│   ├── Dockerfile
│   └── nginx.conf
│
└── compose.yaml                      # Original Docker Compose (reference)
```

---

## 🔄 Deployment Flow

### Complete Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PHASE 1: Infrastructure                         │
└─────────────────────────────────────────────────────────────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Terraform Init/Plan   │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │   Create VPC (3 AZs)   │
                  │   - Public Subnets     │
                  │   - Private Subnets    │
                  │   - NAT Gateways       │
                  │   - VPC Endpoints      │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Provision EKS Cluster │
                  │   - Control Plane      │
                  │   - Node Groups (2-6)  │
                  │   - IAM Roles (IRSA)   │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │   Install Add-ons      │
                  │   - ALB Controller     │
                  │   - Metrics Server     │
                  │   - Cluster Autoscaler │
                  │   - EBS CSI Driver     │
                  └───────────┬────────────┘
                              │
┌─────────────────────────────▼─────────────────────────────────────────┐
│                     PHASE 2: Application Build                       │
└───────────────────────────────────────────────────────────────────────┘
                              │
                  ┌───────────▼────────────┐
                  │   CI/CD Pipeline       │
                  │   (GitHub Actions/     │
                  │    Jenkins/GitLab)     │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Build Docker Images   │
                  │   - web:latest         │
                  │   - nginx:latest       │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Push to Amazon ECR    │
                  │  954692414134.dkr.ecr  │
                  │  .ap-south-1...        │
                  └───────────┬────────────┘
                              │
┌─────────────────────────────▼─────────────────────────────────────────┐
│                  PHASE 3: Kubernetes Deployment                      │
└───────────────────────────────────────────────────────────────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  kubectl apply         │
                  │  - Namespace           │
                  │  - ConfigMaps          │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Deploy Redis          │
                  │  (StatefulSet)         │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Deploy Web App        │
                  │  (Deployment: 3 pods)  │
                  │  Pull from ECR         │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Deploy NGINX          │
                  │  (Deployment: 2 pods)  │
                  │  Create LoadBalancer   │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Configure HPA         │
                  │  (Auto-scaling 3-10)   │
                  └───────────┬────────────┘
                              │
┌─────────────────────────────▼─────────────────────────────────────────┐
│                    PHASE 4: Access & Monitor                         │
└───────────────────────────────────────────────────────────────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Get LoadBalancer URL  │
                  │  (NLB/ALB endpoint)    │
                  └───────────┬────────────┘
                              │
                  ┌───────────▼────────────┐
                  │  Application Live!     │
                  │  http://<LB-URL>       │
                  └────────────────────────┘
```

---

## 🚀 Deployment Steps

### Prerequisites

Install required tools:

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Configure AWS credentials
aws configure
```

### Step 1: Setup Terraform Backend (One-time)

```bash
cd terraform-eks

# Create S3 bucket and DynamoDB table for state management
terraform init
terraform apply -target=aws_s3_bucket.terraform_state
terraform apply -target=aws_dynamodb_table.terraform_state_lock

# Update provider.tf with your bucket name
# Then re-initialize with backend
terraform init -migrate-state
```

### Step 2: Deploy Infrastructure

```bash
# Option A: Use automated script
chmod +x deploy-eks.sh
./deploy-eks.sh

# Option B: Manual deployment
cd terraform-eks
terraform init
terraform plan
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region ap-south-1 --name capstone-eks-cluster
```

### Step 3: Build and Push Images to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region ap-south-1 | \
    docker login --username AWS --password-stdin \
    954692414134.dkr.ecr.ap-south-1.amazonaws.com

# Build and push web application
cd web
docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-latest .
docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-latest

# Build and push nginx
cd ../nginx
docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-latest .
docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-latest
```

### Step 4: Deploy Application to EKS

```bash
# Deploy all Kubernetes resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/web-deployment.yaml
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/hpa.yaml

# Verify deployment
kubectl get all -n capstone-app

# Wait for LoadBalancer to be provisioned
kubectl get svc nginx-service -n capstone-app -w
```

### Step 5: Access Application

```bash
# Get the LoadBalancer URL
export LB_URL=$(kubectl get svc nginx-service -n capstone-app \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Application URL: http://$LB_URL"

# Test the application
curl http://$LB_URL
```

---

## 🔐 Security Features

### 1. **Network Security**
- Private subnets for EKS nodes
- NAT Gateways for outbound internet access
- Security groups with least privilege
- VPC endpoints for AWS services (no internet routing)

### 2. **IAM Security**
- IRSA (IAM Roles for Service Accounts) for pod-level permissions
- Separate roles for:
  - EKS nodes
  - ALB Controller
  - Cluster Autoscaler
  - EBS CSI Driver
- IMDSv2 enforced on nodes

### 3. **Container Security**
- ECR image scanning enabled
- Image immutability (can be enabled)
- Lifecycle policies for image cleanup
- Private ECR access via VPC endpoints

### 4. **Cluster Security**
- EKS managed control plane (auto-patched)
- Encrypted secrets at rest
- API server endpoint access control
- Pod Security Standards (can be enforced)

---

## 📊 High Availability & Scaling

### Horizontal Pod Autoscaler (HPA)

The web application automatically scales based on CPU and memory:

```yaml
Metrics:
- CPU: Scale when average > 70%
- Memory: Scale when average > 80%

Scale Range:
- Minimum: 3 pods
- Maximum: 10 pods

Scale-up Policy:
- Add 100% of current pods or 2 pods (whichever is higher)
- React immediately (0s stabilization)

Scale-down Policy:
- Remove 50% of pods
- Wait 5 minutes before scaling down (stabilization)
```

### Cluster Autoscaler

Node group automatically scales from 2 to 6 nodes based on pod resource requests.

### Multi-AZ Deployment

- **3 Availability Zones**: ap-south-1a, ap-south-1b, ap-south-1c
- Pods distributed across zones
- NAT Gateway in each AZ
- Survives single AZ failure

---

## 🔄 CI/CD Integration

### Example GitHub Actions Workflow

```yaml
name: Deploy to EKS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-south-1
      
      - name: Login to ECR
        run: |
          aws ecr get-login-password --region ap-south-1 | \
          docker login --username AWS --password-stdin \
          954692414134.dkr.ecr.ap-south-1.amazonaws.com
      
      - name: Build and push images
        run: |
          docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-${{ github.sha }} ./web
          docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-${{ github.sha }}
          
          docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-${{ github.sha }} ./nginx
          docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-${{ github.sha }}
      
      - name: Update EKS deployment
        run: |
          aws eks update-kubeconfig --region ap-south-1 --name capstone-eks-cluster
          kubectl set image deployment/web-app \
            web-app=954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-${{ github.sha }} \
            -n capstone-app
          kubectl set image deployment/nginx \
            nginx=954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-${{ github.sha }} \
            -n capstone-app
```

---

## 📈 Monitoring & Observability

### CloudWatch Container Insights

Enable Container Insights for cluster monitoring:

```bash
aws eks update-cluster-config \
    --region ap-south-1 \
    --name capstone-eks-cluster \
    --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```

### Metrics Server

Already installed via Terraform for HPA:

```bash
kubectl top nodes
kubectl top pods -n capstone-app
```

### Useful Monitoring Commands

```bash
# View pod logs
kubectl logs -f deployment/web-app -n capstone-app

# View HPA status
kubectl get hpa -n capstone-app

# View cluster autoscaler logs
kubectl logs -f deployment/cluster-autoscaler -n kube-system

# View all events
kubectl get events -n capstone-app --sort-by='.lastTimestamp'
```

---

## 💰 Cost Optimization

### Current Setup Costs (Estimated)

| Resource | Monthly Cost (USD) |
|----------|-------------------|
| EKS Cluster | ~$73 |
| EC2 Nodes (3 x t3.medium) | ~$95 |
| NAT Gateways (3 x AZ) | ~$97 |
| Network Load Balancer | ~$22 |
| EBS Volumes | ~$6 |
| **Total** | **~$293/month** |

### Cost Optimization Strategies

1. **Use Single NAT Gateway** (Development):
   ```hcl
   single_nat_gateway = true  # Save ~$65/month
   ```

2. **Use Spot Instances** (Non-production):
   ```hcl
   capacity_type = "SPOT"  # Save up to 70%
   ```

3. **Right-size Instances**:
   - Start with t3.small if workload permits
   - Use t3.micro for development

4. **Scheduled Scaling**:
   - Scale down nodes during off-hours
   - Use KEDA for event-driven autoscaling

---

## 🛠️ Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n capstone-app

# Check image pull issues
kubectl get events -n capstone-app | grep -i error

# Verify ECR authentication
aws ecr get-login-password --region ap-south-1
```

### LoadBalancer Not Creating

```bash
# Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify IAM role
kubectl describe sa aws-load-balancer-controller -n kube-system
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml

# Verify HPA status
kubectl describe hpa web-app-hpa -n capstone-app
```

---

## 🧹 Cleanup

### Delete All Resources

```bash
# Option A: Use cleanup script
chmod +x cleanup-eks.sh
./cleanup-eks.sh

# Option B: Manual cleanup
kubectl delete -f k8s/
cd terraform-eks
terraform destroy
```

**Note**: Ensure LoadBalancers are deleted before destroying VPC to avoid issues.

---

## 📚 Key Concepts Explained

### ECR → EKS Image Deployment Flow

1. **CI/CD builds images** → Pushes to ECR with tags
2. **Kubernetes Deployment manifest** → References ECR image URL
3. **Node IAM role** → Has ECR pull permissions (via IRSA)
4. **kubelet pulls image** → Uses AWS credentials from instance metadata
5. **Container runtime** → Runs the container from ECR image

### IRSA (IAM Roles for Service Accounts)

Instead of giving all pods the same permissions (via node IAM role), IRSA allows:
- Pod-level IAM permissions
- Uses OIDC provider
- Temporary credentials via STS AssumeRoleWithWebIdentity
- Better security and compliance

---

## 🎓 Capstone Project Highlights

### What This Demonstrates

✅ **Cloud Architecture**: Multi-AZ, highly available AWS infrastructure  
✅ **Infrastructure as Code**: Complete Terraform automation  
✅ **Container Orchestration**: Production Kubernetes patterns  
✅ **Security Best Practices**: IRSA, VPC endpoints, private subnets  
✅ **Auto-scaling**: Both pod (HPA) and node (CA) levels  
✅ **CI/CD Ready**: Automated deployment pipeline integration  
✅ **Monitoring**: Metrics server, CloudWatch integration  
✅ **Cost Awareness**: Resource optimization strategies  

### Production-Ready Features

- Rolling updates with zero downtime
- Health checks (liveness & readiness probes)
- Resource requests and limits
- ConfigMap for configuration management
- Secrets management capability (can add Secrets Store CSI)
- Multi-environment support (via Terraform workspaces)
- Disaster recovery (multi-AZ, backups)

---

## 📝 References

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

---

## 👨‍💻 Author

**Capstone Project - AWS EKS Deployment**  
Demonstrating enterprise-grade cloud infrastructure and Kubernetes orchestration

---

## 📄 License

This project is for educational purposes as part of a capstone demonstration.
