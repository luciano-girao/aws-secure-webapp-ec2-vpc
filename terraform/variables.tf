# ==============================================================
# variables.tf - Variaveis do projeto
# ==============================================================

variable "aws_region" {
  description = "Regiao AWS onde os recursos serao provisionados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado como prefixo nos recursos)"
  type        = string
  default     = "aws-secure-webapp"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser: dev, staging ou prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block da sub-rede publica"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Nome do Key Pair SSH criado na AWS (sem extensao)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Seu IP publico no formato CIDR para acesso SSH (ex: 200.100.50.25/32)"
  type        = string
  default     = "0.0.0.0/0"
  # ATENCAO: Em producao, substitua pelo seu IP real para restringir acesso SSH
}
