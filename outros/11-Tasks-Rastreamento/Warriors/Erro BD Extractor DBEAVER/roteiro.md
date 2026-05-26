# Resumo do problema
O banco Aurora PostgreSQL está apresentando instabilidade e erros do tipo:
SQL08006 – I/O error while sending to backend
Após análise das métricas do RDS e das sessões via pg_stat_activity, constatou‑se que o problema não é falta de recurso no banco, mas sim uso incorreto de conexões pelo cliente DBeaver, que está deixando transações abertas e acumulando sessões ociosas.

Evidências encontradas
1) Grande número de conexões abertas pelo DBeaver
O comando:
 
SELECT application_name, client_addr, state, count(*)
FROM pg_stat_activity
GROUP BY 1,2,3;
Mostrar mais linhas
mostrou:
27 conexões vindas do IP 10.121.33.80
Todas com application_name = DBeaver ...
Ou seja: o DBeaver está mantendo muitas conexões simultâneas.
2) Sessões em idle in transaction (muito grave)
Foram identificadas 4 sessões de DBeaver em estado:
state = 'idle in transaction'
Isso significa que o DBeaver abriu uma transação (BEGIN), executou uma query e não enviou COMMIT ou ROLLBACK — deixando a transação pendurada por minutos ou horas.
Esse tipo de sessão:
consome recursos continuamente
bloqueia vacuum
mantém snapshots antigos
aumenta uso interno do Postgres
pode bloquear operações internas
e causa justamente os erros 08006 / I/O error
📌 Isso reproduz exatamente o histórico onde reiniciar o RDS “resolvia” — porque o restart mata todas essas conexões zumbis.
3) Crescimento em rampa das conexões
As métricas do CloudWatch mostraram:
DatabaseConnections subindo gradualmente
Sem estabilização
Mesmo sem carga real na aplicação
Esse comportamento é típico de leak de conexão causado por ferramentas de banco (DBeaver, DataGrip etc.).
 
Causa raiz
Uso incorreto do DBeaver (10.121.33.80)
Muitas abas abertas
Conexões de metadata extras
Auto-commit desligado
Sessões esquecidas
Transações abertas e não finalizadas
➡️ Isso satura o número de conexões e afeta o banco.

O que fazer:
1) No DBeaver — habilitar AUTO-COMMIT
No DBeaver:
Menu:
Database → Transactions → Auto-commit
Garanta que esteja ligado.
Isso evita transações abertas acidentalmente.
 
2) Fechar abas antigas no DBeaver
Feche:
SQL Editors antigos
Tabelas abertas
ResultSets abertos
Abas de metadata
Cada aba = 1 conexão extra.


Para conectar no banco
Acessar o servidor BRASA1NDTPT1
export RDSHOST="nike-data-extractor-0.cngig8aky6gi.sa-east-1.rds.amazonaws.com"
[root@brasa1ndtpt1 ~]# psql "host=$RDSHOST port=5432 dbname=extractor user=extractor password=#N2:y(6BMN]QfkW_quV~gqM<dNW5"

