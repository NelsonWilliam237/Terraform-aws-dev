# Outputs pour afficher les informations importantes après le déploiement

# VPC Outputs
output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "subnet_ids" {
  description = "IDs de tous les sous-réseaux"
  value = {
    public_bastion      = aws_subnet.public_bastion.id
    private_servers     = aws_subnet.private_servers.id
    private_databases   = aws_subnet.private_databases.id
    dmz_web            = aws_subnet.dmz_web.id
    private_apps       = aws_subnet.private_apps.id
  }
}

output "subnet_cidrs" {
  description = "Blocs CIDR de tous les sous-réseaux"
  value = {
    public_bastion      = aws_subnet.public_bastion.cidr_block
    private_servers     = aws_subnet.private_servers.cidr_block
    private_databases   = aws_subnet.private_databases.cidr_block
    dmz_web            = aws_subnet.dmz_web.cidr_block
    private_apps       = aws_subnet.private_apps.cidr_block
  }
}

# Internet Gateway Output
output "internet_gateway_id" {
  description = "ID de la passerelle Internet"
  value       = aws_internet_gateway.main.id
}

# Route Table Outputs
output "route_table_ids" {
  description = "IDs des tables de routage"
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private.id
  }
}

# EC2 Instance Outputs
output "web_server_id" {
  description = "ID de l'instance EC2 du serveur web"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "Adresse IP publique du serveur web"
  value       = aws_eip.web_server.public_ip
}

output "web_server_public_dns" {
  description = "DNS public du serveur web"
  value       = aws_instance.web_server.public_dns
}

output "web_server_private_ip" {
  description = "Adresse IP privée du serveur web"
  value       = aws_instance.web_server.private_ip
}

output "web_server_url" {
  description = "URL pour accéder au serveur web"
  value       = "http://${aws_eip.web_server.public_ip}"
}

# Security Group Output
output "web_server_security_group_id" {
  description = "ID du groupe de sécurité du serveur web"
  value       = aws_security_group.web_server.id
}

# S3 Bucket Outputs
output "s3_corp_files_bucket" {
  description = "Nom du bucket S3 principal pour les fichiers de l'entreprise"
  value       = aws_s3_bucket.corp_files.id
}

output "s3_corp_files_arn" {
  description = "ARN du bucket S3 principal"
  value       = aws_s3_bucket.corp_files.arn
}

output "s3_public_reports_bucket" {
  description = "Nom du bucket S3 pour les rapports publics"
  value       = aws_s3_bucket.public_reports.id
}

output "s3_public_reports_url" {
  description = "URL du site web S3 pour les rapports publics"
  value       = "http://${aws_s3_bucket.public_reports.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}

output "s3_financial_reports_bucket" {
  description = "Nom du bucket S3 privé pour les rapports financiers"
  value       = aws_s3_bucket.financial_reports.id
}

output "s3_financial_reports_arn" {
  description = "ARN du bucket S3 pour les rapports financiers"
  value       = aws_s3_bucket.financial_reports.arn
}

output "s3_logs_bucket" {
  description = "Nom du bucket S3 pour les logs d'accès"
  value       = aws_s3_bucket.logs.id
}

# Résumé de la configuration
output "deployment_summary" {
  description = "Résumé du déploiement"
  value = {
    region              = var.aws_region
    vpc_name           = "cloud-${var.student_number}-VPC"
    web_server_url     = "http://${aws_eip.web_server.public_ip}"
    public_reports_url = "http://${aws_s3_bucket.public_reports.bucket}.s3-website-${var.aws_region}.amazonaws.com"
    student_number     = var.student_number
  }
}

# Instructions pour se connecter au serveur
output "ssh_connection_command" {
  description = "Commande pour se connecter au serveur web via SSH"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${aws_eip.web_server.public_ip}"
}

# Informations importantes pour le rapport
output "important_info" {
  description = "Informations importantes à inclure dans votre rapport"
  value = <<-EOT
    ========================================
    INFORMATIONS DE DÉPLOIEMENT - INF1097
    ========================================
    
    VPC:
    - Nom: cloud-${var.student_number}-VPC
    - CIDR: ${aws_vpc.main.cidr_block}
    - ID: ${aws_vpc.main.id}
    - Région: ${var.aws_region}
    
    SERVEUR WEB:
    - URL: http://${aws_eip.web_server.public_ip}
    - IP Publique: ${aws_eip.web_server.public_ip}
    - IP Privée: ${aws_instance.web_server.private_ip}
    - Instance ID: ${aws_instance.web_server.id}
    
    STOCKAGE S3:
    - Rapports Publics: http://${aws_s3_bucket.public_reports.bucket}.s3-website-${var.aws_region}.amazonaws.com
    - Bucket Privé (Financier): ${aws_s3_bucket.financial_reports.id}
    
    SOUS-RÉSEAUX:
    - net-public-bastion: ${aws_subnet.public_bastion.cidr_block}
    - net-private-servers: ${aws_subnet.private_servers.cidr_block}
    - net-private-databases: ${aws_subnet.private_databases.cidr_block}
    - net-dmz-web: ${aws_subnet.dmz_web.cidr_block}
    - net-private-apps: ${aws_subnet.private_apps.cidr_block}
    
    ========================================
  EOT
}
