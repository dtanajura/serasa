
aws eks update-nodegroup-config --profile dsstage --cluster-name ds-eks-01-uat --nodegroup-name EKS-ds-eks-01-uat-NG-infra-2024032100440356980000000f  --scaling-config minSize=1,maxSize=5,desiredSize=2
aws eks update-nodegroup-config --profile dsstage --cluster-name ds-eks-01-uat --nodegroup-name EKS-ds-eks-01-uat-NG-large-2024032100464639320000003c --scaling-config minSize=6,maxSize=9,desiredSize=8
aws eks update-nodegroup-config --profile dsstage --cluster-name ds-eks-01-uat --nodegroup-name EKS-ds-eks-01-uat-NG-medium-20240321004646388900000038 --scaling-config minSize=2,maxSize=4,desiredSize=3
aws eks update-nodegroup-config --profile dsstage --cluster-name ds-eks-01-uat --nodegroup-name EKS-ds-eks-01-uat-NG-small-2024032100464639300000003a --scaling-config minSize=0,maxSize=1,desiredSize=1
aws eks update-nodegroup-config --profile dsstage --cluster-name ds-eks-01-uat --nodegroup-name EKS-ds-eks-01-uat-NG-spot-20240321004646386000000036 --scaling-config minSize=0,maxSize=1,desiredSize=0


aws eks update-nodegroup-config --profile ssrmsandbox --cluster-name ssrm-eks-01-sandbox --nodegroup-name EKS-ssrm-eks-01-sandbox-NG-infra-2024030713381940590000000a  --scaling-config minSize=1,maxSize=2,desiredSize=2
aws eks update-nodegroup-config --profile ssrmsandbox --cluster-name ssrm-eks-01-sandbox --nodegroup-name EKS-ssrm-eks-01-sandbox-NG-large-20240307134052396400000030 --scaling-config minSize=0,maxSize=3,desiredSize=3
aws eks update-nodegroup-config --profile ssrmsandbox --cluster-name ssrm-eks-01-sandbox --nodegroup-name EKS-ssrm-eks-01-sandbox-NG-medium-20240307134052401100000034 --scaling-config minSize=0,maxSize=2,desiredSize=2
aws eks update-nodegroup-config --profile ssrmsandbox --cluster-name ssrm-eks-01-sandbox --nodegroup-name EKS-ssrm-eks-01-sandbox-NG-small-20240307134052400000000032 --scaling-config minSize=0,maxSize=5,desiredSize=4
aws eks update-nodegroup-config --profile ssrmsandbox --cluster-name ssrm-eks-01-sandbox --nodegroup-name  EKS-ssrm-eks-01-sandbox-NG-spot-20240307134052401900000036 --scaling-config minSize=0,maxSize=1,desiredSize=0

aws eks update-nodegroup-config --profile datahubdev --cluster-name datahub-dev --nodegroup-name  EKS-datahub-dev-NG-infra-20240626184642173200000001  --scaling-config minSize=1,maxSize=2,desiredSize=1
aws eks update-nodegroup-config --profile datahubdev --cluster-name datahub-dev --nodegroup-name EKS-datahub-dev-NG-large --scaling-config minSize=1,maxSize=3,desiredSize=3
aws eks update-nodegroup-config --profile datahubdev --cluster-name datahub-dev --nodegroup-name EKS-datahub-dev-NG-medium-2024062523245245430000003e --scaling-config minSize=0,maxSize=1,desiredSize=1
aws eks update-nodegroup-config --profile datahubdev --cluster-name datahub-dev --nodegroup-name EKS-datahub-dev-NG-small-20240625232452457500000040 --scaling-config minSize=0,maxSize=1,desiredSize=1
aws eks update-nodegroup-config --profile datahubdev --cluster-name datahub-dev --nodegroup-name  EKS-datahub-dev-NG-spot-2024062523245244660000003a --scaling-config minSize=1,maxSize=3,desiredSize=1

aws eks update-nodegroup-config --profile arcsandbox --cluster-name nike-tech-dev --nodegroup-name  EKS-nike-tech-dev-NG-infra-20240320214639028400000015  --scaling-config minSize=1,maxSize=5,desiredSize=2
aws eks update-nodegroup-config --profile arcsandbox --cluster-name nike-tech-dev --nodegroup-name EKS-nike-tech-dev-NG-large-20240416120717896900000009 --scaling-config minSize=0,maxSize=1,desiredSize=1
aws eks update-nodegroup-config --profile arcsandbox --cluster-name nike-tech-dev --nodegroup-name EKS-nike-tech-dev-NG-medium-20240320215035132400000041 --scaling-config minSize=0,maxSize=1,desiredSize=0
aws eks update-nodegroup-config --profile arcsandbox --cluster-name nike-tech-dev --nodegroup-name EKS-nike-tech-dev-NG-small-2024041612071789750000000b --scaling-config minSize=0,maxSize=1,desiredSize=0
aws eks update-nodegroup-config --profile arcsandbox --cluster-name nike-tech-dev --nodegroup-name  EKS-nike-tech-dev-NG-spot-2024032021503512700000003b --scaling-config minSize=0,maxSize=1,desiredSize=0

aws eks update-nodegroup-config --profile ssrmprod --cluster-name sales-eks-01-uat --nodegroup-name  EKS-sales-eks-01-uat-NG-infra-2024030712444161820000000a  --scaling-config minSize=1,maxSize=2,desiredSize=2
aws eks update-nodegroup-config --profile ssrmprod --cluster-name sales-eks-01-uat --nodegroup-name EKS-sales-eks-01-uat-NG-large-20240307124709624800000034 --scaling-config minSize=0,maxSize=3,desiredSize=3
aws eks update-nodegroup-config --profile ssrmprod --cluster-name sales-eks-01-uat --nodegroup-name EKS-sales-eks-01-uat-NG-medium-20240307124709608800000030 --scaling-config minSize=0,maxSize=2,desiredSize=2
aws eks update-nodegroup-config --profile ssrmprod --cluster-name sales-eks-01-uat --nodegroup-name EKS-sales-eks-01-uat-NG-small-20240307124709626600000036 --scaling-config minSize=0,maxSize=4,desiredSize=4
aws eks update-nodegroup-config --profile ssrmprod --cluster-name sales-eks-01-uat --nodegroup-name  EKS-sales-eks-01-uat-NG-spot-20240307124709614600000032 --scaling-config minSize=0,maxSize=1,desiredSize=0

aws eks update-nodegroup-config --profile dsdev --cluster-name ds-eks-01-dev --nodegroup-name EKS-ds-eks-01-dev-NG-infra-20240730145310281500000002 --scaling-config minSize=1,maxSize=4,desiredSize=2
aws eks update-nodegroup-config --profile dsdev --cluster-name ds-eks-01-dev --nodegroup-name  EKS-ds-eks-01-dev-NG-large-2024032020415772590000003a --scaling-config minSize=1,maxSize=5,desiredSize=3

