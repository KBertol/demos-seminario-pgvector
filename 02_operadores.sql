-- ==========================================
-- DEMO 2: OS TRES OPERADORES DE DISTANCIA
-- (rodar DEPOIS do 01_instalacao.sql). Vetor de consulta: [3,1,2]
-- ==========================================

-- 1. Distancia EUCLIDIANA (<->): menor = mais proximo
--    Esperado: A (2.449), C (5.099), B (5.745)
SELECT nome, embedding <-> '[3,1,2]' AS distancia_l2
FROM itens ORDER BY distancia_l2 LIMIT 3;

-- 2. Distancia de COSSENO (<=>): compara a DIRECAO; menor = mais parecido
--    Esperado: B (0.117), A (0.214), C (0.214)
SELECT nome, embedding <=> '[3,1,2]' AS distancia_cosseno
FROM itens ORDER BY distancia_cosseno LIMIT 3;

-- 3. PRODUTO INTERNO (<#>): o operador devolve o valor NEGATIVO,
--    por isso multiplicamos por -1 para mostrar o valor real.
--    Esperado: B (29), C (22), A (11)
SELECT nome, (embedding <#> '[3,1,2]') * -1 AS produto_interno
FROM itens ORDER BY embedding <#> '[3,1,2]' LIMIT 3;

-- 4. Ponto didatico: A=[1,2,3] e C=[2,4,6] tem a MESMA direcao.
--    Cosseno ~ 0 (mesma direcao), euclidiana ~ 3.74 (tamanhos diferentes).
SELECT '[1,2,3]'::vector <=> '[2,4,6]'::vector AS cosseno,
       '[1,2,3]'::vector <-> '[2,4,6]'::vector AS euclidiana;

-- 5. Similaridade de cosseno (quanto MAIOR, mais parecido) = 1 - distancia
SELECT nome, 1 - (embedding <=> '[3,1,2]') AS similaridade_cosseno
FROM itens ORDER BY similaridade_cosseno DESC;
