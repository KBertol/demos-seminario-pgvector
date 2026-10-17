-- DEMO 3: TAMANHO, TEMPO E RECALL
\timing on

-- 1. Tamanho dos índices
SELECT pg_size_pretty(pg_relation_size('idx_ivf')) AS ivfflat_mb,
       pg_size_pretty(pg_relation_size('idx_hnsw')) AS hnsw_mb;

-- 2. Busca Exata (Sem Índice - Seq Scan)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id FROM teste_indices 
ORDER BY embedding <-> (SELECT embedding FROM teste_indices WHERE id=500) LIMIT 10;

-- 3. Busca Aproximada (IVFFlat)
SET ivfflat.probes = 10;
EXPLAIN (ANALYZE, BUFFERS)
SELECT id FROM teste_ivf 
ORDER BY embedding <-> (SELECT embedding FROM teste_ivf WHERE id=500) LIMIT 10;

-- 4. Busca Aproximada (HNSW)
SET hnsw.ef_search = 40;
EXPLAIN (ANALYZE, BUFFERS)
SELECT id FROM teste_hnsw 
ORDER BY embedding <-> (SELECT embedding FROM teste_hnsw WHERE id=500) LIMIT 10;

-- 5. Medição de Recall (HNSW)
-- 5a. Vizinhos EXATOS: desligamos o indice e buscamos de novo
SET enable_indexscan = off;
DROP TABLE IF EXISTS exato;
CREATE TEMP TABLE exato AS
SELECT id FROM teste_hnsw WHERE id <> 500
ORDER BY embedding <-> (SELECT embedding FROM teste_hnsw WHERE id = 500) LIMIT 10;
SET enable_indexscan = on;

-- 5b. Vizinhos APROXIMADOS, mudando os parametros (mais probes / ef_search = mais acertos)
SET ivfflat.probes = 1;
DROP TABLE IF EXISTS aprox;
CREATE TEMP TABLE aprox AS
SELECT id FROM teste_ivf WHERE id <> 500
ORDER BY embedding <-> (SELECT embedding FROM teste_ivf WHERE id = 500) LIMIT 10;
SELECT 'IVFFlat (probes = 1)' AS configuracao, count(*) AS acertos_de_10 FROM exato JOIN aprox USING (id);

SET ivfflat.probes = 100;
DROP TABLE IF EXISTS aprox;
CREATE TEMP TABLE aprox AS
SELECT id FROM teste_ivf WHERE id <> 500
ORDER BY embedding <-> (SELECT embedding FROM teste_ivf WHERE id = 500) LIMIT 10;
SELECT 'IVFFlat (probes = 100, examina tudo)' AS configuracao, count(*) AS acertos_de_10 FROM exato JOIN aprox USING (id);

SET hnsw.ef_search = 40;
DROP TABLE IF EXISTS aprox;
CREATE TEMP TABLE aprox AS
SELECT id FROM teste_hnsw WHERE id <> 500
ORDER BY embedding <-> (SELECT embedding FROM teste_hnsw WHERE id = 500) LIMIT 10;
SELECT 'HNSW (ef_search = 40)' AS configuracao, count(*) AS acertos_de_10 FROM exato JOIN aprox USING (id);

SET hnsw.ef_search = 400;
DROP TABLE IF EXISTS aprox;
CREATE TEMP TABLE aprox AS
SELECT id FROM teste_hnsw WHERE id <> 500
ORDER BY embedding <-> (SELECT embedding FROM teste_hnsw WHERE id = 500) LIMIT 10;
SELECT 'HNSW (ef_search = 400)' AS configuracao, count(*) AS acertos_de_10 FROM exato JOIN aprox USING (id);


