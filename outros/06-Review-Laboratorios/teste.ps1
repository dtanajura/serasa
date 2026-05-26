$profile = "lab02"
$cidrBlock = "100.64.0.0/16"

# Executar o comando AWS EC2
$vpcs = aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile $profile --output text

# Iniciar a frase de verificação
Write-Output -NoNewline "Verificar se a conta tem um range secundário de IPs para execução dos pods (100.64.0.0/16): "

# Verificar se o CIDR está presente
if ($vpcs -match $cidrBlock) {
    Write-Output "OK"
} else {
    Write-Output "Falha"
}
