import psycopg2
import os
from faker import Faker
import random
from datetime import datetime, timedelta
import json
from google.cloud import pubsub_v1

# Configurações do banco de dados
address = open('./python/address.txt').read().strip()
db_params = {
    'dbname': os.getenv('POSTGRES_DATABASE'),
    'user': os.getenv('POSTGRES_USERNAME'),
    'password': os.getenv('POSTGRES_PASSWORD'),
    'host': address,
    'port': os.getenv('POSTGRES_PORT')
}

project = os.getenv('PUBSUB_PROJECT')
topic = os.getenv('PUBSUB_TOPIC')

print(db_params)

def get_connection(db_params):
    return psycopg2.connect(**db_params)

def execute_query_from_file(file_path, conn):
    try:
        with open(file_path) as file:
            query = file.read()

        with conn.cursor() as cursor:
            cursor.execute(query)
            conn.commit()

        print(f"Consulta em {file_path} executada com sucesso.")

    except psycopg2.Error as e:
        print(f"Erro ao executar consulta em {file_path}: {e}")

def create_data():
    produto = random.choice(['Produto A', 'Produto B', 'Produto C', 'Produto D', 'Produto E', 'Produto F', 'Produto G', 'Produto H'])
    id_cliente = random.randint(1, 100)
    quantidade = random.randint(1, 10)
    preco = round(random.uniform(10.0, 100.0), 2)
    moeda = random.choice(['USD', 'EUR', 'BRL'])
    data = (datetime.now() - timedelta(days=random.randint(1, 365))).date()
    return produto, id_cliente, quantidade, preco, moeda, data

def ingest_postgres(conn):
    produto, id_cliente, quantidade, preco, moeda, data = create_data()
    with conn.cursor() as cursor:
        cursor.execute("""
            INSERT INTO vendas (id_cliente, produto, quantidade, preco, moeda, data)
            VALUES (%s, %s, %s, %s, %s, %s);
        """, (id_cliente, produto, quantidade, preco, moeda, data))

        conn.commit()

def ingest_pubsub(id_venda, project, topic):
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project, topic)

    produto, id_cliente, quantidade, preco, moeda, data = create_data()

    data = {
        'id_venda':id_venda,
           'id_cliente':id_cliente,
           'produto':produto, 
           'quantidade':quantidade, 
           'preco':preco, 
           'moeda':moeda, 
           'data':data
           }

    json_message = json.dumps(data)
    bytestring_message = json_message.encode("utf-8")
    sent = publisher.publish(topic_path, bytestring_message)
    sent.result()

def main():
    try:
        # Conectar ao PostgreSQL
        conn = get_connection(db_params)

        # Executar consultas
        execute_query_from_file('./sql/create_table.sql', conn)
        execute_query_from_file('./sql/publication.sql', conn)
        execute_query_from_file('./sql/replication.sql', conn)

        for id in range(1001, 2000):
            ingest_postgres(conn)
            ingest_pubsub(id_venda=id, project=project, topic=topic)

    finally:
        # Fechar a conexão
        if conn:
            conn.close()

if __name__ == "__main__":
    main()
