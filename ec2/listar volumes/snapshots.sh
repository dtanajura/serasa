
#!/usr/bin/env bash
set -euo pipefail

profiles=(
  bnsprod
  bnsuat
  dataofficedev
  dataofficeuat
  dataservicesdev
  dataservicesprod
  dataservicesstage
  positivoprod
  eitsarchitecturesandbox
  datahubdev
  datahubprod
  datahubstage
  lab01sandbox
  sremanagementdev
  nikedataservicedev
  nikedataserviceprod
  nikedataserviceuat
  architecturesandbox
  corporatedev
  corporateprod
  ssrmprod
  ssrmsandbox
  ssrmdev
  ecsnegativedev
  negativodev
  negativosandbox
  positivodev
)

for p in "${profiles[@]}"; do
  echo ">>> Executando snapshots para perfil: $p"
  python3 list_snapshots.py --profile "$p" --csv "${p}.csv"
done
