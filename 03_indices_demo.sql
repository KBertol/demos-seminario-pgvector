-- DEMO 3: TAMANHO, TEMPO E RECALL
\timing on

-- 1. Tamanho dos índices
SELECT pg_size_pretty(pg_relation_size('idx_ivf')) AS ivfflat_mb,
       pg_size_pretty(pg_relation_size('idx_hnsw')) AS hnsw_mb;


-- 2. Busca exata (sem índice vetorial: Seq Scan)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id
FROM teste_indices
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_indices
    WHERE id = 500
)
LIMIT 10;


-- 3. Busca aproximada (IVFFlat)
SET ivfflat.probes = 10;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id
FROM teste_ivf
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_ivf
    WHERE id = 500
)
LIMIT 10;


-- 4. Busca aproximada (HNSW)
SET hnsw.ef_search = 40;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id
FROM teste_hnsw
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_hnsw
    WHERE id = 500
)
LIMIT 10;

-- Consulta HNSW com ef_search = 400
SET hnsw.ef_search = 400;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id
FROM teste_hnsw
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_hnsw
    WHERE id = 500
)
LIMIT 10;


-- 5. Medição de Recall (IVFFlat e HNSW)

-- Busca exata usada como referência
SET enable_indexscan = off;

DROP TABLE IF EXISTS exato;

CREATE TEMP TABLE exato AS
SELECT id
FROM teste_indices
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_indices
    WHERE id = 500
)
LIMIT 10;

SET enable_indexscan = on;


-- IVFFlat: probes = 1
SET ivfflat.probes = 1;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_ivf
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_ivf
    WHERE id = 500
)
LIMIT 10;

SELECT
    'IVFFlat (probes = 1)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);


-- IVFFlat: probes = 10
SET ivfflat.probes = 10;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_ivf
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_ivf
    WHERE id = 500
)
LIMIT 10;

SELECT
    'IVFFlat (probes = 10)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);


-- HNSW: ef_search = 40
SET hnsw.ef_search = 40;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_hnsw
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_hnsw
    WHERE id = 500
)
LIMIT 10;

SELECT
    'HNSW (ef_search = 40)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);


-- HNSW: ef_search = 400
SET hnsw.ef_search = 400;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_hnsw
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding
    FROM teste_hnsw
    WHERE id = 500
)
LIMIT 10;

SELECT
    'HNSW (ef_search = 400)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);