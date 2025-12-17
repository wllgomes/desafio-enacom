# Desafio DevOps - Enacom

Solução Serverless para processamento de arquivos (CSV → JSON) utilizando AWS, Terraform e Python.

## 1. Justificativa Arquitetural
A escolha pelo **AWS Lambda** (Container Image) em detrimento do AWS Fargate/ECS baseia-se nos critérios de **custo** e **simplicidade** solicitados no desafio:

* **Custo-Eficiência:** O processamento de arquivos é uma tarefa esporádica. O Lambda cobra apenas por milissegundo de execução (custo zero quando ocioso), enquanto o Fargate exigiria provisionamento constante de recursos ou gestão complexa de capacidade.
* **Simplicidade (KISS):** Elimina a necessidade de gerenciar Clusters, Services e Load Balancers, reduzindo drasticamente a complexidade do código Terraform e a manutenção operacional.
* **Orientação a Eventos:** Integração nativa e instantânea com o S3 (`s3:ObjectCreated`), ideal para a arquitetura de "Gatilho → Processamento" requerida.

---

## 2. Instruções de Deploy

A infraestrutura é provisionada via Terraform. Devido à dependência circular (o Lambda exige a imagem Docker, e o Docker exige o repositório ECR), o deploy é feito em duas etapas.

### Pré-requisitos
* AWS CLI configurado (`aws configure`).
* Terraform e Docker instalados.

### Passo A: Criar Repositório (Bootstrap)
Crie o ECR primeiro para permitir o upload da imagem:

```bash
cd terraform
terraform init
terraform apply -target=module.compute.aws_ecr_repository.app_repo -auto-approve

Build & Push da Imagem

cd ../app

# 1. Login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 632244887993.dkr.ecr.us-east-1.amazonaws.com

# 2. Build & Push
docker build -t desafio-enacom .
docker tag desafio-enacom:latest 632244887993.dkr.ecr.us-east-1.amazonaws.com/enacom-desafio-repo:latest
docker push 632244887993.dkr.ecr.us-east-1.amazonaws.com/enacom-desafio-repo:latest

Deploy Final

Bash

cd ../terraform
terraform apply -auto-approve

Como Testar

1. Upload:

aws s3 cp teste.csv s3://enacom-csv-processor-enacom-desafio/input/tabela-fipe-historico-precos.csv

2. Validar: 

aws s3 ls s3://enacom-csv-processor-enacom-desafio/output/