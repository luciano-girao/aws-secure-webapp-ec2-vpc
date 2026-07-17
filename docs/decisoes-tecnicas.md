# Decisoes Tecnicas

Este documento registra as principais decisoes tomadas durante o projeto, com a justificativa de cada escolha. Isso demonstra raciocinio tecnico e maturidade de engenharia.

---

## 1. Por que usar VPC dedicada em vez da VPC default?

**Decisao**: criar uma VPC exclusiva para o projeto.

**Motivo**: a VPC default da AWS e compartilhada e nao deve ser usada em ambientes de trabalho reais. Criar uma VPC dedicada permite:
- Controle total sobre o espaco de IPs (CIDR)
- Segmentacao clara entre subnets publicas e privadas
- Facilidade de auditoria e exclusao limpa dos recursos
- Reproductibilidade: Terraform pode recriar tudo do zero

---

## 2. Por que EC2 na sub-rede publica e nao privada?

**Decisao**: EC2 na subnet publica, com acesso direto via Internet Gateway.

**Motivo**: simplicidade proposital para o escopo deste projeto de portfólio.

**Trade-off consciente**: em producao, o correto seria:
- EC2 em subnet privada
- Application Load Balancer (ALB) na subnet publica
- NAT Gateway para saida de internet da EC2

**Proximo passo documentado**: mover EC2 para subnet privada esta listado nos "Proximos Passos" do README.

---

## 3. Por que Terraform e nao CloudFormation?

**Decisao**: usar Terraform (HashiCorp) como ferramenta de IaC.

**Motivo**:
- Terraform e multi-cloud (AWS, GCP, Azure) — habilidade mais transferivel no mercado
- Sintaxe HCL e mais legivel que YAML/JSON do CloudFormation
- Ecossistema rico de modulos e providers
- Estado gerenciado facilita rastreamento de mudancas
- Habilidade com alta demanda no mercado de trabalho

---

## 4. Por que IAM Role e nao Access Keys na instancia?

**Decisao**: usar IAM Instance Profile (Role) para autenticacao da EC2 com servicos AWS.

**Motivo**: Access Keys (chaves de acesso) hardcoded em instancias ou codigo sao uma das principais causas de vazamentos de seguranca na nuvem. IAM Roles:
- Nao expoe credenciais em codigo ou variaveis de ambiente
- Rotacao automatica de tokens pelo SDK da AWS
- Auditavel via AWS CloudTrail
- Segue o principio do menor privilegio (apenas S3ReadOnly)

---

## 5. Por que S3 com acesso publico completamente bloqueado?

**Decisao**: `block_public_acls = true`, `block_public_policy = true`, etc.

**Motivo**: buckets S3 publicos acidentalmente configurados sao uma das principais causas de vazamentos de dados em cloud. Bloqueio total e o default correto; acesso deve ser explicitamente concedido apenas quando necessario e para o minimo de recursos possivel.

---

## 6. Por que suffix aleatorio no nome do bucket S3?

**Decisao**: nome do bucket gerado com `random_id` como sufixo.

**Motivo**: nomes de buckets S3 sao globalmente unicos na AWS. Sem sufixo, haveria conflito ao tentar recriar o ambiente ou usar o mesmo nome em outra conta. O `random_id` garante unicidade sem comprometer a reprodutibilidade.

---

## 7. Por que Amazon Linux 2023 e nao Ubuntu?

**Decisao**: usar Amazon Linux 2023 como AMI da instancia.

**Motivo**:
- AMI otimizada para AWS (menor custo, melhor integracao com servicos AWS)
- Suporte oficial da AWS com patches de seguranca
- Integrada com SSM Agent por padrao (util para acesso sem SSH no futuro)
- Mais comum em ambientes corporativos que usam AWS

---

## 8. Por que Security Group com SSH em vez de SSM Session Manager?

**Decisao**: SSH via Security Group com IP restrito para este projeto.

**Motivo**: demonstra conhecimento de Security Groups e restricao de acesso por IP.

**Evolucao prevista**: em producao, o correto e usar AWS Systems Manager Session Manager para acesso a instancias, eliminando completamente a necessidade de abrir a porta 22, sem precisar de Key Pair SSH.

---

## Resumo das Decisoes

| Decisao | Escolha | Alternativa Considerada |
|---|---|---|
| IaC | Terraform | CloudFormation |
| Rede | VPC dedicada | VPC default |
| Subnet EC2 | Publica (trade-off consciente) | Privada + ALB |
| Autenticacao EC2 | IAM Role | Access Keys |
| S3 | Privado total | Publico com policy |
| Acesso | SSH restrito | SSM Session Manager |
| AMI | Amazon Linux 2023 | Ubuntu 22.04 |
