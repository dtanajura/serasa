
#!/usr/bin/env bash
set -euo pipefail

# ==== Configurações ====
AWS_REGION="sa-east-1"
SESSION_DURATION="36000"
LIST_EBS_SCRIPT="./list_ebs.py"  # ajuste se necessário, ex.: /path/to/list_ebs.py
OUT_DIR="./csv"                  # pasta de saída para os CSVs
MAX_RETRIES=2                    # tentativas extras em caso de falha de login/execução
PARALLEL_JOBS=1                  # ajuste para >1 se quiser paralelizar (usa subshells & wait)

# Perfis a processar
PROFILES=(
  "bnsprod"
  "bnsuat"
  "dataofficedev"
  "dataofficeuat"
  "dataservicesdev"
  "dataservicesprod"
  "dataservicesstage"
  "positivoprod"
  "positivouat"
  "datahubdev"
  "datahubprod"
  "datahubstage"
  "sremanagementdev"
  "nikedataservicedev"
  "nikedataserviceprod"
  "nikedataserviceuat"
  "architecturesandbox"
  "corporatedev"
  "corporateprod"
  "bnspssrmprodrod"
  "ssrmsandbox"
  "ssrmdev"
  "negativodev"
  "negativosandbox"
  "positivodev"
)

# ==== Funções auxiliares ====

log() {
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  printf "[%s] %s\n" "$ts" "$*"
}

err() {
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  printf "[%s] [ERRO] %s\n" "$ts" "$*" >&2
}

# login_okta() {
#   local profile="$1"
#   log "Iniciando login Okta para profile '${profile}'..."
#   okta-aws-cli web \
#     --profile "${profile}" \
#     --aws-region "${AWS_REGION}" \
#     --aws-session-duration "${SESSION_DURATION}"
#   log "Login Okta concluído para '${profile}'."
# }

run_list_ebs() {
  local profile="$1"
  local csv_path="$2"
  log "Executando list_ebs.py para '${profile}' -> '${csv_path}'..."
  python3 "${LIST_EBS_SCRIPT}" --profile "${profile}" --csv "${csv_path}"
  log "CSV gerado: ${csv_path}"
}

process_profile() {
  local profile="$1"
  local attempt=0
  local csv_file="${OUT_DIR}/${profile}.csv"

  mkdir -p "${OUT_DIR}"

  while (( attempt <= MAX_RETRIES )); do
    if (( attempt > 0 )); then
      log "Retry ${attempt}/${MAX_RETRIES} para '${profile}'..."
    fi

    # if login_okta "${profile}"; then
      if run_list_ebs "${profile}" "${csv_file}"; then
        log "Profile '${profile}' processado com sucesso."
        return 0
      else
        err "Falha ao executar list_ebs.py para '${profile}'."
      fi
    # else
    #   err "Falha no login Okta para '${profile}'."
    # fi

    ((attempt++))
    sleep 2
  done

  err "Profile '${profile}' falhou após ${MAX_RETRIES} tentativas."
  return 1
}

# ==== Execução ====
log "Início do processamento. Região: ${AWS_REGION}, Duração sessão: ${SESSION_DURATION}s"
log "Saída de CSVs em: ${OUT_DIR}"
log "Script list_ebs.py: ${LIST_EBS_SCRIPT}"

# Controle simples de paralelismo
pids=()
count=0

for profile in "${PROFILES[@]}"; do
  if (( PARALLEL_JOBS > 1 )); then
    (
      process_profile "${profile}"
    ) &
    pids+=($!)
    ((count++))

    if (( count % PARALLEL_JOBS == 0 )); then
      wait
      pids=()
    fi
  else
    process_profile "${profile}"
  fi
done

# Espera restante se paralelizado
if (( PARALLEL_JOBS > 1 )); then
  wait
fi

log "Processamento concluído."
