#!/bin/bash

# Script to update application images in EKS
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Application Update Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Variables
ECR_REGISTRY="954692414134.dkr.ecr.ap-south-1.amazonaws.com"
ECR_REPO="capstone-repo"
IMAGE_TAG=${1:-latest}

if [ -z "$1" ]; then
    echo -e "${YELLOW}No tag specified, using 'latest'${NC}"
fi

# Update web application deployment
update_web_deployment() {
    echo -e "\n${YELLOW}Updating web application...${NC}"
    kubectl set image deployment/web-app \
        web-app=${ECR_REGISTRY}/${ECR_REPO}:web-${IMAGE_TAG} \
        -n capstone-app
    
    kubectl rollout status deployment/web-app -n capstone-app
    echo -e "${GREEN}✓ Web application updated${NC}"
}

# Update nginx deployment
update_nginx_deployment() {
    echo -e "\n${YELLOW}Updating NGINX...${NC}"
    kubectl set image deployment/nginx \
        nginx=${ECR_REGISTRY}/${ECR_REPO}:nginx-${IMAGE_TAG} \
        -n capstone-app
    
    kubectl rollout status deployment/nginx -n capstone-app
    echo -e "${GREEN}✓ NGINX updated${NC}"
}

# Main execution
main() {
    update_web_deployment
    update_nginx_deployment
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Update Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    kubectl get pods -n capstone-app
}

main
