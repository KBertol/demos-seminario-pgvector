-- DEMO 1: INSTALACAO, HABILITACAO E PRIMEIRA TABELA COM VETORES
-- ------------------------------------------
-- ETAPA A: INSTALAR o pgvector no SERVIDOR (feita ANTES, no terminal, nao no SQL)
-- Instalar = colocar os arquivos da extensao dentro do PostgreSQL. Exemplo no Fedora,
-- compilando o codigo-fonte oficial (https://github.com/pgvector/pgvector):
--
--   sudo dnf install -y gcc make git redhat-rpm-config postgresql-server-devel
--   git clone --branch <versao> https://github.com/pgvector/pgvector.git
--   cd pgvector && make && sudo make install
--   sudo systemctl restart postgresql
--
-- (<versao> = ultima tag em github.com/pgvector/pgvector/releases.
--  Alternativas: pacote do repositorio PGDG, ou a imagem Docker pgvector/pgvector.)
-- ------------------------------------------

-- ETAPA B: confere que o servidor TEM a extensao instalada.
--   default_version   = versao instalada no servidor
--   installed_version = versao habilitada NESTE banco (vazio se ainda nao habilitou)

SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE name = 'vector';

-- ETAPA C: HABILITAR a extensao no banco atual (uma vez por banco).
-- Normalmente exige superusuario; aqui ela ja foi habilitada antes pelo usuario postgres.
CREATE EXTENSION IF NOT EXISTS vector;

-- Confere: a extensao agora aparece como habilitada neste banco (no psql: \dx)
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';

-- ------------------------------------------
-- ETAPA D: primeira tabela com uma coluna do tipo vector de 3 dimensoes
-- ------------------------------------------
DROP TABLE IF EXISTS itens;
CREATE TABLE itens (
    id        bigserial PRIMARY KEY,
    nome      text,
    embedding vector(3)
);

-- Insere 4 vetores de exemplo
INSERT INTO itens (nome, embedding) VALUES
    ('A', '[1,2,3]'),
    ('B', '[4,5,6]'),
    ('C', '[2,4,6]'),
    ('D', '[-1,-2,-3]');

-- Confere: os vetores ficaram guardados como qualquer outra coluna
SELECT * FROM itens;