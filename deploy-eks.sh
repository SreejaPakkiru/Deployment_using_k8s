#!/bin/bash

# Deployment script for EKS cluster provisioning
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}EKS Cluster Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check prerequisites
check_prerequisites() {
    echo -e "\n${YELLOW}Checking prerequisites...${NC}"
    
    command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is required but not installed. Aborting.${NC}" >&2; exit 1; }
    command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is required but not installed. Aborting.${NC}" >&2; exit 1; }
    command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is required but not installed. Aborting.${NC}" >&2; exit 1; }
    
    echo -e "${GREEN}✓ All prerequisites installed${NC}"
}

# Initialize Terraform
init_terraform() {
    echo -e "\n${YELLOW}Initializing Terraform...${NC}"
    cd terraform-eks
    terraform init
    echo -e "${GREEN}✓ Terraform initialized${NC}"
}

# Plan infrastructure
plan_infrastructure() {
    echo -e "\n${YELLOW}Planning infrastructure...${NC}"
    terraform plan -out=tfplan
    echo -e "${GREEN}✓ Terraform plan created${NC}"
}

# Apply infrastructure
apply_infrastructure() {
    echo -e "\n${YELLOW}Applying infrastructure...${NC}"
    echo -e "${RED}This will create AWS resources and may incur costs.${NC}"
    read -p "Do you want to continue? (yes/no): " response
    
    if [ "$response" == "yes" ]; then
        terraform apply tfplan
        echo -e "${GREEN}✓ Infrastructure created successfully${NC}"
    else
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
}

# Configure kubectl
configure_kubectl() {
    echo -e "\n${YELLOW}Configuring kubectl...${NC}"
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    AWS_REGION=$(terraform output -raw cluster_endpoint | grep -oP 'eks\.\K[^.]+')
    
    aws eks update-kubeconfig --region ap-south-1 --name $CLUSTER_NAME
    echo -e "${GREEN}✓ kubectl configured${NC}"
}

# Verify cluster
verify_cluster() {
    echo -e "\n${YELLOW}Verifying cluster...${NC}"
    kubectl get nodes
    kubectl get pods -A
    echo -e "${GREEN}✓ Cluster is operational${NC}"
}

# Deploy application
deploy_application() {
    echo -e "\n${YELLOW}Deploying application to EKS...${NC}"
    cd ..
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/redis-deployment.yaml
    kubectl apply -f k8s/nginx-configmap.yaml
    kubectl apply -f k8s/web-deployment.yaml
    kubectl apply -f k8s/nginx-deployment.yaml
    kubectl apply -f k8s/hpa.yaml
    
    # Optional: Apply Ingress if using ALB
    # kubectl apply -f k8s/ingress.yaml
    
    echo -e "${GREEN}✓ Application deployed${NC}"
}

# Show deployment info
show_info() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "\n${YELLOW}Getting service endpoints...${NC}"
    kubectl get svc -n capstone-app
    
    echo -e "\n${YELLOW}To access your application:${NC}"
    echo "1. Get the LoadBalancer URL:"
    echo "   kubectl get svc nginx-service -n capstone-app"
    echo ""
    echo "2. Wait for the EXTERNAL-IP to be assigned (may take a few minutes)"
    echo ""
    echo "3. Access your application at: http://<EXTERNAL-IP>"
}

# Main execution
main() {
    check_prerequisites
    init_terraform
    plan_infrastructure
    apply_infrastructure
    configure_kubectl
    verify_cluster
    deploy_application
    show_info
}

# Run main function
main
