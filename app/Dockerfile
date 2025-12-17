FROM public.ecr.aws/lambda/python:3.12

LABEL maintainer="William Gomes williamllgoomes@gmail.com"
LABEL description="Processador de CSV Tabela Fipe para JSON"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install --no-cache-dir -r requirements.txt

COPY handler.py ${LAMBDA_TASK_ROOT}
COPY processa_preco_medio.py ${LAMBDA_TASK_ROOT}


CMD [ "handler.lambda_handler" ]
