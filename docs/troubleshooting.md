# Troubleshooting

Guia de solucao de problemas comuns durante o deploy e operacao deste projeto.

---

## Problemas no Terraform

### `terraform init` falha com erro de provider

**Sintoma**: `Error: Failed to install provider`

**Causa**: sem acesso a internet ou versao do Terraform desatualizada.

**Solucao**:
```bash
# Verifique a versao do Terraform
terraform version
# Deve ser >= 1.7.0

# Verifique conexao com internet
curl -I https://registry.terraform.io
```

---

### `terraform apply` falha com `InvalidClientTokenId`

**Sintoma**: `Error: InvalidClientTokenId: The security token included in the request is invalid`

**Causa**: AWS CLI nao esta configurado ou as credenciais estao invalidas/expiradas.

**Solucao**:
```bash
# Verifique a configuracao do AWS CLI
aws sts get-caller-identity

# Se falhar, reconfigure:
aws configure
# Informe: Access Key ID, Secret Access Key, Regiao (us-east-1), formato (json)
```

---

### `Error: BucketAlreadyExists`

**Sintoma**: falha ao criar o bucket S3 por conflito de nome.

**Causa**: o nome do bucket ja existe globalmente na AWS (mesmo com o sufixo `random_id`).

**Solucao**:
```bash
# Destrua e recrie o random_id
terraform destroy -target=random_id.bucket_suffix
terraform apply
```

---

### `Error: VpcLimitExceeded`

**Sintoma**: `You have reached the limit of VPCs allowed per region`

**Causa**: o limite padrao da AWS e de 5 VPCs por regiao.

**Solucao**:
- Acesse o AWS Console -> VPC
- Delete VPCs nao utilizadas
- Ou abra um ticket no AWS Support para aumentar o limite

---

## Problemas de Acesso

### Nao consigo acessar o site via HTTP

**Sintoma**: `http://IP_DA_EC2` nao responde no browser.

**Checklist**:
1. A instancia EC2 esta com status `running`?
   ```bash
   aws ec2 describe-instances --filters "Name=tag:Project,Values=aws-secure-webapp"
   ```
2. O Security Group tem a porta 80 liberada para `0.0.0.0/0`?
3. O Apache foi iniciado corretamente?
   ```bash
   # Conecte via SSH
   ssh -i sua-chave.pem ec2-user@IP_DA_EC2

   # Verifique o status do httpd
   systemctl status httpd

   # Se nao estiver rodando:
   sudo systemctl start httpd
   ```
4. O User Data foi executado? Verifique os logs:
   ```bash
   sudo cat /var/log/cloud-init-output.log
   ```

---

### SSH: `Permission denied (publickey)`

**Sintoma**: nao consigo conectar via SSH na EC2.

**Causa**: Key Pair incorreto ou permissao do arquivo de chave errada.

**Solucao**:
```bash
# Corrija a permissao da chave
chmod 400 sua-chave.pem

# Verifique o usuario correto (Amazon Linux 2023 = ec2-user)
ssh -i sua-chave.pem ec2-user@IP_DA_EC2

# Certifique-se que o Key Pair definido em variables.tf e o mesmo que voce tem localmente
```

---

### SSH: `Connection refused` ou timeout

**Sintoma**: SSH nao conecta mesmo com a chave correta.

**Causa mais provavel**: porta 22 bloqueada no Security Group ou o IP do SSH nao corresponde ao seu IP atual.

**Solucao**:
```bash
# Descubra seu IP publico atual
curl ifconfig.me

# Compare com o valor em variables.tf (ssh_allowed_cidr)
# Se diferente, atualize e aplique novamente:
terraform apply -var="ssh_allowed_cidr=SEU_IP_ATUAL/32"
```

---

## Problemas com IAM e S3

### EC2 nao consegue listar objetos no S3

**Sintoma**: `An error occurred (AccessDenied) when calling the ListObjectsV2 operation`

**Causa**: a IAM Role nao esta associada a instancia ou a politica nao foi aplicada.

**Solucao**:
```bash
# Dentro da EC2, verifique se a Role esta associada
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Deve retornar o nome da Role criada pelo Terraform
# Se vazio, o IAM Instance Profile nao foi associado corretamente
# Verifique: aws iam list-instance-profiles
```

---

## Limpeza de Recursos

### Como destruir tudo e evitar cobranças?

```bash
cd terraform/
terraform destroy

# Confirme digitando 'yes' quando solicitado
# Todos os recursos criados pelo Terraform serao removidos
```

**Recursos que NAO sao destruidos automaticamente**:
- Key Pairs criados manualmente no Console AWS
- Snapshots de EBS (se houver)
- Logs do CloudWatch (se configurados manualmente)

---

## Referências Uteis

- [AWS EC2 Troubleshooting](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-troubleshoot.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Troubleshooting](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Troubleshooting.html)
- [IAM Troubleshooting](https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot.html)
