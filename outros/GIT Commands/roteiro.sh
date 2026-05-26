# Configurar certificado
# No servidor Linux criar certificado
ssh-keygen -t ed25519 -C "ec2-user"

# Esse comando vai gerar na pasta .ssh dois arquivos:
# id_ed25519 e id_ed25519.pub

# copiar o conteudo do certificado público
cat id_ed25519.pub

# Colar o conteúdo no Bitbucket -> Repository Settings -> Access Keys -> Create Access Keys

# Conectar no GIT no servidor Linux
git clone ssh://git@code.experian.local/enanqu/experian-qes.git

git status # a qualquer momento para obter dicas

# Cria uma nova branch 
git checkout -b branchTest 

# Faz o checkin dos arquivos que vão ser carregados
git add fileName

# Faz o commit dos arquivos alterados na branch
git commit -m "Message"

# Transfere os arquivos para o repositório remoto
git push --set-upstream origin branch_test

# Não lembro para que serve
git checkout master
