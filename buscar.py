import sys, psycopg
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")
q = model.encode(sys.argv[1], normalize_embeddings=True)
vec = "[" + ",".join(str(float(x)) for x in q) + "]"

with psycopg.connect("host=localhost dbname=seminario user=seminario password=KV1234") as conn:
    rows = conn.execute(
        "SELECT titulo, categoria, 1 - (embedding <=> %s::vector) AS sim "
        "FROM documentos "
        "ORDER BY embedding <=> %s::vector LIMIT 5", (vec, vec)
    ).fetchall()
    
    print("\nResultados Filtrados (Tecnologia):")
    for titulo, cat, sim in rows:
        print(f"[{sim:.3f}] {titulo} ({cat})")
