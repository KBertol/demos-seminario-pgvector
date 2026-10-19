-- DEMO 4: BUSCA SEMANTICA E RECOMENDACAO

-- 1. Tabela: cada documento guarda seu texto e o vetor de 384 dimensoes
DROP TABLE IF EXISTS documentos;
CREATE TABLE documentos (
    id        int PRIMARY KEY,
    titulo    text,
    conteudo  text,
    categoria text,
    embedding vector(384)
);

--2. Pegar os 04_dados.sql

-- 3. Indice HNSW com distancia de cosseno
CREATE INDEX ON documentos USING hnsw (embedding vector_cosine_ops);

-- 4. Os documentos carregados
SELECT id, titulo, categoria FROM documentos ORDER BY id;

-- 5. Usamos o operador de distância espacial (<=>) do pgvector.
SELECT d.titulo, d.categoria, 1 - (d.embedding <=> ref.embedding) AS similaridade
FROM documentos d,
     (SELECT embedding FROM documentos WHERE id = 11) AS ref
WHERE d.id <> 11
ORDER BY d.embedding <=> ref.embedding
LIMIT 5;

-- 6. VETOR + FILTRO RELACIONAL na mesma consulta (vantagem do pgvector):
--    parecidos com o documento 11, mas so da categoria 'automoveis'.
SELECT d.titulo, d.categoria, 1 - (d.embedding <=> ref.embedding) AS similaridade
FROM documentos d,
     (SELECT embedding FROM documentos WHERE id = 11) AS ref
WHERE d.categoria = 'automoveis' AND d.id <> 11
ORDER BY d.embedding <=> ref.embedding
LIMIT 5;
