# 📚 Documentation Index

## Quick Navigation

This project contains comprehensive documentation for deploying a production-grade application on Amazon EKS. Use this index to find what you need quickly.

---

## 🎯 Getting Started

**New to this project? Start here:**

1. **[README.md](README.md)** - Project overview, quick start guide, and feature summary
2. **[PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)** - Complete deliverables checklist and project status
3. **[EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md)** - Step-by-step deployment instructions

**Estimated reading time: 15-20 minutes**

---

## 📖 Documentation Files

### Core Documentation (Must Read)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[README.md](README.md)** | Main project overview | First stop for understanding the project |
| **[EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md)** | Complete deployment walkthrough | When deploying to AWS |
| **[PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)** | Deliverables & completion status | For capstone presentation prep |
| **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** | Command cheat sheet | Daily operations and troubleshooting |

### Architecture Documentation

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md)** | Before/After detailed comparison | Understanding the migration benefits |
| **[ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md)** | Visual architecture diagrams | System design review, presentations |

### Deployment Resources

| Resource | Purpose | When to Use |
|----------|---------|-------------|
| **[helm/capstone-app/README.md](helm/capstone-app/README.md)** | Helm chart documentation | Using Helm for deployment |
| **[deploy-eks.sh](deploy-eks.sh)** | Automated deployment script | First-time infrastructure setup |
| **[update-app.sh](update-app.sh)** | Application update script | Deploying new versions |
| **[cleanup-eks.sh](cleanup-eks.sh)** | Resource cleanup script | Tearing down infrastructure |

---

## 🗂️ Documentation by Topic

### Infrastructure Setup
- **Terraform Configuration**: [terraform-eks/](terraform-eks/)
  - VPC Setup: [vpc.tf](terraform-eks/vpc.tf)
  - EKS Cluster: [eks-cluster.tf](terraform-eks/eks-cluster.tf)
  - Add-ons: [eks-addons.tf](terraform-eks/eks-addons.tf)
- **Deployment Guide**: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-deployment-steps)

### Kubernetes Resources
- **Manifests**: [k8s/](k8s/)
  - All deployments, services, configmaps
