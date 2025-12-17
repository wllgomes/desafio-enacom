# Desafio DevOps - Enacom 🚀

Solução **Serverless** para processamento de dados (CSV → JSON) utilizando AWS, Terraform e Python.

## 1. Por que essa Arquitetura?

Para este desafio, optei pelo **AWS Lambda (Container Image)** em vez do ECS Fargate. A decisão foi baseada puramente em eficiência operacional e de custos:

* **Zero Custo em Ociosidade:** Como o processamento é esporádico (orientado a eventos), não faz sentido pagar por containers rodando 24/7 no Fargate. O Lambda cobra apenas pelos milissegundos de execução.
* **Menos Overhead:** Eliminei a necessidade de gerenciar Clusters, Services ou Load Balancers. A infraestrutura fica mais limpa e o código Terraform muito mais simples de manter (KISS).
* **Event-Driven:** O trigger nativo do S3 (`s3:ObjectCreated`) conecta o upload ao processamento instantaneamente, sem precisar de filas ou configurações complexas de rede.

---

## 2. Guia de Deploy

Como o Terraform gerencia o Lambda, e o Lambda precisa da imagem Docker, existe uma pequena dependência circular. Para resolver isso de forma elegante, dividi o deploy em etapas.

### Pré-requisitos
* AWS CLI configurado (`aws configure`).
* Terraform e Docker instalados.

### Passo A: Bootstrap (Criar o ECR)
Primeiro, vamos criar apenas o repositório para ter onde subir a imagem.

```bash
cd terraform
terraform init
# Sobe apenas o módulo do ECR
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