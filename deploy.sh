#!/bin/bash

# Script de déploiement automatisé pour AWS Infrastructure
# Usage: ./deploy.sh [init|plan|apply|destroy|output]

set -e

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Vérifier que Terraform est installé
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform n'est pas installé!"
        echo ""
        echo "Installation:"
        echo "  Mac:     brew install terraform"
        echo "  Linux:   sudo apt-get install terraform"
        echo "  Windows: choco install terraform"
        echo ""
        exit 1
    fi
    
    TERRAFORM_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    print_success "Terraform installé (version: $TERRAFORM_VERSION)"
}

# Vérifier la configuration
check_config() {
    print_header "Vérification de la Configuration"
    
    # Vérifier que main.tf existe
    if [ ! -f "main.tf" ]; then
        print_error "Fichier main.tf introuvable!"
        exit 1
    fi
    
    # Vérifier que l'organisation est configurée
    if grep -q "VOTRE_ORGANISATION" main.tf; then
        print_error "Vous devez configurer votre organisation dans main.tf!"
        echo ""
        echo "Modifiez la ligne 11 de main.tf:"
        echo '  organization = "VOTRE_ORGANISATION"  # ⚠️ À REMPLACER'
        echo ""
        exit 1
    fi
    
    # Vérifier les variables Terraform Cloud
    print_warning "Assurez-vous d'avoir configuré les variables dans Terraform Cloud:"
    echo "  - student_number"
    echo "  - my_ip"
    echo "  - key_pair_name"
    echo "  - AWS_ACCESS_KEY_ID (Environment, Sensitive)"
    echo "  - AWS_SECRET_ACCESS_KEY (Environment, Sensitive)"
    echo ""
    
    read -p "Variables configurées? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Configurez d'abord vos variables dans Terraform Cloud"
        exit 0
    fi
    
    print_success "Configuration vérifiée"
}

# Initialisation
terraform_init() {
    print_header "Initialisation de Terraform"
    
    terraform init
    
    print_success "Initialisation terminée"
}

# Plan
terraform_plan() {
    print_header "Génération du Plan d'Exécution"
    
    terraform plan -out=tfplan
    
    print_success "Plan généré et sauvegardé dans tfplan"
}

# Apply
terraform_apply() {
    print_header "Déploiement de l'Infrastructure"
    
    print_warning "Vous êtes sur le point de créer des ressources AWS"
    print_warning "Cela peut entraîner des coûts (faibles avec Free Tier)"
    echo ""
    
    read -p "Continuer? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Déploiement annulé"
        exit 0
    fi
    
    terraform apply tfplan
    
    print_success "Infrastructure déployée!"
    echo ""
    
    # Afficher les informations importantes
    print_header "Informations de Déploiement"
    terraform output important_info
    
    echo ""
    print_success "Tests à effectuer:"
    echo "  1. Ouvrir le web_server_url dans votre navigateur"
    echo "  2. Tester la connexion SSH"
    echo "  3. Vérifier les buckets S3"
    echo ""
    print_warning "N'oubliez pas de détruire l'infrastructure après vos tests!"
    echo "  Commande: ./deploy.sh destroy"
}

# Destroy
terraform_destroy() {
    print_header "Destruction de l'Infrastructure"
    
    print_warning "Vous êtes sur le point de DÉTRUIRE toutes les ressources AWS"
    print_warning "Cette action est IRRÉVERSIBLE!"
    echo ""
    
    read -p "Êtes-vous SÛR? (tapez 'yes' pour confirmer) " -r
    echo
    if [[ ! $REPLY == "yes" ]]; then
        print_info "Destruction annulée"
        exit 0
    fi
    
    terraform destroy
    
    print_success "Infrastructure détruite"
    print_success "Vérifiez dans AWS Console que tout est bien supprimé"
}

# Output
terraform_output() {
    print_header "Outputs Terraform"
    
    terraform output
    
    echo ""
    print_info "Pour voir un output spécifique:"
    echo "  terraform output <nom_output>"
    echo ""
    echo "Exemples:"
    echo "  terraform output web_server_url"
    echo "  terraform output deployment_summary"
}

# Fonction d'aide
show_help() {
    cat << EOF
Usage: ./deploy.sh [COMMAND]

Commandes:
  init      Initialiser Terraform et se connecter à Terraform Cloud
  plan      Générer le plan d'exécution (dry-run)
  apply     Déployer l'infrastructure
  destroy   Détruire toute l'infrastructure
  output    Afficher les outputs
  all       Exécuter init + plan + apply (déploiement complet)
  help      Afficher cette aide

Exemples:
  ./deploy.sh init       # Première initialisation
  ./deploy.sh all        # Déploiement complet
  ./deploy.sh output     # Voir les informations de déploiement
  ./deploy.sh destroy    # Nettoyer toutes les ressources

Documentation complète: README.md
Guide rapide: QUICKSTART.md

EOF
}

# Menu principal
main() {
    print_header "INF1097 - Déploiement AWS avec Terraform Cloud"
    
    check_terraform
    
    case "${1:-help}" in
        init)
            check_config
            terraform_init
            ;;
        plan)
            terraform_plan
            ;;
        apply)
            terraform_apply
            ;;
        destroy)
            terraform_destroy
            ;;
        output)
            terraform_output
            ;;
        all)
            check_config
            terraform_init
            terraform_plan
            terraform_apply
            ;;
        help|*)
            show_help
            ;;
    esac
}

# Exécution
main "$@"
