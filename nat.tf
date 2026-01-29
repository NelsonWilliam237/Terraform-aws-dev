# nat.tf - Configuration optionnelle NAT Gateway
# Ce fichier contient la configuration pour permettre aux sous-réseaux privés d'accéder à Internet
# ⚠️ ATTENTION: NAT Gateway coûte environ 35$/mois - désactivé par défaut

# Elastic IP pour le NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name    = "cloud-${var.student_number}-nat-eip"
    Project = "INF1097"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway dans le sous-réseau public
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_bastion.id

  tags = {
    Name    = "cloud-${var.student_number}-nat-gateway"
    Project = "INF1097"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route vers le NAT Gateway pour les sous-réseaux privés
resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

# Output pour le NAT Gateway
output "nat_gateway_id" {
  description = "ID du NAT Gateway (si activé)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : "NAT Gateway désactivé"
}

output "nat_gateway_ip" {
  description = "IP publique du NAT Gateway (si activé)"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : "NAT Gateway désactivé"
}
