#!/bin/bash

# 🚀 Kubernetes Deployment Script pro Pepa's Inventory System
# Usage: ./k8s-deploy.sh [simple|full|cleanup]

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MODE="${1:-simple}"

echo -e "${BLUE}🚀 Kubernetes Deployment pro Pepa's Inventory System${NC}"
echo ""

case "$MODE" in
  simple)
    echo -e "${YELLOW}📦 Deploying SIMPLE setup (Flask only, SQLite)${NC}"
    echo "   - Flask aplikace na portu 8000"
    echo "   - SQLite databáze"
    echo ""
    
    kubectl apply -f k8s/flask-simple-deployment.yaml
    
    echo ""
    echo -e "${GREEN}✅ Deployment dokončen!${NC}"
    echo ""
    echo "Sledujte status:"
    echo "  kubectl get pods"
    echo "  kubectl get services"
    echo ""
    echo "Získejte external IP:"
    echo "  kubectl get svc flask-app-simple"
    echo ""
    echo "Přístup:"
    echo "  http://<EXTERNAL-IP>:8000"
    ;;
    
  full)
    echo -e "${YELLOW}📦 Deploying FULL setup (Flask + Nginx + MariaDB)${NC}"
    echo "   - Flask aplikace (interní)"
    echo "   - Nginx reverse proxy (port 80)"
    echo "   - MariaDB databáze"
    echo ""
    
    # Vytvoření namespace
    echo -e "${BLUE}1/4 Creating namespace...${NC}"
    kubectl apply -f k8s/namespace.yaml
    
    # Deploy databáze
    echo -e "${BLUE}2/4 Deploying MariaDB...${NC}"
    kubectl apply -f k8s/mariadb-deployment.yaml
    
    # Počkáme na databázi
    echo -e "${BLUE}Waiting for database to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l component=database -n flask-app --timeout=120s || true
    
    # Deploy Flask aplikace
    echo -e "${BLUE}3/4 Deploying Flask application...${NC}"
    kubectl apply -f k8s/flask-deployment.yaml
    
    # Deploy Nginx
    echo -e "${BLUE}4/4 Deploying Nginx...${NC}"
    kubectl apply -f k8s/nginx-deployment.yaml
    
    echo ""
    echo -e "${GREEN}✅ Full deployment dokončen!${NC}"
    echo ""
    echo "Sledujte status:"
    echo "  kubectl get pods -n flask-app"
    echo "  kubectl get services -n flask-app"
    echo ""
    echo "Získejte external IP:"
    echo "  kubectl get svc nginx-service -n flask-app"
    echo ""
    echo "Logy:"
    echo "  kubectl logs -f deployment/flask-app -n flask-app"
    echo "  kubectl logs -f deployment/nginx -n flask-app"
    echo ""
    echo "Přístup:"
    echo "  http://<EXTERNAL-IP>"
    echo ""
    echo "Vytvoření admin účtu:"
    echo "  kubectl exec -it deployment/flask-app -n flask-app -- flask fab create-admin"
    ;;
    
  cleanup)
    echo -e "${RED}🗑️  Cleaning up all deployments...${NC}"
    echo ""
    
    read -p "Are you sure you want to delete everything? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
      echo "Cancelled."
      exit 0
    fi
    
    echo "Deleting simple deployment..."
    kubectl delete -f k8s/flask-simple-deployment.yaml --ignore-not-found=true
    
    echo "Deleting full deployment..."
    kubectl delete namespace flask-app --ignore-not-found=true
    
    echo ""
    echo -e "${GREEN}✅ Cleanup completed!${NC}"
    ;;
    
  *)
    echo -e "${RED}Usage: $0 [simple|full|cleanup]${NC}"
    echo ""
    echo "Modes:"
    echo "  simple  - Deploy Flask only (port 8000, SQLite)"
    echo "  full    - Deploy Flask + Nginx + MariaDB (port 80)"
    echo "  cleanup - Remove all deployments"
    exit 1
    ;;
esac
