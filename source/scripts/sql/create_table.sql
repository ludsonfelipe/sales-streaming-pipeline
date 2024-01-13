GRANT SELECT ON ALL TABLES IN SCHEMA public TO "pipeline";
GRANT USAGE ON SCHEMA public TO "pipeline";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "pipeline";
ALTER USER "pipeline" WITH REPLICATION;

CREATE TABLE vendas (
    id_venda SERIAL PRIMARY KEY,
    id_cliente INT,
    produto VARCHAR(255),
    quantidade INT,
    preco DECIMAL(10, 2),
    moeda VARCHAR(3),
    data DATE
);