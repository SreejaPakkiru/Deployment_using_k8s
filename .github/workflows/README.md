# GitHub Actions Workflows

This directory contains CI/CD workflows for automated deployment to Amazon EKS.

## 📋 Available Workflows

| Workflow | File | Purpose | Trigger |
|----------|------|---------|---------|
| 🏗️ **Deploy Infrastructure** | `deploy-infrastructure.yml` | Create/update/destroy EKS cluster | Manual, Push (terraform files) |
| 🚀 **Build and Deploy** | `build-and-deploy.yml` | Build images and deploy app | Manual, Push (app files) |
| ⚙️ **Helm Deploy** | `helm-deploy.yml` | Deploy using Helm charts | Manual |
| 🧹 **Cleanup** | `cleanup.yml` | Delete resources | Manual (with confirmation) |
| 🧪 **Tests** | `test.yml` | Run tests and validation | PR, Push, Manual |

## 🚀 Quick Start

### 1. Setup Secrets

Add to **Repository Settings → Secrets and variables → Actions**:

```
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
```

### 2. First Deployment

```
1. Actions → "Deploy EKS Infrastructure" → Run (action: apply)
   ⏱️ ~20 minutes
   
2. Actions → "Build and Deploy Application" → Run
   ⏱️ ~10 minutes
   
3. Check deployment summary for application URL
```

### 3. Update Application

```
1. Make code changes
2. Commit and push to main
3. Workflow automatically builds and deploys
```

## 📖 Documentation

- **Setup Guide**: [SETUP.md](../SETUP.md)
- **Project Docs**: [../../README.md](../../README.md)
- **Deployment Guide**: [../../EKS-DEPLOYMENT-GUIDE.md](../../EKS-DEPLOYMENT-GUIDE.md)

## 🔄 Workflow Sequence

```
┌─────────────────────────────────────┐
│  1. Deploy Infrastructure           │
│     (One-time or updates)           │
│     Creates: VPC, EKS, Nodes        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. Build and Deploy                │
│     (On every code push)            │
│     Builds → ECR → K8s Deploy       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Application Running! 🎉            │
│  Access via LoadBalancer URL        │
└─────────────────────────────────────┘
```

## 💡 Tips

- **First time?** Start with `plan` action to preview
- **Testing?** Use the test workflow before deploying
- **Multiple envs?** Use Helm workflow with different environments
- **Cleanup?** Remember to type "DESTROY" to confirm

## 📞 Support

See [../../QUICK-REFERENCE.md](../../QUICK-REFERENCE.md) for kubectl commands and troubleshooting.
