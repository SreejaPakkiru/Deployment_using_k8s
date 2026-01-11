# Architecture Migration: Docker Compose → Amazon EKS

## 🔄 Comparison Overview

| Aspect | Docker Compose (Before) | Amazon EKS (After) |
|--------|------------------------|-------------------|
| **Orchestration** | Docker Compose | Kubernetes |
| **Infrastructure** | Single EC2 Instance | Multi-AZ EKS Cluster |
| **Scaling** | Manual | Automatic (HPA + CA) |
| **High Availability** | None (Single point of failure) | Multi-AZ, Self-healing |
| **Load Balancing** | NGINX container | AWS NLB/ALB + NGINX |
| **Deployment** | SSH + docker-compose up | kubectl/GitOps |
| **Infrastructure Management** | Manual/Scripts | Terraform (IaC) |
| **Cost** | ~$20-30/month | ~$293/month |
| **Production Ready** | No | Yes |

---

## 📊 Detailed Component Mapping

### 1. Redis Database

**Docker Compose:**
```yaml
redis:
  image: 'redislabs/redismod'
  container_name: redis
  ports:
    - '6379:6379'
```

**Kubernetes:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: capstone-app
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: redis
        image: redislabs/redismod:latest
        ports:
        - containerPort: 6379
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        livenessProbe:
          tcpSocket:
            port: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  type: ClusterIP
  ports:
  - port: 6379
  selector:
    app: redis
```

**Key Improvements:**
- ✅ Resource limits prevent resource starvation
- ✅ Health probes for automatic recovery
- ✅ Service discovery via DNS (redis.capstone-app.svc.cluster.local)
- ✅ Namespace isolation
- ✅ Can be scaled to Redis Cluster/StatefulSet for HA

---

### 2. Web Application (Node.js)

**Docker Compose:**
```yaml
web1:
  build: ./web
  image: 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web1-${TAG}
  container_name: web1
  restart: on-failure
  ports:
    - '81:5000'

web2:
  build: ./web
  image: 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web2-${TAG}
  container_name: web2
  restart: on-failure
  ports:
    - '82:5000'
```

**Kubernetes:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: capstone-app
spec:
  replicas: 3  # Automatic distribution across nodes
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Zero-downtime updates
  template:
    spec:
      containers:
      - name: web-app
        image: 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:web-latest
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
        env:
        - name: REDIS_HOST
          value: "redis"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 5000
        readinessProbe:
          httpGet:
            path: /
            port: 5000
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Key Improvements:**
- ✅ Auto-scaling (3-10 pods) based on load
- ✅ Zero-downtime rolling updates
- ✅ Self-healing (automatic pod restart on failure)
- ✅ Health checks (liveness + readiness)
- ✅ Resource guarantees and limits
- ✅ Environment variable management
- ✅ Single image, multiple replicas (vs. multiple containers)

---

### 3. NGINX Load Balancer

**Docker Compose:**
```yaml
nginx:
  build: ./nginx
  image: 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-${TAG}
  container_name: nginx
  ports:
    - '80:80'
  depends_on:
    - web1
    - web2
```

**Kubernetes:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    # Configuration externalized
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: nginx
        image: 954692414134.dkr.ecr.ap-south-1.amazonaws.com/capstone-repo:nginx-latest
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer  # Creates AWS NLB
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
```

**Key Improvements:**
- ✅ ConfigMap for configuration management (no rebuild needed)
- ✅ AWS Network Load Balancer for external access
- ✅ High availability (2 replicas)
- ✅ Automatic service discovery to backend pods
- ✅ Health checks and automatic failover
- ✅ Cross-zone load balancing

---

## 🏗️ Infrastructure Evolution

### Docker Compose Architecture

```
┌──────────────────────────────────────┐
│         Single EC2 Instance          │
│                                      │
│  ┌────────────────────────────────┐ │
│  │      Docker Compose            │ │
│  │                                │ │
│  │  ┌──────┐  ┌──────┐  ┌──────┐ │ │
│  │  │NGINX │  │ Web1 │  │ Web2 │ │ │
│  │  │  :80 │→ │ :5000│  │:5000 │ │ │
│  │  └──────┘  └───┬──┘  └───┬──┘ │ │
│  │              │         │     │ │
│  │          ┌───▼─────────▼───┐ │ │
│  │          │   Redis :6379   │ │ │
│  │          └─────────────────┘ │ │
│  └────────────────────────────────┘ │
│                                      │
│  Issues:                             │
│  ❌ Single point of failure          │
│  ❌ No auto-scaling                  │
│  ❌ Manual updates (downtime)        │
│  ❌ No failover                      │
└──────────────────────────────────────┘
```

