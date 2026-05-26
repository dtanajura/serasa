$listPods = (kubectl get pod -A)
foreach ($pod in $listPods) {
    print($pod.Trim())
    # $namespace,$podname,$rest=$pod.Split(),3
    # $namespace
    # $podname
    # if ($efs.IndexOf("fs-") -eq -1) {$name=$efs} else {$id=$efs}  #,0,$efs.Length
    # if ($name -eq $clusterName) {
    #     # Excluir os Access Points do EFS
    #     $accessPoints = aws efs describe-access-points --file-system-id $id --profile $profileAws | ConvertFrom-Json
    #     foreach ($ap in $accessPoints.AccessPoints) {
    #         Write-Host "Excluindo Access Point: $($ap.AccessPointId)"
    #         aws efs delete-access-point --access-point-id $ap.AccessPointId --profile $profileAws
    #     }
    #     Write-Host "linha $name e $id"
    #     # Excluir os Mount Targets do EFS
    #     $mountTargets = aws efs describe-mount-targets --file-system-id $id --profile $profileAws --query "MountTargets[].MountTargetId" --output text
    #     if ($mountTargets -ne "") {$mountTargets = $mountTargets.Split()}
    #     foreach ($mt in $mountTargets) {
    #         Write-Host "Excluindo Mount Target: $mt"
    #         aws efs delete-mount-target --mount-target-id $mt --profile $profileAws
    #     }
    #     # Excluir o EFS File System (deve esperar que todos os Access Points sejam excluídos)
    #     Write-Host "Excluindo EFS File System: $id"
    #     Start-Sleep -Seconds 10
    #     aws efs delete-file-system --file-system-id $id --profile $profileAws
    # }
}
