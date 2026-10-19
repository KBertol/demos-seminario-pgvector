from sentence_transformers import SentenceTransformer

model = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")

docs = [
    (1, "Redes neurais", "Redes neurais aprendem padrões a partir de grandes volumes de dados.", "tecnologia"),
    (2, "Banco de dados relacional", "O PostgreSQL armazena dados em tabelas e garante transações confiáveis.", "tecnologia"),
    (3, "Busca vetorial", "Embeddings permitem encontrar textos com significado parecido, mesmo sem palavras iguais.", "tecnologia"),
    (4, "Linguagens de programação", "Python e Java são muito usadas no desenvolvimento de software.", "tecnologia"),
    (5, "Segurança da informação", "Senhas fortes e autenticação em dois fatores protegem contas.", "tecnologia"),
    (6, "Receita de bolo", "Misture a farinha, o açúcar e os ovos e asse em forno médio por quarenta minutos.", "culinaria"),
    (7, "Molho de tomate", "Refogue a cebola e o alho, adicione os tomates e cozinhe em fogo baixo.", "culinaria"),
    (8, "Pão caseiro", "A massa precisa descansar para crescer antes de ir ao forno.", "culinaria"),
    (9, "Churrasco", "A carne deve descansar depois de grelhada para manter o suco.", "culinaria"),
    (10, "Manutenção do carro", "Troque o óleo do motor e verifique os freios com regularidade.", "automoveis"),
    (11, "Veículo sem partida", "Se o veículo não dá partida, verifique a bateria e o motor de arranque.", "automoveis"),
    (12, "Pneus e segurança", "Calibrar os pneus melhora a segurança e reduz o consumo de combustível.", "automoveis")
]

emb = model.encode([d[2] for d in docs], normalize_embeddings=True)

esc = lambda t: t.replace("'", "''")

with open("04_dados.sql", "w", encoding="utf-8") as f:
    f.write("-- Gerado por gerar_embeddings.py (vetores de 384 dimensoes)\n")
    f.write("INSERT INTO documentos (id, titulo, conteudo, categoria, embedding) VALUES\n")
    linhas = [f"({i}, '{esc(t)}', '{esc(c)}', '{cat}', '{v.tolist()}')"
              for (i, t, c, cat), v in zip(docs, emb)]
    f.write(",\n".join(linhas) + ";\n")

print("Arquivo 04_dados.sql gerado com sucesso!")