# ==============================================================
# outputs.tf - Valores exportados apos o apply
# ==============================================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da sub-rede publica"
  value       = aws_subnet.public.id
}

output "ec2_public_ip" {
  description = "IP publico da instancia EC2 (acesse via http://IP)"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "DNS publico da instancia EC2"
  value       = aws_instance.web.public_dns
}

output "ec2_instance_id" {
  description = "ID da instancia EC2"
  value       = aws_instance.web.id
}

output "security_group_id" {
  description = "ID do Security Group da aplicacao web"
  value       = aws_security_group.web.id
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.artifacts.bucket
}

output "iam_role_arn" {
  description = "ARN da IAM Role associada a EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "webapp_url" {
  description = "URL para acessar a aplicacao web"
  value       = "http://${aws_instance.web.public_ip}"
}
