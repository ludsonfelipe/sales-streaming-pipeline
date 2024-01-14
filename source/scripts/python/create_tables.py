import psycopg2
import os

# Configurações do banco de dados
address = open('./python/address.txt').read().strip()
db_params = {
    'dbname': os.getenv('POSTGRES_DATABASE'),
    'user': os.getenv('POSTGRES_USERNAME'),
    'password': os.getenv('POSTGRES_PASSWORD'),
    'host': address,
    'port': os.getenv('POSTGRES_PORT')
}
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

def main():
    try:
        # Conectar ao PostgreSQL
        conn = get_connection(db_params)

        # Executar consultas
        execute_query_from_file('./sql/create_table.sql', conn)
        execute_query_from_file('./sql/publication.sql', conn)
        execute_query_from_file('./sql/replication.sql', conn)


    finally:
        # Fechar a conexão
        if conn:
            conn.close()

if __name__ == "__main__":
    main()