- **Helm Chart**: [helm/capstone-app/](helm/capstone-app/)
- **Usage Guide**: [QUICK-REFERENCE.md](QUICK-REFERENCE.md#kubernetes-operations)

### Architecture Understanding
- **System Overview**: [README.md](README.md#-architecture)
- **Detailed Comparison**: [ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md)
- **Visual Diagrams**: [ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md)
- **Deployment Flow**: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-deployment-flow)

### Security
- **Security Features**: [README.md](README.md#-security-highlights)
- **Security Layers**: [ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md#-security-layers)
- **Best Practices**: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-security-features)
- **IAM & IRSA**: [terraform-eks/eks-cluster.tf](terraform-eks/eks-cluster.tf) (lines 70-130)

### Scaling & High Availability
- **Auto-Scaling**: [README.md](README.md#-high-availability--scaling)
- **HPA Configuration**: [k8s/hpa.yaml](k8s/hpa.yaml)
- **Scaling Behavior**: [ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md#-scaling-behavior)
- **Multi-AZ Setup**: [ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md#-infrastructure-evolution)

### Cost Management
- **Cost Analysis**: [README.md](README.md#-cost-estimate)
- **Optimization**: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-cost-optimization)
- **Comparison**: [ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md#-cost-analysis)

### Troubleshooting
- **Common Issues**: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-troubleshooting)
- **Debug Commands**: [QUICK-REFERENCE.md](QUICK-REFERENCE.md#monitoring--debugging)
- **Operations**: [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

---

## 🎓 Learning Paths

### Path 1: Quick Demo (30 minutes)
1. Read [README.md](README.md) - 10 min
2. Review [ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md) - 5 min
3. Run [deploy-eks.sh](deploy-eks.sh) - 15 min

### Path 2: Complete Understanding (2-3 hours)
1. Read [README.md](README.md) - 15 min
2. Read [ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md) - 30 min
3. Study [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md) - 45 min
4. Review Terraform files in [terraform-eks/](terraform-eks/) - 30 min
5. Practice with [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - 30 min

### Path 3: Deployment Engineer (Full Day)
1. Complete "Path 2: Complete Understanding"
2. Deploy infrastructure: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-deployment-steps)
3. Test scaling: [QUICK-REFERENCE.md](QUICK-REFERENCE.md#scaling-operations)
4. Perform updates: [update-app.sh](update-app.sh)
5. Troubleshooting practice: [QUICK-REFERENCE.md](QUICK-REFERENCE.md#troubleshooting)

### Path 4: Capstone Preparation (2-3 days)
1. Complete all above paths
2. Customize for your environment
3. Document any changes
4. Prepare presentation slides from documentation
5. Practice demo deployment

---

## 📊 File Structure Map

```
Documentation (You Are Here)
├── 📄 INDEX.md                          ← You are here
├── 📄 README.md                         ← Start here
├── 📄 PROJECT-SUMMARY.md                ← Deliverables checklist
├── 📄 EKS-DEPLOYMENT-GUIDE.md          ← Deployment instructions
├── 📄 ARCHITECTURE-COMPARISON.md        ← Before/After analysis
├── 📄 ARCHITECTURE-VISUALIZATION.md     ← System diagrams
└── 📄 QUICK-REFERENCE.md                ← Command reference

Infrastructure Code
├── 📂 terraform-eks/                    ← AWS infrastructure
│   ├── provider.tf                      ← AWS provider config
│   ├── variables.tf                     ← Input variables
│   ├── vpc.tf                           ← VPC, subnets, NAT
│   ├── eks-cluster.tf                   ← EKS cluster setup
│   ├── eks-addons.tf                    ← Cluster add-ons
│   ├── ecr.tf                           ← Container registry
│   ├── outputs.tf                       ← Output values
│   └── terraform-backend-setup.tf       ← State management

Kubernetes Resources
├── 📂 k8s/                              ← Kubernetes manifests
│   ├── namespace.yaml
│   ├── redis-deployment.yaml
│   ├── web-deployment.yaml
│   ├── nginx-configmap.yaml
│   ├── nginx-deployment.yaml
│   ├── ingress.yaml
│   └── hpa.yaml

Helm Charts
├── 📂 helm/capstone-app/               ← Helm deployment
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── README.md
│   └── templates/
│       ├── namespace.yaml
│       ├── redis.yaml
│       ├── web-app.yaml
│       ├── nginx.yaml
│       ├── hpa.yaml
│       └── ingress.yaml

Application Code
├── 📂 web/                              ← Node.js app
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── 📂 nginx/                            ← NGINX proxy
│   ├── Dockerfile
│   └── nginx.conf

Deployment Scripts
├── 🚀 deploy-eks.sh                     ← Deploy everything
├── 🔄 update-app.sh                     ← Update application
└── 🧹 cleanup-eks.sh                    ← Cleanup resources
```

---

## 🔍 Find Information By Task

### I want to...

**Deploy the application for the first time**
→ [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-deployment-steps)

**Understand the architecture**
→ [ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md)

**Compare Docker Compose vs EKS**
→ [ARCHITECTURE-COMPARISON.md](ARCHITECTURE-COMPARISON.md)

**Update application images**
→ [QUICK-REFERENCE.md](QUICK-REFERENCE.md#deployment-updates)

**Scale the application**
→ [QUICK-REFERENCE.md](QUICK-REFERENCE.md#scaling-operations)

**Troubleshoot issues**
→ [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-troubleshooting)

**Understand costs**
→ [README.md](README.md#-cost-estimate)

**Prepare for capstone presentation**
→ [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md#-capstone-presentation-points)

**Use Helm instead of kubectl**
→ [helm/capstone-app/README.md](helm/capstone-app/README.md)

**Clean up everything**
→ [cleanup-eks.sh](cleanup-eks.sh) or [QUICK-REFERENCE.md](QUICK-REFERENCE.md#cleanup)

---

## 📈 Documentation Statistics

- **Total Documentation Files**: 8
- **Total Lines of Documentation**: 2000+
- **Code Files (Terraform + K8s + Helm)**: 27
- **Scripts**: 3
- **Diagrams**: 15+
- **Complete Examples**: 50+
- **Commands Documented**: 100+

---

## 💡 Pro Tips

1. **Bookmark this page** - Your navigation hub
2. **Use CTRL+F** - Search within documents
3. **Start with README.md** - Get the big picture
4. **Keep QUICK-REFERENCE.md open** - While working
5. **Print ARCHITECTURE-VISUALIZATION.md** - For presentations

---

## 🎯 Document Purpose Matrix

| Need | Document | Section |
|------|----------|---------|
| Project Overview | README.md | All |
| Quick Commands | QUICK-REFERENCE.md | All |
| Step-by-Step Deploy | EKS-DEPLOYMENT-GUIDE.md | Deployment Steps |
| Architecture Details | ARCHITECTURE-VISUALIZATION.md | All |
| Migration Benefits | ARCHITECTURE-COMPARISON.md | All |
| Capstone Prep | PROJECT-SUMMARY.md | All |
| Helm Usage | helm/capstone-app/README.md | All |
| Terraform Details | terraform-eks/*.tf | Code comments |

---

## 🔗 External References

While this documentation is comprehensive, here are useful external resources:

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [Helm Documentation](https://helm.sh/docs/)

---

## ✅ Pre-Deployment Checklist

Before deploying, ensure you've reviewed:

- [ ] [README.md](README.md) - Understand the project
- [ ] [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md) - Know the process
- [ ] [terraform-eks/variables.tf](terraform-eks/variables.tf) - Configure your settings
- [ ] AWS credentials configured
- [ ] Required tools installed (kubectl, terraform, AWS CLI)

---

## 📞 Quick Support

**Common Questions:**

Q: Where do I start?  
A: [README.md](README.md)

Q: How do I deploy?  
A: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md)

Q: What's the architecture?  
A: [ARCHITECTURE-VISUALIZATION.md](ARCHITECTURE-VISUALIZATION.md)

Q: How do I fix errors?  
A: [EKS-DEPLOYMENT-GUIDE.md](EKS-DEPLOYMENT-GUIDE.md#-troubleshooting)

Q: What commands do I need?  
A: [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

---

**Last Updated**: January 2026  
**Project Status**: ✅ Complete and Production-Ready

---

**Happy Deploying! 🚀**
