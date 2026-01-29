# Bucket S3 principal pour stocker les fichiers de l'entreprise
resource "aws_s3_bucket" "corp_files" {
  bucket = "cloud-${var.student_number}-corp-files-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "CORP-FILES"
    Environment = "Training"
    Project     = "INF1097"
  }
}

# Génération d'un suffixe aléatoire pour garantir l'unicité du nom du bucket
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Versioning pour le bucket (bonne pratique)
resource "aws_s3_bucket_versioning" "corp_files" {
  bucket = aws_s3_bucket.corp_files.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption au repos (bonne pratique de sécurité)
resource "aws_s3_bucket_server_side_encryption_configuration" "corp_files" {
  bucket = aws_s3_bucket.corp_files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquer l'accès public par défaut
resource "aws_s3_bucket_public_access_block" "corp_files" {
  bucket = aws_s3_bucket.corp_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuration pour les rapports publics
# Création d'un préfixe/dossier pour les rapports publics
resource "aws_s3_object" "public_reports_folder" {
  bucket       = aws_s3_bucket.corp_files.id
  key          = "PublicReports/"
  content_type = "application/x-directory"
}

# Bucket pour les rapports publics (approche alternative avec bucket séparé)
resource "aws_s3_bucket" "public_reports" {
  bucket = "cloud-${var.student_number}-public-reports-${random_string.public_bucket_suffix.result}"

  tags = {
    Name        = "PublicReports"
    Environment = "Training"
    Project     = "INF1097"
    Access      = "Public"
  }
}

resource "random_string" "public_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Configuration d'accès public pour le bucket des rapports publics
resource "aws_s3_bucket_public_access_block" "public_reports" {
  bucket = aws_s3_bucket.public_reports.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Policy pour permettre la lecture publique
resource "aws_s3_bucket_policy" "public_reports" {
  bucket = aws_s3_bucket.public_reports.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public_reports.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_reports]
}

# Configuration du site web statique pour les rapports publics
resource "aws_s3_bucket_website_configuration" "public_reports" {
  bucket = aws_s3_bucket.public_reports.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Fichier index.html pour la liste des rapports publics
resource "aws_s3_object" "public_reports_index" {
  bucket       = aws_s3_bucket.public_reports.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-HTML
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Rapports Publics - INF1097</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f5f5f5;
            }
            .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 30px;
                border-radius: 10px;
                margin-bottom: 30px;
            }
            h1 {
                margin: 0;
            }
            .content {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .info-box {
                background: #e8f4f8;
                border-left: 4px solid #2196F3;
                padding: 15px;
                margin: 20px 0;
            }
            .warning-box {
                background: #fff3cd;
                border-left: 4px solid #ffc107;
                padding: 15px;
                margin: 20px 0;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>📊 Rapports Publics</h1>
            <p>Collège Boréal - INF1097 Réseautique III</p>
        </div>
        <div class="content">
            <h2>Bienvenue</h2>
            <p>Cette section contient les rapports publics accessibles via Internet.</p>
            
            <div class="info-box">
                <strong>ℹ️ Information:</strong> Ce bucket S3 est configuré pour un accès public en lecture seule.
            </div>
            
            <div class="warning-box">
                <strong>⚠️ Confidentialité:</strong> Les rapports financiers et autres données sensibles sont stockés dans un bucket privé séparé.
            </div>
            
            <h3>Structure du projet</h3>
            <ul>
                <li><strong>Bucket Public:</strong> Rapports accessibles à tous</li>
                <li><strong>Bucket Privé:</strong> Données confidentielles (rapports financiers)</li>
            </ul>
        </div>
    </body>
    </html>
  HTML
}

# Bucket privé pour les rapports financiers
resource "aws_s3_bucket" "financial_reports" {
  bucket = "cloud-${var.student_number}-financial-reports-${random_string.financial_bucket_suffix.result}"

  tags = {
    Name        = "FinancialReports"
    Environment = "Training"
    Project     = "Aws_infrastructure"
    Access      = "Private"
    Confidential = "true"
  }
}

resource "random_string" "financial_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Encryption renforcée pour les données financières
resource "aws_s3_bucket_server_side_encryption_configuration" "financial_reports" {
  bucket = aws_s3_bucket.financial_reports.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Bloquer complètement l'accès public pour les données financières
resource "aws_s3_bucket_public_access_block" "financial_reports" {
  bucket = aws_s3_bucket.financial_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning pour les données financières (audit trail)
resource "aws_s3_bucket_versioning" "financial_reports" {
  bucket = aws_s3_bucket.financial_reports.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Logging pour les accès aux données financières
resource "aws_s3_bucket" "logs" {
  bucket = "cloud-${var.student_number}-logs-${random_string.logs_bucket_suffix.result}"

  tags = {
    Name    = "AccessLogs"
    Project = "Aws_infrastructure"
  }
}

resource "random_string" "logs_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_logging" "financial_reports" {
  bucket = aws_s3_bucket.financial_reports.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "financial-access-logs/"
}
