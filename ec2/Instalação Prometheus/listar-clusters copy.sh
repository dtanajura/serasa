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
  "datahubdev",
  "datahubdevus",
  "datahubprod",
  "consentdev",
  "consentprod"
)
$profile_aws = "dsprod"

# foreach ($profile_aws  in $profiles) {
    Write-Output "************************************"
    Write-Output "Conta: $profile_aws"
    # Listar clusters ativos e armazenar em uma variável
    $clusters = aws emr list-clusters --profile $profile_aws | ConvertFrom-Json

    # Iterar sobre cada cluster
    clear
    foreach ($cluster in $clusters.Clusters) {
        $clusterId = $cluster.Id

        # Descrever o cluster
        $clusterDetails = aws emr describe-cluster --cluster-id $clusterId --profile $profile_aws | ConvertFrom-Json
        $clusterName = $clusterDetails.Cluster.Name
        $clusterEC2Name = aws emr describe-cluster --profile $profile_aws --cluster-id $clusterId --query "Cluster.Tags[?Key=='Name'].Value | [0]" --output text

        Write-Output "# Cluster ID: $clusterId  Cluster Name: $clusterName   Cluster EC2 Names: $clusterEC2Name"

        # Verificar se há ações de bootstrap
        if ($clusterDetails.Cluster.BootstrapActions) {
            Write-Output "# Bootstrap Actions for Cluster $clusterName"

            # Iterar sobre cada ação de bootstrap
            foreach ($action in $clusterDetails.Cluster.BootstrapActions) {
                $actionName = $action.Name
                $scriptPath = $action.ScriptBootstrapAction.Path
                $scriptArgs = $action.ScriptBootstrapAction.Args -join ", "

                Write-Output "# Name: $actionName"
                # Write-Output "Script Path: $scriptPath"
                # Write-Output "Arguments: $scriptArgs"
            }
        } else {
            Write-Output "# No Bootstrap Actions for Cluster $clusterId"
        }
        # Obter os IDs das instâncias do cluster
        # $instances = aws emr list-instances --cluster-id $clusterId --profile $profile_aws | ConvertFrom-Json
        # foreach ($instance in $instances.Instances) {
        #     $instanceId = $instance.Ec2InstanceId

        #     # Obter as informações de IP da instância
        #     $dataInstance = aws ec2 describe-instances --instance-ids $instanceId --profile $profile_aws  | ConvertFrom-Json
        #     $instanceName = $dataInstance.Reservations.Instances.Tags | Where-Object {$_.Key -eq 'Name'} | Select-Object -ExpandProperty Value
        #     $instanceIPAddress = $dataInstance.Reservations.Instances.PrivateIpAddress
        #     if ($instanceIPAddress) { 
        #         Write-Output "Instance ID: $instanceId ($instanceName)"
        #         Write-Output "IP Address: $instanceIPAddress"
        #         # Write-Output $instanceIPAddress
        #     }
        # }


        Write-Output "  - job_name: '$clusterName'"
        Write-Output "    ec2_sd_configs:"
        Write-Output "      - region: sa-east-1"
        Write-Output "    relabel_configs:"
        Write-Output "      - source_labels: [__meta_ec2_tag_Name]"
        Write-Output "        regex: '$clusterEC2Name'"
        Write-Output "        action: keep"
        Write-Output "      - source_labels: [__meta_ec2_private_ip]"
        Write-Output "        target_label: __address__"
        Write-Output "        replacement: '`${1}`:9100'"
        Write-Output ""
    }

