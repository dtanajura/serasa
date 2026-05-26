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
  "datahubprod"
)
# $profile_aws = "dsprod"

foreach ($profile_aws  in $profiles) {
    Write-Output "************************************"
    Write-Output "Conta: $profile_aws"
    # Listar clusters ativos e armazenar em uma variável
    $clusters = aws emr list-clusters --profile $profile_aws | ConvertFrom-Json

    # Iterar sobre cada cluster
    foreach ($cluster in $clusters.Clusters) {
        $clusterId = $cluster.Id

        # Descrever o cluster
        $clusterDetails = aws emr describe-cluster --cluster-id $clusterId --profile $profile_aws | ConvertFrom-Json
        $clusterName = $clusterDetails.Cluster.Name
        Write-Output "Cluster ID: $clusterId  Cluster Name: $clusterName"

        # Verificar se há ações de bootstrap
        if ($clusterDetails.Cluster.BootstrapActions) {
            Write-Output "Bootstrap Actions for Cluster $clusterName"

            # Iterar sobre cada ação de bootstrap
            foreach ($action in $clusterDetails.Cluster.BootstrapActions) {
                $actionName = $action.Name
                $scriptPath = $action.ScriptBootstrapAction.Path
                $scriptArgs = $action.ScriptBootstrapAction.Args -join ", "

                Write-Output "Name: $actionName"
                # Write-Output "Script Path: $scriptPath"
                # Write-Output "Arguments: $scriptArgs"
            }
        } else {
            Write-Output "No Bootstrap Actions for Cluster $clusterId"
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

        Write-Output ""
    }
}

--query "Reservations[].Instances[].PrivateIpAddress"

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
  "datahubprod"
)

$processedClusters = @{}

foreach ($profile_aws  in $profiles) {
    Write-Output "Conta: $profile_aws"

    Add-Content -Path output.txt -Value "************************************"
    Add-Content -Path output.txt -Value "Conta: $profile_aws"
    $clusters = aws emr list-clusters --profile $profile_aws | ConvertFrom-Json

    foreach ($cluster in $clusters.Clusters) {
        $clusterId = $cluster.Id
        $clusterDetails = aws emr describe-cluster --cluster-id $clusterId --profile $profile_aws | ConvertFrom-Json
        $clusterName = $clusterDetails.Cluster.Name

        if ($processedClusters[$clusterName] -eq $null) {
            $processedClusters[$clusterName] = $true
            Write-Output "Cluster ID: $clusterId  Cluster Name: $clusterName"
            Add-Content -Path output.txt -Value "Cluster ID: $clusterId  Cluster Name: $clusterName"

            if ($clusterDetails.Cluster.BootstrapActions) {
                Add-Content -Path output.txt -Value "Bootstrap Actions for Cluster $clusterName"

                foreach ($action in $clusterDetails.Cluster.BootstrapActions) {
                    $actionName = $action.Name
                    $scriptPath = $action.ScriptBootstrapAction.Path
                    $scriptArgs = $action.ScriptBootstrapAction.Args -join ", "

                    Add-Content -Path output.txt -Value "Name: $actionName"
                }
            } else {
                Add-Content -Path output.txt -Value "No Bootstrap Actions for Cluster $clusterId"
            }
        }
    }
}
