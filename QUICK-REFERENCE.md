# Quick Reference Guide - EKS Deployment

## 🚀 Common Commands

### Infrastructure Management

```bash
# Initialize Terraform
cd terraform-eks
terraform init

# Plan infrastructure changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# Configure kubectl
aws eks update-kubeconfig --region ap-south-1 --name capstone-eks-cluster
```

### ECR Operations

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin \
  954692414134.dkr.ecr.ap-south-1.amazonaws.com

# Build and push web app
docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-v1.0 ./web
docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-v1.0

# Build and push nginx
docker build -t 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-v1.0 ./nginx
docker push 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-v1.0

# List images
aws ecr list-images --repository-name capstone-repo --region ap-south-1
```

### Kubernetes Operations

```bash
# Deploy all manifests
kubectl apply -f k8s/

# Deploy specific resource
kubectl apply -f k8s/web-deployment.yaml

# Get all resources
kubectl get all -n capstone-app

# Get pods with more details
kubectl get pods -n capstone-app -o wide

# Describe a pod
kubectl describe pod <pod-name> -n capstone-app

# View pod logs
kubectl logs <pod-name> -n capstone-app
kubectl logs -f deployment/web-app -n capstone-app

# Execute command in pod
kubectl exec -it <pod-name> -n capstone-app -- /bin/sh

# Delete resources
kubectl delete -f k8s/
```

### Deployment Updates

```bash
# Update image
kubectl set image deployment/web-app \
  web-app=954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-v2.0 \
  -n capstone-app

# Check rollout status
kubectl rollout status deployment/web-app -n capstone-app

# View rollout history
kubectl rollout history deployment/web-app -n capstone-app

# Rollback to previous version
kubectl rollout undo deployment/web-app -n capstone-app

# Rollback to specific revision
kubectl rollout undo deployment/web-app --to-revision=2 -n capstone-app
```

### Scaling Operations

```bash
# Manual scaling
kubectl scale deployment web-app --replicas=5 -n capstone-app

# View HPA status
kubectl get hpa -n capstone-app

# Describe HPA
kubectl describe hpa web-app-hpa -n capstone-app

# View node autoscaling
kubectl get nodes
kubectl describe node <node-name>
```

### Helm Operations

```bash
# Install chart
helm install capstone-app ./helm/capstone-app -n capstone-app --create-namespace

# Upgrade chart
helm upgrade capstone-app ./helm/capstone-app

# List releases
helm list -n capstone-app

# Get values
helm get values capstone-app -n capstone-app

# Uninstall
helm uninstall capstone-app -n capstone-app

# Dry run / debug
helm install capstone-app ./helm/capstone-app --dry-run --debug
```

### Monitoring & Debugging

```bash
# Check cluster info
kubectl cluster-info
kubectl cluster-info dump

# View events
kubectl get events -n capstone-app --sort-by='.lastTimestamp'

# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n capstone-app

# View metrics server
kubectl get apiservice v1beta1.metrics.k8s.io

# Check service endpoints
kubectl get endpoints -n capstone-app

# Port forward for local testing
kubectl port-forward svc/web-app-service 8080:80 -n capstone-app
```

### Service Discovery

```bash
# Get LoadBalancer URL
kubectl get svc nginx-service -n capstone-app

# Get external IP/hostname
export LB_URL=$(kubectl get svc nginx-service -n capstone-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $LB_URL

# Test application
curl http://$LB_URL
```

### ConfigMaps & Secrets

```bash
# View ConfigMaps
kubectl get configmap -n capstone-app

# Describe ConfigMap
kubectl describe configmap nginx-config -n capstone-app

# Edit ConfigMap
kubectl edit configmap nginx-config -n capstone-app

# Create secret (example)
kubectl create secret generic app-secret \
  --from-literal=password=mysecret \
  -n capstone-app
```

### Troubleshooting

```bash
# Pod not starting
kubectl describe pod <pod-name> -n capstone-app
kubectl logs <pod-name> -n capstone-app --previous

# Service not accessible
kubectl get svc -n capstone-app
kubectl get endpoints -n capstone-app
kubectl describe svc nginx-service -n capstone-app

# Image pull errors
kubectl get events -n capstone-app | grep -i error
kubectl describe pod <pod-name> -n capstone-app | grep -i image

# Check ALB controller (if using Ingress)
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check cluster autoscaler
kubectl logs -n kube-system deployment/cluster-autoscaler

# View all namespaces
kubectl get ns
kubectl get all --all-namespaces
```

### Cleanup

```bash
# Delete application
kubectl delete -f k8s/

# Delete namespace
kubectl delete namespace capstone-app

# Destroy infrastructure
cd terraform-eks
terraform destroy

# Or use cleanup script
chmod +x cleanup-eks.sh
./cleanup-eks.sh
```

## 📊 Quick Verification Checklist

```bash
# 1. Verify cluster is running
kubectl get nodes

# 2. Verify all pods are running
kubectl get pods -n capstone-app

# 3. Verify services are created
kubectl get svc -n capstone-app

# 4. Verify HPA is working
kubectl get hpa -n capstone-app

# 5. Verify LoadBalancer has external IP
kubectl get svc nginx-service -n capstone-app

# 6. Test application
curl http://$(kubectl get svc nginx-service -n capstone-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

## 🔐 AWS CLI Shortcuts

```bash
# Get cluster details
aws eks describe-cluster --name capstone-eks-cluster --region ap-south-1

# List node groups
aws eks list-nodegroups --cluster-name capstone-eks-cluster --region ap-south-1

# Describe node group
aws eks describe-nodegroup \
  --cluster-name capstone-eks-cluster \
  --nodegroup-name <nodegroup-name> \
  --region ap-south-1

# Update kubeconfig
aws eks update-kubeconfig --region ap-south-1 --name capstone-eks-cluster

# Get ECR login
aws ecr get-login-password --region ap-south-1
```

## 📈 Performance Testing

```bash
# Generate load (using Apache Bench)
ab -n 10000 -c 100 http://<LoadBalancer-URL>/

# Watch HPA scaling
watch -n 1 kubectl get hpa -n capstone-app

# Watch pod count
watch -n 1 kubectl get pods -n capstone-app

# Monitor resources
watch -n 1 kubectl top pods -n capstone-app
```

## 🎯 Environment-Specific Deployment

### Development
```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app-dev \
  --create-namespace \
  --set webApp.replicas=1 \
  --set nginx.replicas=1 \
  --set autoscaling.enabled=false
```

### Staging
```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app-staging \
  --create-namespace \
  --set webApp.replicas=2 \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=5
```

### Production
```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app \
  --create-namespace \
  --set webApp.replicas=5 \
  --set autoscaling.minReplicas=5 \
  --set autoscaling.maxReplicas=20
```

## 💡 Pro Tips

1. **Always tag images with version numbers** instead of `latest` in production
2. **Use `kubectl apply`** instead of `kubectl create` for idempotency
3. **Monitor costs** regularly with AWS Cost Explorer
4. **Enable CloudWatch Container Insights** for better monitoring
5. **Use Helm** for easier configuration management
6. **Test rollbacks** before going to production
7. **Set resource limits** to prevent resource exhaustion
8. **Use namespaces** to isolate environments
9. **Regularly update** cluster and node versions
10. **Backup** important data and configurations
