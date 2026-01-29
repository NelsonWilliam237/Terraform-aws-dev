# Architecture Diagram - INF1097 AWS Infrastructure

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                         INTERNET (0.0.0.0/0)                               │
│                                                                             │
└─────────────────────┬───────────────────────────────────────────────────────┘
                      │
                      │
        ┌─────────────▼──────────────┐
        │   Internet Gateway (IGW)   │
        │  cloud-[number]-IGW       │
        └─────────────┬──────────────┘
                      │
┌─────────────────────▼──────────────────────────────────────────────────────┐
│                                                                            │
│                    VPC: cloud-[number]-VPC                                │
│                    CIDR: 10.145.0.0/16                                     │
│                    Region: eu-west-2 (London)                              │
│                                                                            │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    PUBLIC ROUTE TABLE                              │   │
│  │               Route: 0.0.0.0/0 → IGW                               │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                          │                    │                            │
│  ┌───────────────────────▼─────┐   ┌─────────▼──────────────────┐         │
│  │  net-public-bastion         │   │  net-dmz-web               │         │
│  │  10.145.10.0/24            │   │  10.145.60.0/27            │         │
│  │  AZ: eu-west-2a            │   │  AZ: eu-west-2c            │         │
│  │  [PUBLIC]                   │   │  [PUBLIC]                  │         │
│  │                             │   │                            │         │
│  │  • Bastion Host (future)    │   │  • EC2 Web Server          │         │
│  │  • Jump Server              │   │    (t2.micro, AL2023)      │         │
│  │                             │   │  • Apache HTTP             │         │
│  │                             │   │  • Elastic IP              │         │
│  │                             │   │  • Security Group:         │         │
│  │                             │   │    - SSH: your-ip/32       │         │
│  │                             │   │    - HTTP: 0.0.0.0/0       │         │
│  └─────────────────────────────┘   └────────────────────────────┘         │
│                                                                            │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    PRIVATE ROUTE TABLE                             │   │
│  │         (No direct internet access - local routes only)            │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                 │                    │                    │                │
│  ┌──────────────▼──────┐  ┌─────────▼──────┐  ┌─────────▼──────────┐     │
│  │ net-private-servers │  │ net-private-dbs │  │ net-private-apps   │     │
│  │ 10.145.200.0/24    │  │ 10.145.55.0/26  │  │ 10.145.100.0/24    │     │
│  │ AZ: eu-west-2b     │  │ AZ: eu-west-2a  │  │ AZ: eu-west-2b     │     │
│  │ [PRIVATE]          │  │ [PRIVATE]       │  │ [PRIVATE]          │     │
│  │                    │  │                 │  │                    │     │
│  │ • App Servers      │  │ • RDS Database  │  │ • Backend Apps     │     │
│  │ • Internal APIs    │  │ • ElastiCache   │  │ • Processing       │     │
│  │                    │  │                 │  │                    │     │
│  └────────────────────┘  └─────────────────┘  └────────────────────┘     │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                          S3 STORAGE LAYER                                   │
│                                                                             │
│  ┌─────────────────────────────┐  ┌──────────────────────────────────┐    │
│  │  S3: Public Reports         │  │  S3: Financial Reports           │    │
│  │  [PUBLIC READ ACCESS]       │  │  [PRIVATE - ENCRYPTED]           │    │
│  │                             │  │                                  │    │
│  │  • Website Configuration    │  │  • Encryption: AES-256           │    │
│  │  • Public Policy            │  │  • Versioning Enabled            │    │
│  │  • Access: Internet         │  │  • Block All Public Access       │    │
│  │  • Reports & Docs           │  │  • Access Logging                │    │
│  │                             │  │  • Financial Data                │    │
│  └─────────────────────────────┘  └──────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  S3: Access Logs                                                    │   │
│  │  [LOGGING BUCKET]                                                   │   │
│  │  • Tracks all access to Financial Reports                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Flux de Trafic

### 1. Accès Internet vers Serveur Web

```
Internet → IGW → Public Route Table → net-dmz-web → EC2 Web Server (Port 80)
```

### 2. SSH vers Serveur Web

```
Your IP → IGW → Public Route Table → net-dmz-web → EC2 Web Server (Port 22)
                                                    [Security Group Filter]
```

### 3. Accès aux Rapports Publics S3

```
Internet → S3 Public Reports Bucket → HTML Pages (Public Access)
```

### 4. Accès aux Données Financières

```
AWS Console/IAM User → S3 Financial Reports (Authenticated Only)
```

## Configuration des Sous-réseaux

| Nom                 | CIDR            | AZ         | Type    | Route Internet |
| ------------------- | --------------- | ---------- | ------- | -------------- |
| net-public-bastion  | 10.145.10.0/24  | eu-west-2a | Public  | via IGW        |
| net-dmz-web         | 10.145.60.0/27  | eu-west-2c | Public  | via IGW        |
| net-private-servers | 10.145.200.0/24 | eu-west-2b | Private | None           |
| net-private-dbs     | 10.145.55.0/26  | eu-west-2a | Private | None           |
| net-private-apps    | 10.145.100.0/24 | eu-west-2b | Private | None           |

## Groupes de Sécurité

### Web-Server-SG

```
Inbound Rules:
  • SSH (22)  : Source = Your IP (/32)
  • HTTP (80) : Source = 0.0.0.0/0 (Internet)

Outbound Rules:
  • All Traffic : Destination = 0.0.0.0/0
```

## Zones de Disponibilité (AZ)

```
eu-west-2a:
  • net-public-bastion
  • net-private-databases

eu-west-2b:
  • net-private-servers
  • net-private-apps

eu-west-2c:
  • net-dmz-web (Web Server)
```

## Points de Sécurité Clés

1. **Isolation Réseau**:
   - Sous-réseaux publics: Accès direct Internet
   - Sous-réseaux privés: Aucun accès Internet direct

2. **Contrôle d'Accès**:
   - SSH limité à votre IP uniquement
   - HTTP ouvert pour les visiteurs web

3. **Données Sensibles**:
   - Rapports financiers: Bucket S3 privé avec encryption
   - Access logging activé pour audit

4. **Haute Disponibilité**:
   - Distribution sur 3 AZ différentes
   - Résilience en cas de panne d'une AZ

## Légende

```
┌───┐
│   │  Conteneur/Ressource
└───┘

  │    Connexion réseau
  ▼    Direction du flux

[PUBLIC]   Accès Internet autorisé
[PRIVATE]  Pas d'accès Internet direct
```