### EKS Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                       AWS Cloud (Multi-AZ)                          │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                  Application Load Balancer                    │  │
│  │                   (Auto-created by K8s)                       │  │
│  └────────────────────────────┬─────────────────────────────────┘  │
│                               │                                     │
│  ┌────────────────────────────┼─────────────────────────────────┐  │
│  │         EKS Cluster        │                                 │  │
│  │                            │                                 │  │
│  │  ┌─────────────────────────▼──────────────────────────────┐ │  │
│  │  │  NGINX Service (Type: LoadBalancer)                    │ │  │
│  │  │  ┌──────────┐  ┌──────────┐                           │ │  │
│  │  │  │ NGINX-1  │  │ NGINX-2  │  (2 replicas)            │ │  │
│  │  │  └────┬─────┘  └────┬─────┘                           │ │  │
│  │  └───────┼─────────────┼────────────────────────────────┘ │  │
│  │          │             │                                   │  │
│  │  ┌───────▼─────────────▼────────────────────────────────┐ │  │
│  │  │  Web App Service (ClusterIP)                         │ │  │
│  │  │  ┌───────┐ ┌───────┐ ┌───────┐ ... up to 10 pods    │ │  │
│  │  │  │ Web-1 │ │ Web-2 │ │ Web-3 │ (HPA: 3-10)          │ │  │
│  │  │  └───┬───┘ └───┬───┘ └───┬───┘                       │ │  │
│  │  └──────┼─────────┼─────────┼────────────────────────────┘ │  │
│  │         │         │         │                              │  │
│  │  ┌──────▼─────────▼─────────▼────────────────────────────┐ │  │
│  │  │  Redis Service (ClusterIP)                            │ │  │
│  │  │  ┌─────────────┐                                      │ │  │
│  │  │  │   Redis-1   │  (1 replica, can be StatefulSet)    │ │  │
│  │  │  └─────────────┘                                      │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  │                                                              │  │
│  │  Nodes distributed across:                                  │  │
│  │  [AZ-1a]  [AZ-1b]  [AZ-1c]                                 │  │
│  │                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Benefits:                                                          │
│  ✅ Multi-AZ high availability                                     │
│  ✅ Auto-scaling (pods & nodes)                                    │
│  ✅ Zero-downtime deployments                                      │
│  ✅ Self-healing                                                   │
│  ✅ Professional monitoring                                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Enhancements

| Security Aspect | Docker Compose | EKS |
|----------------|----------------|-----|
| **Network Isolation** | None (shared network) | Namespaces, Network Policies |
| **Secrets Management** | Environment variables | Kubernetes Secrets, AWS Secrets Manager |
| **IAM Permissions** | EC2 instance role (all containers) | IRSA (per-pod roles) |
| **Image Security** | Manual scanning | ECR automatic scanning |
| **Pod Security** | N/A | Pod Security Standards |
| **Encryption** | None | EBS encryption, Secrets encryption at rest |
| **Access Control** | SSH to EC2 | RBAC, IAM authentication |
| **Private Networking** | Public EC2 | Private subnets, VPC endpoints |

---

## 📈 Operational Improvements

### Deployment Process

**Docker Compose:**
```bash
# Manual process
ssh ec2-instance
git pull
docker-compose down  # ❌ Downtime!
docker-compose build
docker-compose up -d
# ❌ Manual, error-prone, downtime
```

**Kubernetes:**
```bash
# Automated, zero-downtime
kubectl set image deployment/web-app web-app=<new-image>
# or via CI/CD pipeline
# ✅ Rolling update, automatic rollback on failure
```

### Scaling

**Docker Compose:**
```bash
# Manual
docker-compose up -d --scale web=5  # ❌ No auto-scale
# ❌ No health-based scaling
# ❌ Manual monitoring required
```

**Kubernetes:**
```yaml
# Automatic HPA
# ✅ Scales based on CPU/memory metrics
# ✅ Scales from 3 to 10 pods automatically
# ✅ Node autoscaling adds/removes EC2 instances
```

### Monitoring

**Docker Compose:**
- `docker logs <container>`
- `docker stats`
- ❌ No centralized logging
- ❌ Basic metrics

