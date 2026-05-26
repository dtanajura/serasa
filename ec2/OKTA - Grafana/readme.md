# 🔐 Roteiro – Integração OKTA + Grafana (SSO)

## 🎯 Objetivo

Configurar autenticação no Grafana via OKTA usando:

* ✅ SSO (Single Sign-On)
* ✅ Autenticação centralizada
* ✅ Controle de acesso por grupos
* ✅ Segurança corporativa

***

# 🧠 1. Arquitetura

```text
Usuário
   ↓
OKTA (IdP)
   ↓
Grafana (OAuth / SAML)
   ↓
Permissões por grupo
```

***

# ⚙️ 2. Métodos suportados

Grafana pode integrar com OKTA via:

| Método          | Uso                        |
| --------------- | -------------------------- |
| OAuth2 ✅        | Mais comum                 |
| SAML ✅          | Corporativo                |
| LDAP ❌ (legado) | Você está usando isso hoje |

***

⚠️ Seu `grafana.ini` indica LDAP:

```ini
[auth.ldap]
enabled = true
config_file = /etc/grafana/ldap.toml
```

👉 Isso NÃO é OKTA diretamente  
👉 Provavelmente via AD/LDAP intermediário [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/grafana.ini)

***

# 🚀 3. Padrão recomendado (OKTA → OAuth)

Vamos migrar para:

✅ OKTA via OAuth2 (melhor prática)

***

# 🔐 4. Configurar OKTA

## 📌 Criar App

Em OKTA:

* Application type: **Web**
* Sign-in redirect URI:

```text
https://grafana.seu-dominio.com/login/okta
```

***

## 📌 Dados gerados

* Client ID
* Client Secret
* Issuer URL

***

# 🔧 5. Configurar Grafana

Editar `grafana.ini`:

```ini
[auth.generic_oauth]
enabled = true
name = Okta
allow_sign_up = true

client_id = SEU_CLIENT_ID
client_secret = SEU_CLIENT_SECRET

scopes = openid profile email
auth_url = https://<OKTA_DOMAIN>/oauth2/default/v1/authorize
token_url = https://<OKTA_DOMAIN>/oauth2/default/v1/token
api_url = https://<OKTA_DOMAIN>/oauth2/default/v1/userinfo

role_attribute_path = contains(groups[*], 'grafana-admin') && 'Admin' || 'Viewer'
```

***

## 🔑 Segurança (secret.json)

⚠️ Seu arquivo:

```json
{
  "username": "usr-nikedata-observ",
  "password": "GhS#Y8U#hgTY"
}
```

👉 Isso NÃO deve ficar em arquivo plano  
👉 Migrar para:

* Kubernetes Secret ✅
* AWS Secrets Manager ✅

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/secret.json)

***

# ☸️ 6. Kubernetes (se Grafana estiver no EKS)

## ▶️ Criar secret

```bash
kubectl create secret generic grafana-okta \
  --from-literal=client-id=XXX \
  --from-literal=client-secret=YYY
```

***

## ▶️ Usar no deployment

```yaml
env:
  - name: GF_AUTH_GENERIC_OAUTH_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: grafana-okta
        key: client-id
```

***

# 🔄 7. Reiniciar Grafana

```bash
kubectl rollout restart deployment grafana
```

ou

```bash
systemctl restart grafana-server
```

***

# 🔎 8. Validação

## ✅ Acesso

Abrir:

```text
https://grafana.seu-dominio.com
```

***

## ✅ Resultado esperado

* Botão **Login via Okta**
* Redirecionamento OKTA
* Login automático

***

# 👥 9. Controle de acesso

## Mapear grupos OKTA → Grafana

```ini
role_attribute_path =
  contains(groups[*], 'grafana-admin') && 'Admin' ||
  contains(groups[*], 'grafana-editor') && 'Editor' ||
  'Viewer'
```

***

# ⚠️ 10. Problemas comuns

## ❌ Redirect URI inválido

✔ Ajustar no OKTA

***

## ❌ Token invalid

✔ Verificar client secret

***

## ❌ Login OK mas sem permissão

✔ Configurar mapping de grupos

***

## ❌ LDAP conflitante

👉 Desabilitar:

```ini
[auth.ldap]
enabled = false
```

***

# ✅ 11. Checklist final

* ✅ App OKTA criado
* ✅ grafana.ini configurado
* ✅ secrets seguros
* ✅ login funcionando
* ✅ roles mapeadas

***

# 🚀 12. Boas práticas

* ✅ Usar OAuth (não LDAP)
* ✅ Não armazenar secrets em texto plano
* ✅ Usar grupos OKTA
* ✅ Ativar TLS
* ✅ Logar auditoria

***

# 🔥 13. Script rápido (exemplo)

```bash
echo "Configurando Grafana OKTA..."

kubectl create secret generic grafana-okta \
  --from-literal=client-id=$CLIENT_ID \
  --from-literal=client-secret=$CLIENT_SECRET

kubectl rollout restart deployment grafana

echo "Concluído ✅"
```

***

# 🧠 Próximo nível (posso montar)

* 🔹 OKTA + Grafana + RBAC completo
* 🔹 integração com AWS SSO
* 🔹 multi-org Grafana
* 🔹 audit logs / compliance
* 🔹 integração com Prometheus / Loki

