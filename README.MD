# Desafio DevOps - Processamento Serverless de CSV para JSON

Este projeto implementa uma arquitetura **Serverless** na AWS para processar arquivos CSV da Tabela Fipe e convertê-los em JSON automaticamente.

A infraestrutura é 100% provisionada via **Terraform** e utiliza **AWS Lambda (Container Image)**, garantindo escalabilidade, baixo custo e facilidade de rollback.

## Arquitetura

A solução adota um padrão orientado a eventos (Event-Driven):

```mermaid
flowchart LR
    User([Usuário]) -- Upload .csv --> S3_In[S3 Bucket\n(Input Prefix)]
    S3_In -- Event: ObjectCreated --> Trigger[S3 Notification]
    Trigger -- Invokes --> Lambda[AWS Lambda\n(Container Image)]
    Lambda -- Reads CSV --> S3_In
    Lambda -- Processa & Converte --> Logic{Python App}
    Logic -- Writes JSON --> S3_Out[S3 Bucket\n(Output Prefix)]
    CloudWatch[CloudWatch Logs] -. Logs .- Lambda

    subgraph AWS Cloud
    S3_In
    S3_Out
    Lambda
    Trigger
    CloudWatch
    end
    
    style Lambda fill:#f9f,stroke:#333,stroke-width:2px
    style S3_In fill:#ff9,stroke:#333,stroke-width:2px