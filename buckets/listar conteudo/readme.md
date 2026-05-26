## Para listar conteudo dos buckets em uma planilha EXCEL

python s3_list_to_excel.py --bucket nome-do-bucket --profile nome-do-profile

O arquivo gerado é o nome-do-bucket.xlsx

### Outros parâmetros
("--bucket", required=True, help="Nome do bucket S3.")
("--prefix", default="", help="Prefix opcional para filtrar objetos.")
("--profile", default=None, help="AWS profile (opcional).")
("--region", default=None, help="Região AWS (opcional).")

("--max-rows", type=int, default=None, help="Limite máximo de linhas (para testes/lab).")
("--dry-run", action="store_true", help="Executa uma chamada simples para validar acesso, sem gerar o Excel.")
("--progress-every", type=int, default=1000, help="Imprime progresso a cada N objetos lidos (padrão: 1000).")
("--use-tqdm", action="store_true", help="Tenta usar barra de progresso com tqdm (se disponível).")
("--quiet", action="store_true", help="Modo silencioso: minimiza saídas no console.")


# Para listar conteudo dos buckets (muito grandes) em um arquivo csv

python s3_list_to_csv.py --bucket nome-do-bucket --profile nome-do-profile
