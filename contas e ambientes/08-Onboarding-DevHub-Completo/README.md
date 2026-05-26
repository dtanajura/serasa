# Onboarding contas devhub

## 📌 Descrição

Pasta: `Onboarding contas devhub`

**Roteiro de execução disponível**

## 📋 Roteiro de Execução

Passos a serem executados:

1. atividades:
2. solicitação de criação das contas AWS - em andamento
3. Solicitação de acesso às contas no IDC
4. ********
5. Conta sandbox:
6. ********
7. configuração do acesso SAML
8. Validações iniciais
9. Solicitações:
10. REQ-Solicitação de configuração Firewall: porta 443 - Nexus
11. REQ-Solicitação de configuração Firewall: porta 22 – Ansible
12. REQ-Solicitação para habilitar acesso ao proxy
13. Enquanto as solicitações não são atendidas:
14. Configuração do Systems Manager
15. Configuração do AWS Backup
16. Configuração do Bastion da Conta
17. Criação do bucket para salvar o tfstate
18. Configurações de policy do usuário BUPolicyForDevSecOpsPiaaS
19. REQ-Abrir uma request para criação do usuário BUPolicyForDevSecOpsPiaaS
20. REQ-Solicitação de acesso ao cofre de senhas BUUserForDevSecOpsPiaaS e validação da accesskey no CyberArk

... (total de 131 passos)

## 📋 Pré-requisitos

- AWS CLI configurada
- Credenciais AWS com permissões apropriadas

## ⚠️ Observações Importantes

- Sempre testar em ambiente DEV antes de executar em PROD
- Revisar o roteiro antes de executar automaticamente
- Fazer backup dos dados antes de operações destrutivas
- Verificar credenciais e permissões necessárias

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique o arquivo `roteiro.sh` ou `roteiro.txt`
2. Consulte os comentários nos scripts Python
3. Revise os arquivos de configuração

---

*Documentação gerada automaticamente - Última atualização: 2026-05-26*
