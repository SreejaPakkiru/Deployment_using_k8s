#!/bin/bash

# Cleanup script for EKS resources
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}EKS Cluster Cleanup Script${NC}"
echo -e "${RED}========================================${NC}"

echo -e "\n${RED}WARNING: This will destroy all EKS resources!${NC}"
read -p "Are you sure you want to continue? (type 'yes' to confirm): " response

if [ "$response" != "yes" ]; then
    echo -e "${YELLOW}Cleanup cancelled${NC}"
    exit 0
fi

# Delete Kubernetes resources first
delete_k8s_resources() {
    echo -e "\n${YELLOW}Deleting Kubernetes resources...${NC}"
    kubectl delete -f k8s/ --ignore-not-found=true || true
    echo -e "${GREEN}✓ Kubernetes resources deleted${NC}"
}

# Destroy Terraform infrastructure
destroy_terraform() {
    echo -e "\n${YELLOW}Destroying Terraform infrastructure...${NC}"
    cd terraform-eks
    terraform destroy -auto-approve
    echo -e "${GREEN}✓ Infrastructure destroyed${NC}"
}

# Main execution
main() {
    delete_k8s_resources
    sleep 10  # Wait for LoadBalancers to be deleted
    destroy_terraform
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Cleanup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
}

main
