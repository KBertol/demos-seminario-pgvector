SET maintenance_work_mem = '512MB';

-- Funcao auxiliar: devolve UM vetor aleatorio com n numeros entre 0 e 1.
-- (random() e chamado de novo a cada execucao da funcao, entao cada linha fica diferente)
CREATE OR REPLACE FUNCTION vetor_aleatorio(n int) RETURNS vector AS $$
    SELECT array_agg(random())::vector FROM generate_series(1, n);
$$ LANGUAGE sql;

DROP TABLE IF EXISTS teste_indices CASCADE;
DROP TABLE IF EXISTS teste_ivf CASCADE;
DROP TABLE IF EXISTS teste_hnsw CASCADE;

-- Tabela base: 100 mil vetores de 128 dimensoes (sem indice = busca exata)
CREATE TABLE teste_indices (id bigserial PRIMARY KEY, embedding vector(128));
INSERT INTO teste_indices (embedding)
SELECT vetor_aleatorio(128) FROM generate_series(1, 100000);

-- Copias com os mesmos dados, uma para cada indice
CREATE TABLE teste_ivf AS SELECT * FROM teste_indices;
CREATE TABLE teste_hnsw AS SELECT * FROM teste_indices;

\timing on
-- IVFFlat: lists = linhas/1000 = 100 (criar DEPOIS de ter os dados)
CREATE INDEX idx_ivf ON teste_ivf USING ivfflat (embedding vector_l2_ops) WITH (lists = 100);

-- HNSW: parametros padrao (m=16, ef_construction=64)
CREATE INDEX idx_hnsw ON teste_hnsw USING hnsw (embedding vector_l2_ops) WITH (m=16, ef_construction=64);

-- estatísticas para o planner
ANALYZE teste_indices;
ANALYZE teste_ivf;
ANALYZE teste_hnsw;

-- Conferencia: deve mostrar 100000 linhas e ~100000 vetores distintos
SELECT count(*) AS linhas, count(DISTINCT embedding::text) AS vetores_distintos FROM teste_indices;