**Kubernetes:**
- CloudWatch Container Insights
- Prometheus + Grafana integration
- Centralized logging (Fluentd/CloudWatch Logs)
- ✅ Cluster-wide metrics
- ✅ Application performance monitoring

---

## 💰 Cost Analysis

### Docker Compose Setup
```
EC2 Instance (t3.medium):     $30/month
Elastic IP:                   $3.60/month
EBS Volume (20GB):            $2/month
────────────────────────────────────────
Total:                        ~$36/month
```

**Limitations:**
- Single point of failure
- No auto-scaling
- Manual intervention needed

### EKS Setup
```
EKS Control Plane:            $73/month
EC2 Nodes (3 x t3.medium):    $95/month
NAT Gateways (3 AZ):          $97/month
Network Load Balancer:        $22/month
EBS Volumes:                  $6/month
────────────────────────────────────────
Total:                        ~$293/month
```

**Benefits:**
- Production-grade availability
- Auto-scaling (cost scales with load)
- Zero-downtime deployments
- Enterprise monitoring

### Cost Optimization for Development

```
Single NAT Gateway:           Save $65/month
t3.small instances:           Save $47/month
Spot instances (dev):         Save additional 70%
────────────────────────────────────────
Optimized Dev Cost:           ~$150/month
```

---

## 🚀 Migration Benefits Summary

### Reliability
- **Before**: Single point of failure, manual recovery
- **After**: Multi-AZ, self-healing, automatic failover

### Scalability
- **Before**: Manual scaling, downtime during scale
- **After**: Automatic horizontal scaling (pods & nodes)

### Deployment
- **Before**: Manual, risky, downtime
- **After**: Automated, zero-downtime, rollback capability

### Security
- **Before**: Single EC2 role, public instance
- **After**: Pod-level IAM (IRSA), private subnets, VPC endpoints

### Monitoring
- **Before**: Basic logs, manual monitoring
- **After**: CloudWatch, metrics server, cluster insights

### Infrastructure Management
- **Before**: Manual setup, snowflake infrastructure
- **After**: Infrastructure as Code, reproducible, version-controlled

---

## 📋 Migration Checklist

### Pre-Migration
- [ ] Document current Docker Compose setup
- [ ] Identify persistent data (volumes, databases)
- [ ] Plan for data migration strategy
- [ ] Set up AWS account and configure credentials
- [ ] Create Terraform backend (S3 + DynamoDB)

### Infrastructure Setup
- [ ] Review and customize Terraform variables
- [ ] Provision VPC and networking
- [ ] Create EKS cluster
- [ ] Install cluster add-ons (ALB controller, metrics server)
- [ ] Configure kubectl access

### Application Migration
- [ ] Push images to ECR
- [ ] Create Kubernetes manifests
- [ ] Deploy applications to EKS
- [ ] Configure monitoring and logging
- [ ] Set up HPA and cluster autoscaler
- [ ] Configure Ingress/LoadBalancer

### Testing
- [ ] Verify application functionality
- [ ] Test auto-scaling behavior
- [ ] Test rolling update process
- [ ] Simulate node failure (HA testing)
- [ ] Load testing
- [ ] Security audit

### Production Cutover
- [ ] Plan maintenance window
- [ ] Update DNS to point to new LoadBalancer
- [ ] Monitor application health
- [ ] Keep old EC2 instance as backup (1-2 weeks)
- [ ] Decommission old infrastructure

---

## 🎯 Conclusion

This migration transforms a development-oriented Docker Compose setup into an **enterprise-grade, production-ready Kubernetes deployment** on AWS EKS.

**Key Takeaways:**
- ✅ **High Availability**: Multi-AZ deployment survives datacenter failures
- ✅ **Auto-Scaling**: Handles traffic spikes automatically
- ✅ **Zero Downtime**: Deploy updates without user impact
- ✅ **Security**: Pod-level IAM, private networking, encrypted secrets
- ✅ **Observability**: Comprehensive monitoring and logging
- ✅ **Infrastructure as Code**: Reproducible, version-controlled infrastructure

**Trade-offs:**
- Higher complexity (learning curve)
- Increased cost (~8x for full production setup)
- More components to manage

**Recommendation:**
- Production workloads: **EKS is essential**
- Development/staging: **Can optimize for cost**
- Personal projects: **Docker Compose may suffice**
