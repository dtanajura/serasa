$profiles = @(
   "corporateprod",
   "arcsandbox",
   "ssrmdev",
   "ssrmsandbox",
   "ssrmprod",
   "corporatedev",
   "sredev",
   "dsstage",
   "dsprod",
   "dsdev",
   "datahubprod",
   "datahubdev",
   "bnsprod",
   "bnsuat",
   "dodev",
   "douat",
   "positivoprod",
   "datainsightprod",
   "nikedatadev",
   "nikedataprod",
   "nikedatauat"
)
foreach ($profile_aws  in $profiles) {
    python .\feriascoletivas.py $profile_aws 
}