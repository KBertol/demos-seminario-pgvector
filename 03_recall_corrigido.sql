
-- DEMO 3B: RECALL CORRIGIDO
-- Usa as tabelas e os índices já existentes.
-- Não recria os dados nem os índices.

-- 1. Busca exata: referência para comparar os resultados
-- O id 500 é o vetor da consulta, não deve contar como vizinho.

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

-- Conferir os 10 vizinhos exatos
SELECT id FROM exato ORDER BY id;


-- 2. IVFFlat: probes = 1

SET ivfflat.probes = 1;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_ivf
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding FROM teste_ivf WHERE id = 500
)
LIMIT 10;

SELECT
    'IVFFlat (probes = 1)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);


-- 3. IVFFlat: probes = 10

SET ivfflat.probes = 10;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_ivf
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding FROM teste_ivf WHERE id = 500
)
LIMIT 10;

SELECT
    'IVFFlat (probes = 10)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);


-- 4. HNSW: ef_search = 40

SET hnsw.ef_search = 40;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_hnsw
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding FROM teste_hnsw WHERE id = 500
)
LIMIT 10;

SELECT
    'HNSW (ef_search = 40)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);


-- 5. HNSW: ef_search = 400

SET hnsw.ef_search = 400;

DROP TABLE IF EXISTS aprox;

CREATE TEMP TABLE aprox AS
SELECT id
FROM teste_hnsw
WHERE id <> 500
ORDER BY embedding <-> (
    SELECT embedding FROM teste_hnsw WHERE id = 500
)
LIMIT 10;

SELECT
    'HNSW (ef_search = 400)' AS configuracao,
    COUNT(*) AS acertos_de_10,
    COUNT(*) * 10 AS recall_percentual
FROM exato
JOIN aprox USING (id);
