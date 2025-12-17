import json
import os
import boto3
import logging
from processa_preco_medio import calcular_medias_por_ano_e_marca

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    logger.info("Iniciando processamento do evento S3")
    
    try:
        record = event['Records'][0]
        source_bucket = record['s3']['bucket']['name']
        source_key = record['s3']['object']['key']
        
        logger.info(f"Arquivo recebido: s3://{source_bucket}/{source_key}")
    except (KeyError, IndexError) as e:
        logger.error("Erro ao processar estrutura do evento: %s", e)
        return {"statusCode": 400, "body": "Evento invalido"}

    download_path = f"/tmp/{os.path.basename(source_key)}"
    output_json_path = f"/tmp/resultado.json"
    
    try:
        s3_client.download_file(source_bucket, source_key, download_path)
        logger.info("Download concluído.")

        resultado = calcular_medias_por_ano_e_marca(download_path)
        
        with open(output_json_path, "w", encoding="utf-8") as f:
            json.dump(resultado, f, ensure_ascii=False, indent=2)
            
        output_prefix = os.environ.get('OUTPUT_PREFIX', 'output/')
        destination_key = f"{output_prefix}resultado_{os.path.basename(source_key)}.json"
        
        s3_client.upload_file(output_json_path, source_bucket, destination_key)
        logger.info(f"Upload concluído em: s3://{source_bucket}/{destination_key}")

    except Exception as e:
        logger.error(f"Falha no processamento: {str(e)}")
        raise e
        
    return {
        'statusCode': 200,
        'body': json.dumps('Processamento realizado com sucesso!')
    }