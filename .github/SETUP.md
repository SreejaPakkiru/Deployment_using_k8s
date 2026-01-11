# GitHub Actions Setup Guide

## 🔐 Required Secrets

Configure these secrets in your GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

### AWS Credentials

1. **AWS_ACCESS_KEY_ID**
   - Your AWS access key ID
   - Get from AWS IAM: Create a user with programmatic access
   
2. **AWS_SECRET_ACCESS_KEY**
   - Your AWS secret access key
   - Provided when creating IAM user

### How to Get AWS Credentials

```bash
# Create IAM user with required permissions
aws iam create-user --user-name github-actions-user

# Attach policies
aws iam attach-user-policy \
  --user-name github-actions-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create access key
aws iam create-access-key --user-name github-actions-user

# The output will contain:
# - AccessKeyId (set as AWS_ACCESS_KEY_ID)
# - SecretAccessKey (set as AWS_SECRET_ACCESS_KEY)
```

**Note:** For production, use a more restrictive IAM policy instead of AdministratorAccess.

---

## 📋 Workflows Overview

### 1. Deploy Infrastructure (`deploy-infrastructure.yml`)

**Triggers:**
- Manual dispatch (workflow_dispatch)
- Push to `main` branch (terraform-eks files)

**Actions:**
- `plan` - Show what will be created
- `apply` - Create infrastructure
- `destroy` - Destroy infrastructure

**Usage:**
```
1. Go to Actions tab
2. Select "Deploy EKS Infrastructure"
3. Click "Run workflow"
4. Choose action (plan/apply/destroy)
5. Click "Run workflow"
```

### 2. Build and Deploy (`build-and-deploy.yml`)

**Triggers:**
- Push to `main` branch (web, nginx, k8s files)
- Manual dispatch

**What it does:**
1. Builds Docker images for web app and NGINX
2. Pushes to Amazon ECR
3. Scans images for vulnerabilities
4. Deploys to EKS cluster
5. Runs health checks
6. Provides deployment URL

**Usage:**
- Automatic on code push
- Or run manually from Actions tab

### 3. Helm Deploy (`helm-deploy.yml`)

**Triggers:**
- Manual dispatch only

**What it does:**
1. Deploys using Helm chart
2. Supports multiple environments (dev/staging/prod)
3. Configurable image tags
4. Environment-specific scaling

**Usage:**
```
1. Actions → "Deploy with Helm"
2. Select environment
3. Enter image tag (or use 'latest')
4. Run workflow
```

### 4. Cleanup (`cleanup.yml`)

**Triggers:**
- Manual dispatch only (with confirmation)

**Options:**
- `application-only` - Delete K8s resources only
- `infrastructure-only` - Destroy Terraform resources
- `everything` - Delete all

**Usage:**
```
1. Actions → "Cleanup Resources"
2. Choose cleanup type
3. Type "DESTROY" in confirm field
4. Run workflow
```

### 5. Tests (`test.yml`)

**Triggers:**
- Pull requests
- Push to `main`
- Manual dispatch

**What it does:**
1. Validates Terraform code
2. Validates Kubernetes manifests
3. Lints Helm charts
4. Tests Docker builds
5. Runs security scans
6. (Optional) Integration tests

---

## 🚀 Complete Deployment Workflow

### First-Time Setup

1. **Add GitHub Secrets**
   ```
   Settings → Secrets and variables → Actions → New repository secret
   
   Add:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   ```

2. **Update Configuration**
   ```bash
   # Get your AWS account ID
   aws sts get-caller-identity --query Account --output text
   
   # Update these files with YOUR account ID:
   - terraform-eks/ecr.tf
   - k8s/*.yaml (image URLs)
   - helm/capstone-app/values.yaml
   - .github/workflows/*.yml (if ECR_REPOSITORY differs)
   ```

3. **Initialize Terraform Backend (One-time)**
   ```
   Actions → Deploy EKS Infrastructure
   Action: plan
   Run workflow
   
   # Then manually create S3 bucket for state:
   cd terraform-eks
   terraform init
   terraform apply -target=aws_s3_bucket.terraform_state
   
   # Update provider.tf with bucket name
   # Commit and push
   ```

### Deploy Everything

**Step 1: Deploy Infrastructure**
```
Actions → Deploy EKS Infrastructure
Action: apply
Run workflow

⏱️ Takes: ~15-20 minutes
✅ Creates: VPC, EKS, nodes, add-ons
```

**Step 2: Build and Deploy Application**
```
Option A (Automatic):
- Push code to main branch
- Workflow triggers automatically

Option B (Manual):
Actions → Build and Deploy Application
Environment: production
Run workflow

⏱️ Takes: ~5-10 minutes
✅ Creates: Docker images, deploys to EKS
```

**Step 3: Access Application**
```
1. Check workflow summary for LoadBalancer URL
2. Wait 2-3 minutes for DNS propagation
3. Visit: http://<LoadBalancer-URL>
```

