# AWS Infrastructure avec Terraform Cloud

## 📋 Description du Projet

Ce projet déploie une infrastructure AWS complète  
L'infrastructure comprend :

- **VPC personnalisé** avec 5 sous-réseaux (publics et privés)
- **Serveur Web EC2** avec Apache dans une zone DMZ
- **Stockage S3** avec séparation des données publiques et confidentielles
- **Groupes de sécurité** configurés selon les meilleures pratiques

## 🏗️ Architecture

```
cloud-[number]-VPC (10.145.0.0/16)
│
├── Sous-réseaux Publics:
│   ├── net-public-bastion (10.145.10.0/24) - AZ: eu-west-2a
│   └── net-dmz-web (10.145.60.0/27) - AZ: eu-west-2c [Serveur Web]
│
├── Sous-réseaux Privés:
│   ├── net-private-servers (10.145.200.0/24) - AZ: eu-west-2b
│   ├── net-private-databases (10.145.55.0/26) - AZ: eu-west-2a
│   └── net-private-apps (10.145.100.0/24) - AZ: eu-west-2b
│
├── Internet Gateway (IGW)
│   └── Route: 0.0.0.0/0 → IGW (pour sous-réseaux publics)
│
└── Ressources:
    ├── EC2 Instance (t2.micro, Amazon Linux 2023)
    ├── S3 Buckets:
    │   ├── Public Reports (accès web)
    │   ├── Financial Reports (privé)
    │   └── Access Logs
    └── Security Groups
```

## 📦 Prérequis

### 1. Compte AWS

- Créez un compte AWS (offre gratuite disponible)
- Notez votre Access Key ID et Secret Access Key

### 2. Compte Terraform Cloud

- Créez un compte sur [app.terraform.io](https://app.terraform.io)
- Créez une organisation
- Créez un workspace nommé `Terraform-aws-dev`

### 3. Paire de clés SSH

- Créez une paire de clés dans AWS Console:
  - Région: **eu-west-2 (London)**
  - EC2 → Key Pairs → Create key pair
  - Format: `.pem` pour Linux/Mac, `.ppk` pour Windows
  - Sauvegardez le fichier en lieu sûr

### 4. Votre adresse IP

- Trouvez votre adresse IP publique: [whatismyipaddress.com](https://whatismyipaddress.com/)
- Notez-la au format `x.x.x.x/32`

## 🚀 Installation et Configuration

### Étape 1: Cloner/Télécharger les fichiers

```bash
# Si vous utilisez Git
git clone <votre-repo>
cd <votre-repo>

# Ou téléchargez les fichiers directement
```

### Étape 2: Configuration de Terraform Cloud

1. **Connectez-vous à Terraform Cloud** : [app.terraform.io](https://app.terraform.io)

2. **Créez un workspace**:
   - Type: "API-driven workflow"
   - Nom: `Terraform-aws-dev`

3. **Configurez les variables dans Terraform Cloud**:

   **Variables Terraform** (dans l'onglet Variables du workspace):

   ```
   my_ip = "VOTRE_IP/32"
   key_pair_name = "NOM_DE_VOTRE_CLE"
   ```

   **Variables d'environnement** (sensibles):

   ```
   AWS_ACCESS_KEY_ID = "votre_access_key"         [Sensitive]
   AWS_SECRET_ACCESS_KEY = "votre_secret_key"     [Sensitive]
   ```

### Étape 4: Déploiement

```bash
# Initialisez Terraform
terraform init

# Vérifiez le plan d'exécution
terraform plan

# Déployez l'infrastructure
terraform apply

# Confirmez avec "yes" quand demandé
```

## 📊 Vérification du Déploiement

Après le déploiement, Terraform affichera des outputs importants:

```
Outputs:

web_server_url = "http://X.X.X.X"
s3_public_reports_url = "http://bucket-name.s3-website-eu-west-2.amazonaws.com"
ssh_connection_command = "ssh -i ~/.ssh/your-key.pem ec2-user@X.X.X.X"
```

### Tests à effectuer:

1. **Serveur Web**:

   ```bash
   # Ouvrez dans votre navigateur
   http://<web_server_ip>

   # Vous devriez voir la page d'accueil personnalisée
   ```

2. **Connexion SSH**:

   ```bash
   ssh -i /path/to/your-key.pem ec2-user@<web_server_ip>
   ```

3. **Rapports Publics S3**:

   ```bash
   # Ouvrez l'URL S3 dans votre navigateur
   # Les fichiers doivent être accessibles publiquement
   ```

4. **Rapports Financiers (Privés)**:
   ```bash
   # Essayez d'accéder - devrait être bloqué
   # Accessible uniquement via AWS Console avec authentification
   ```

## 📁 Structure des Fichiers

```
.
├── main.tf                    # Configuration VPC et réseaux
├── ec2.tf                     # Configuration serveur web EC2
├── s3.tf                      # Configuration buckets S3
├── variables.tf               # Définition des variables
├── outputs.tf                 # Outputs après déploiement
├── terraform.tfvars.example   # Exemple de fichier de variables
├── .gitignore                 # Fichiers à ignorer par Git
└── README.md                  # Ce fichier
```

## 🔒 Sécurité

### Groupes de Sécurité

**Web-Server-SG**:

- Port 22 (SSH): Votre IP uniquement
- Port 80 (HTTP): Internet (0.0.0.0/0)
- Sortie: Tout autorisé

### S3 Buckets

- **Public Reports**: Accès lecture publique
- **Financial Reports**: Complètement privé
- **Encryption**: AES-256 activé sur tous les buckets
- **Versioning**: Activé pour audit trail
- **Access Logs**: Activés pour traçabilité

## 💰 Gestion des Coûts

### Ressources Gratuites (Offre AWS Free Tier):

- EC2 t2.micro: 750 heures/mois
- S3: 5 GB stockage + requêtes limitées
- Transfert de données: 15 GB/mois

### Ressources Payantes (désactivées par défaut):

- NAT Gateway: ~35$/mois (désactivé)
- Elastic IP non attachée: ~0.005$/heure

### **⚠️ IMPORTANT**: Détruisez l'infrastructure après utilisation!

```bash
terraform destroy
```

## 🧹 Nettoyage (Après le Projet)

Pour éviter les frais, détruisez toutes les ressources:

```bash
# Supprimez toute l'infrastructure
terraform destroy

# Confirmez avec "yes"

# Vérifiez dans AWS Console que tout est supprimé:
# - EC2 Instances
# - VPC et sous-réseaux
# - S3 Buckets (videz-les d'abord si nécessaire)
# - Elastic IPs
```

## 📚 Ressources Utiles

- [Documentation Terraform AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [AWS Free Tier](https://aws.amazon.com/free/)

**⚠️ RAPPEL IMPORTANT**: N'oubliez pas de détruire votre infrastructure avec `terraform destroy` après avoir terminé vos tests pour éviter les frais AWS!
