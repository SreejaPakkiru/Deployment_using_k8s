# Capstone Application Helm Chart

## Overview

This Helm chart deploys the Capstone Node.js application with Redis and NGINX to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Amazon ECR access configured

## Installation

### Install with default values

```bash
helm install capstone-app ./helm/capstone-app -n capstone-app --create-namespace
```

### Install with custom values

```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app \
  --create-namespace \
  --set webApp.image.tag=v1.0.0 \
  --set nginx.image.tag=v1.0.0
```

### Install with custom values file

```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app \
  --create-namespace \
  -f custom-values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace` | Kubernetes namespace | `capstone-app` |
| `ecr.registry` | ECR registry URL | `954692414134.dkr.ecr.ap-south-1.amazonaws.com` |
| `ecr.repository` | ECR repository name | `capstone-repo` |
| `redis.enabled` | Enable Redis deployment | `true` |
| `redis.replicas` | Number of Redis replicas | `1` |
| `redis.resources.requests.cpu` | Redis CPU request | `100m` |
| `redis.resources.requests.memory` | Redis memory request | `128Mi` |
| `webApp.enabled` | Enable web application | `true` |
| `webApp.replicas` | Initial number of web app replicas | `3` |
| `webApp.image.tag` | Web app image tag | `latest` |
| `webApp.resources.requests.cpu` | Web app CPU request | `100m` |
| `webApp.resources.requests.memory` | Web app memory request | `128Mi` |
| `nginx.enabled` | Enable NGINX deployment | `true` |
| `nginx.replicas` | Number of NGINX replicas | `2` |
| `nginx.image.tag` | NGINX image tag | `latest` |
| `nginx.service.type` | NGINX service type | `LoadBalancer` |
| `autoscaling.enabled` | Enable HPA | `true` |
| `autoscaling.minReplicas` | Minimum replicas | `3` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `70` |
| `ingress.enabled` | Enable Ingress | `false` |

## Upgrading

### Upgrade to new image version

```bash
helm upgrade capstone-app ./helm/capstone-app \
  --set webApp.image.tag=v2.0.0 \
  --set nginx.image.tag=v2.0.0
```

### Upgrade with new values

```bash
helm upgrade capstone-app ./helm/capstone-app \
  -f updated-values.yaml
```

## Uninstallation

```bash
helm uninstall capstone-app -n capstone-app
kubectl delete namespace capstone-app
```

## Examples

### Production configuration

```yaml
# production-values.yaml
webApp:
  replicas: 5
  image:
    tag: v1.2.3
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi

nginx:
  replicas: 3
  image:
    tag: v1.2.3

autoscaling:
  minReplicas: 5
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60
```

```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app \
  --create-namespace \
  -f production-values.yaml
```

### Development configuration

```yaml
# dev-values.yaml
webApp:
  replicas: 1
  image:
    tag: dev
  resources:
    requests:
      cpu: 50m
      memory: 64Mi

nginx:
  replicas: 1
  image:
    tag: dev
  service:
    type: ClusterIP  # Use port-forward instead of LoadBalancer

autoscaling:
  enabled: false
```

```bash
helm install capstone-app ./helm/capstone-app \
  -n capstone-app-dev \
  --create-namespace \
  -f dev-values.yaml
```

## Troubleshooting

### View all resources

```bash
helm list -n capstone-app
kubectl get all -n capstone-app
```

### View Helm values

```bash
helm get values capstone-app -n capstone-app
```

### View rendered templates

```bash
helm template capstone-app ./helm/capstone-app
```

### Debug installation

```bash
helm install capstone-app ./helm/capstone-app --dry-run --debug
```

## Notes

- The chart creates a namespace if it doesn't exist
- LoadBalancer service type requires cloud provider support
- For production, always specify image tags instead of using `latest`
- Ensure your cluster has Metrics Server installed for HPA to work