---

## 🔄 Common Workflows

### Deploy Code Update

```
1. Make changes to web/ or nginx/
2. Commit and push to main
3. Workflow automatically:
   - Builds new images
   - Pushes to ECR
   - Rolling update to EKS (zero downtime!)
4. Check deployment status in Actions
```

### Scale Application

```
Option 1: Update HPA
- Edit k8s/hpa.yaml
- Push to main
- Automatic deployment

Option 2: Use Helm
Actions → Deploy with Helm
Environment: production (adjust replicas)
```

### Rollback Deployment

```bash
# Manual rollback via kubectl (if needed)
kubectl rollout undo deployment/web-app -n capstone-app
kubectl rollout undo deployment/nginx -n capstone-app
```

### Deploy to Different Environment

```
Actions → Deploy with Helm
Environment: staging (or development)
Image tag: latest (or specific version)
Run workflow

✅ Creates separate namespace with env-specific config
```

### Complete Cleanup

```
Actions → Cleanup Resources
Cleanup type: everything
Confirm: DESTROY
Run workflow

⚠️ This will delete EVERYTHING!
```

---

## 📊 Monitoring Deployments

### View Deployment Status

**In GitHub:**
- Actions tab → Select workflow run
- Check each job's logs
- View deployment summary

**Via kubectl:**
```bash
# Update your local kubeconfig
aws eks update-kubeconfig --region ap-south-1 --name capstone-eks-cluster

# Check deployment
kubectl get all -n capstone-app
kubectl get hpa -n capstone-app
kubectl get svc -n capstone-app
```

### Common Issues

**Workflow fails at "Deploy to EKS"**
- Check if cluster exists: `aws eks list-clusters --region ap-south-1`
- Verify AWS credentials in GitHub secrets
- Check workflow logs for specific error

**Images not pulling from ECR**
- Verify ECR repository exists
- Check image tags in workflow outputs
- Verify node IAM role has ECR permissions

**LoadBalancer not getting external IP**
- Check if ALB controller is installed
- View ALB controller logs: `kubectl logs -n kube-system deployment/aws-load-balancer-controller`
- Check security groups

---

## 🎯 Best Practices

### Branch Protection

Recommended for production:
```
Settings → Branches → Add rule
Branch name pattern: main

Enable:
☑ Require pull request reviews
☑ Require status checks (select test workflow)
☑ Require branches to be up to date
```

### Approval Gates

For production deployments, add manual approval:
```yaml
# Add to deploy job in build-and-deploy.yml
environment:
  name: production
  url: http://${{ steps.get-url.outputs.url }}
# Configure environment in repo settings with reviewers
```

### Secrets Rotation

```bash
# Rotate AWS credentials regularly
aws iam create-access-key --user-name github-actions-user
# Update GitHub secrets
aws iam delete-access-key --user-name github-actions-user --access-key-id OLD_KEY
```

### Cost Control

```yaml
# Add to cleanup.yml - scheduled cleanup
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight
```

---

## 🧪 Testing Workflows

### Test Locally (Act)

```bash
# Install act (GitHub Actions local runner)
# https://github.com/nektos/act

# Test workflow locally
act workflow_dispatch -W .github/workflows/test.yml

# Test with secrets
act -s AWS_ACCESS_KEY_ID=xxx -s AWS_SECRET_ACCESS_KEY=yyy
```

### Dry Run

```bash
# Test Terraform without applying
Actions → Deploy EKS Infrastructure
Action: plan
```

---

## 📈 Workflow Outputs

Each workflow provides outputs:

- **Infrastructure**: Cluster name, ECR URL, endpoints
- **Build**: Image tags, ECR URLs
- **Deploy**: LoadBalancer URL, pod status
- **Cleanup**: Resources deleted

Check the "Summary" section of each workflow run.

---

## 🆘 Troubleshooting

### Workflow Permission Errors

```yaml
# Add to workflow if needed
permissions:
  contents: read
  id-token: write
```

### Timeout Issues

Adjust timeouts in workflows:
```yaml
timeout-minutes: 30  # Default is 360
```

### Debug Mode

Enable debug logging:
```
Repository Settings → Secrets → New repository secret
Name: ACTIONS_STEP_DEBUG
Value: true
```

---

## ✅ Verification Checklist

Before first deployment:

- [ ] AWS credentials added to GitHub secrets
- [ ] Account ID updated in all files
- [ ] Terraform backend initialized
- [ ] Branch protection configured (optional)
- [ ] Cost alerts configured in AWS
- [ ] Repository collaborators added
- [ ] Tested with `plan` action first

---

## 📞 Quick Commands

```bash
# Get workflow status
gh workflow list

# View workflow run
gh run list

# Watch workflow
gh run watch

# View logs
gh run view <run-id> --log
```

---

**Your repository is now fully automated! Push to main and watch the magic happen! 🚀**
