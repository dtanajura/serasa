import boto3
from botocore.exceptions import ClientError
import tkinter as tk
from tkinter import filedialog, messagebox
import os
import json
import subprocess

# Caminho do arquivo de configuração para salvar a última pasta selecionada
config_file = "config.json"

def load_last_folder():
    if os.path.isfile(config_file):
        with open(config_file, 'r') as f:
            config = json.load(f)
            return config.get("last_folder", "")
    return ""

def save_last_folder(folder_path):
    config = {"last_folder": folder_path}
    with open(config_file, 'w') as f:
        json.dump(config, f)

def select_folder():
    folder_path = filedialog.askdirectory()
    if folder_path:
        folder_path_var.set(folder_path)
        save_last_folder(folder_path)

def list_files(folder_path):
    files = os.listdir(folder_path)
    if files:
        files_textbox.delete(1.0, tk.END)
        for file in files:
            if os.path.isdir(os.path.join(folder_path, file)):
                files_textbox.insert(tk.END, f"D => {file}\n")
            else:
                files_textbox.insert(tk.END, f"{file}\n")
    else:
        messagebox.showinfo("Info", "A pasta selecionada está vazia.")

def validate_folder(folder_path):
    required_files = ["backend.hcl", "main.tf", "outputs.tf", "variables.tf", "versions.tf"]
    for file in required_files:
        if not os.path.isfile(os.path.join(folder_path, file)):
            return False
    return True

def git_commit_and_push(folder_path, service_type, service_name):
    branch_name = "refactor/terragrunt"
    commit_message = f"refactor({service_type}/{service_name}): terragrunt migration"
    
    try:
        # Navega até o diretório do repositório
        os.chdir(folder_path)
        
        # Cria uma nova branch
        subprocess.run(["git", "checkout", "-b", branch_name], check=True)
        
        # Adiciona os arquivos modificados
        subprocess.run(["git", "add", "tags.hcl", "terragrunt.hcl", "import.tf"], check=True)
        
        # Faz o commit com a mensagem apropriada
        subprocess.run(["git", "commit", "-m", commit_message], check=True)
        
        # Envia a branch para o repositório remoto
        subprocess.run(["git", "push", "origin", branch_name], check=True)
        
        files_textbox.insert(tk.END, "Commit e push realizados com sucesso.\n")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Erro ao executar o comando Git:\n{e}")


def extract_info_from_path(folder_path):
    normalized_path = folder_path.replace(os.sep, '/')
    path_parts = normalized_path.split('/')
       
    # Verifica se o caminho tem pelo menos duas partes
    if len(path_parts) < 2:
        print("Caminho inválido")
        return None, None, None
    
    # Busca a região pelo padrão "sa-east-1" ou "us-east-1"
    region = next((part for part in path_parts if part in ["sa-east-1", "us-east-1"]), None)
    
    if not region:
        print("Região não encontrada")
        return None, None, None
    
    region_index = path_parts.index(region)
    remaining_parts = path_parts[region_index + 1:]
    
    if len(remaining_parts) == 3:
        service_type = f"{remaining_parts[0]}-{remaining_parts[1]}"
        service_name = remaining_parts[2]
    elif len(remaining_parts) == 2:
        service_type = remaining_parts[0]
        service_name = remaining_parts[1]
    else:
        print("Estrutura de caminho inválida")
        return None, None, None
    
    # print(f"região: {region} Serviço: {service_type} Nome: {service_name}")
    
    return region, service_type, service_name

def get_repository_info(service_type):
    repositories = {
        "iam-policies": {
            "url": "https://code.experian.local/scm/nikesre/terraform-iam-policy.git",
            "version": "v1.2.5"
        },
        "iam-policy": {
            "url": "https://code.experian.local/scm/nikesre/terraform-iam-policy.git",
            "version": "v1.2.5"
        },
        "iam-role": {
            "url": "https://code.experian.local/scm/nikesre/terraform-iam-role.git",
            "version": "v1.3.8"
        },
        "documentdb": {
            "url": "https://code.experian.local/scm/nikesre/terraform-documentdb.git",
            "version": "v1.0.6"
        },
        "elasticache": {
            "url": "https://code.experian.local/scm/nikesre/terraform-elasticache.git",
            "version": "v1.5.0"
        },
        "s3": {
            "url": "https://code.experian.local/scm/nikesre/terraform-s3.git",
            "version": "v1.6.9"
        },
        "msk": {
            "url": "https://code.experian.local/scm/nikesre/terraform-msk.git",
            "version": "v1.1.7"
        },
        "rds": {
            "url": "https://code.experian.local/scm/nikesre/terraform-rds.git",
            "version": "v1.2.9"
        },
        "sqs": {
            "url": "https://code.experian.local/scm/nikesre/terraform-sqs.git",
            "version": "v1.2.4"
        },
        "ec2": {
            "url": "https://code.experian.local/scm/nikesre/terraform-ec2.git//submodules/instance",
            "version": "v2.2.4"
        },
        "ecr": {
            "url": "https://code.experian.local/scm/nikesre/terraform-ecr.git",
            "version": "v1.0.4"
        },
        "dynamodb": {
            "url": "https://code.experian.local/scm/nikesre/terraform-dynamodb.git",
            "version": "v1.1.7"
        }
    }
    return repositories.get(service_type, {"url": "", "version": ""})

def read_module_lines(folder_path):
    main_tf_path = os.path.join(folder_path, "main.tf")
    if not os.path.isfile(main_tf_path):
        return None
    
    with open(main_tf_path, 'r') as f:
        content = f.read()
    
    start = content.find('module "')
    if start == -1:
        return None
    
    module_content = content[start:]
    lines = module_content.splitlines()
    lines_to_copy = []
    for line in lines:
        if not line.strip().startswith("source") and not line.strip().startswith("env") and not line.strip().startswith("module"):
            lines_to_copy.append(line)
    return lines_to_copy


def create_terragrunt_hcl(folder_path, service_type):
    repo_info = get_repository_info(service_type)
    terragrunt_hcl_path = os.path.join(folder_path, "terragrunt.hcl")
    with open(terragrunt_hcl_path, 'w') as f:
        f.write('''# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  enabled = true
}

terraform {
  source = local.enabled ? "git::''' + repo_info["url"] + '''?ref=''' + repo_info["version"] + '''" : null
}

inputs = {
  env  = include.root.locals.env
''')
        lines_to_copy = read_module_lines(folder_path)
        if lines_to_copy:
            for line in lines_to_copy:
                f.write(f'  {line}\n')
                # print(line)

def get_ec2_parameters(service_name, session):
    ec2 = session.client('ec2')
    # Filtre as instâncias pela tag Name
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [service_name]
            }
        ]
    )
    # Extraia o ID da instância da resposta
    instance_id = None
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
    return instance_id

def get_iampolicy_parameters(service_name, session):
    # Inicialize o cliente IAM
    iam = session.client('iam')
    # Liste todas as policies e encontre a que corresponde ao nome
    response = iam.list_policies(Scope='Local')
    # Filtre a policy pelo nome e obtenha a ARN
    policy_arn = None
    for policy in response['Policies']:
        if policy['PolicyName'] == service_name:
            policy_arn = policy['Arn']
            break
    return policy_arn

# def get_iamrole_parameters(service_name, session):
#     iam = session.client('iam')
#     policy_arns = []
#     valor_instance_profile = "false"
#     # Verifica se a role existe
#     role = iam.get_role(RoleName=service_name)
#     if role:
#         attached_policies = iam.list_attached_role_policies(RoleName=service_name)
#         policy_arns = [policy['PolicyArn'] for policy in attached_policies['AttachedPolicies']]
    
#     # Verifica se existe um instance profile com o mesmo nome da role
#     instance_profile = iam.get_instance_profile(InstanceProfileName=service_name)
#     if instance_profile:
#         valor_instance_profile = "true"
    
#     return valor_instance_profile, policy_arns

def get_iamrole_parameters(service_name, session):
    iam = session.client('iam')
    policy_arns = []
    instance_profile_created = "false"
    
    try:
        # Verifica se a role existe
        role = iam.get_role(RoleName=service_name)
        if role:
            attached_policies = iam.list_attached_role_policies(RoleName=service_name)
            policy_arns = [policy['PolicyArn'] for policy in attached_policies['AttachedPolicies']]
    except iam.exceptions.NoSuchEntityException:
        files_textbox.insert(tk.END, f"Policies não atachadas na role {service_name}")        
    try:
        # Verifica se existe um instance profile com o mesmo nome da role
        instance_profile = iam.get_instance_profile(InstanceProfileName=service_name)
        if instance_profile:
            instance_profile_created = "true"
    except iam.exceptions.NoSuchEntityException:
        files_textbox.insert(tk.END, f"Não tem instance profile na role {service_name}")
    
    return instance_profile_created, policy_arns


def get_sqs_parameters(service_name, session):
    # Inicialize o cliente SQS
    sqs = session.client('sqs')
    # Obtenha a URL da fila
    response = sqs.get_queue_url(QueueName=service_name)
    queue_url = None
    if response:
        queue_url = response['QueueUrl']
    return queue_url

def get_msk_parameters(service_name, session):
    # Inicialize o cliente MSK
    msk = session.client('kafka') 
    # Liste todos os clusters e encontre o que corresponde ao nome
    response = msk.list_clusters_v2()
    cluster_arn = None
    # Filtre o cluster pelo nome e obtenha a ARN
    for cluster in response['ClusterInfoList']:
        if cluster['ClusterName'] == service_name:
            cluster_arn = cluster['ClusterArn']
            break
    return cluster_arn

def get_elasticache_parameters(service_name, session):
    # Inicialize o cliente ElastiCache
    elasticache = session.client('elasticache')

    # Inicialize as variáveis para armazenar as informações
    parameter_group = None
    replication_group = None
    subnet_group = None
    security_group_id = None
    log_group_name = None

    # Liste todos os clusters
    response = elasticache.describe_cache_clusters(ShowCacheNodeInfo=True)

    # Filtre o cluster pelo nome do cluster
    cluster_info = None
    for cluster in response['CacheClusters']:
        if cluster['ReplicationGroupId'] == service_name:
            cluster_info = cluster
            break
    
    # Extraia as informações do cluster
    if cluster_info:
        parameter_group = cluster_info['CacheParameterGroup']['CacheParameterGroupName']
        replication_group = cluster_info['ReplicationGroupId']
        subnet_group = cluster_info['CacheSubnetGroupName']
        security_group_id = cluster_info['SecurityGroups'][0]['SecurityGroupId']
        
        # Verifique se o grupo de logs existe
        cloudwatch = session.client('logs')
        potential_log_group_name = f"/aws/elasticache/{cluster_info['CacheClusterId']}"
        log_groups_response = cloudwatch.describe_log_groups(logGroupNamePrefix=potential_log_group_name)
        log_groups = log_groups_response['logGroups']
        
        if any(log_group['logGroupName'] == potential_log_group_name for log_group in log_groups):
            log_group_name = potential_log_group_name
        else:
            log_group_name = None

    return parameter_group, replication_group, subnet_group, security_group_id, log_group_name


def get_security_group_rules(security_group_id, session):
    # Inicialize o cliente EC2
    ec2 = session.client('ec2')

    # Obtenha as regras do grupo de segurança
    response = ec2.describe_security_group_rules(
        Filters=[{'Name': 'group-id', 'Values': [security_group_id]}]
    )
    # print(security_group_id)
    egress_rules = []
    ingress_rules = []

    for rule in response['SecurityGroupRules']:
        if rule['IsEgress']:
            egress_rules.append(rule['SecurityGroupRuleId'])
            print(f'Egress Rule CIDR: {rule["CidrIpv4"]}')
        else:
            ingress_rules.append(rule['SecurityGroupRuleId'])
            print(f'Ingress Rule CIDR: {rule["CidrIpv4"]}')

    return egress_rules, ingress_rules

def get_import_info(service_type, service_name, session):
    import_info = {}

    if service_type == "ec2":
        instance_id = get_ec2_parameters(service_name, session)
        import_info["ec2"] = [
            {"to": "aws_instance.this", "id": instance_id}
        ]
    elif service_type == "iam-policy":
        policy_arn = get_iampolicy_parameters(service_name, session)
        import_info["iam-policy"] = [
            {"to": "aws_iam_policy.this", "id": policy_arn}
        ]
        import_info["iam-policy"] = [
            {"to": "aws_iam_policy.this", "id": policy_arn}
        ]
    elif service_type == "iam-role":
        instance_profile_created, policy_arns = get_iamrole_parameters(service_name, session)
        if instance_profile_created == "true":
            import_info["iam-role"] = [
                {"to": "aws_iam_role.this", "id": service_name},
                {"to": "aws_iam_instance_profile.this", "id": service_name}
            ]
        else:
            import_info["iam-role"] = [
                {"to": "aws_iam_role.this", "id": service_name}
            ]
        for arn in policy_arns:
            import_info["iam-role"].append({"to": f"aws_iam_role_policy_attachment.this[\"{arn}\"]", "id": f"{service_name}/{arn}"})
    elif service_type == "sqs":
        queue_url = get_sqs_parameters(service_name, session)
        import_info["sqs"] = [
            {"to": "aws_sqs_queue.this", "id": queue_url},
            {"to": "aws_sqs_queue_policy.this", "id": queue_url}
        ]
    elif service_type == "s3":
        import_info["s3"] = [
            {"to": "aws_s3_bucket.this", "id": service_name}
        ]
    elif service_type == "ecr":
        import_info["ecr"] = [
            {"to": "aws_ecr_repository.this", "id": service_name}
        ]
    elif service_type == "msk":
        cluster_arn = get_msk_parameters(service_name, session)
        import_info["msk"] = [
            {"to": "aws_kafka_cluster.this", "id": cluster_arn}
        ]
    elif service_type == "elasticache":
        parameter_group, replication_group, subnet_group, security_group_id, log_group_name = get_elasticache_parameters(service_name, session)
        import_info["elasticache"] = [
            {"to": "aws_elasticache_parameter_group.this", "id": parameter_group},
            {"to": "aws_elasticache_replication_group.this", "id": replication_group},
            {"to": "aws_elasticache_subnet_group.this", "id": subnet_group},
            {"to": "aws_security_group.this", "id": security_group_id},
            {"to": "aws_cloudwatch_log_group.this", "id": log_group_name}
        ]
        if security_group_id:
            egress_rules, ingress_rules = get_security_group_rules(security_group_id, session)
        if egress_rules:
            for index, rule_id in enumerate(egress_rules):
                import_info["elasticache"].append({"to": f"aws_vpc_security_group_egress_rule.this[\"{index}\"]", "id": rule_id})
        if ingress_rules:
            for index, rule_id in enumerate(ingress_rules):
                import_info["elasticache"].append({"to": f"aws_vpc_security_group_ingress_rule.this[\"{index}\"]", "id": rule_id})
    else:
        import_info[service_type] = [
            {"to": f"aws_{service_type}.this", "id": service_name}
        ]

    return import_info.get(service_type, [{"to": "", "id": ""}])


def create_import_tf(folder_path, service_type, service_name, session):
    import_info_list = get_import_info(service_type, service_name, session)
    import_tf_path = os.path.join(folder_path, "import.tf")
    
    with open(import_tf_path, 'w') as f:
        for import_info in import_info_list:
            f.write(f'''import {{
  to = {import_info["to"]}
  id = "{import_info["id"]}"
}}
 ''')

def remove_old_tfstate(folder_path, service_type, region, service_name, bucket_name, dynamodb_table, session):

    dynamodb = session.client('dynamodb', region_name=region)
    s3 = session.client('s3')
    
    # Verifica se service_name contém "-"
    if "-" in service_type:
        service_type_parts = service_type.split("-")
        service_type_part1 = service_type_parts[0]
        service_type_part2 = service_type_parts[1]
        lock_id = f"{bucket_name}/{region}/{service_type_part1}/{service_type_part2}/{service_name}/terraform.tfstate-md5"
        tfstate_key = f"{region}/{service_type_part1}/{service_type_part2}/{service_name}/terraform.tfstate"
    else:
        lock_id = f"{bucket_name}/{region}/{service_type}/{service_name}/terraform.tfstate-md5"
        tfstate_key = f"{region}/{service_type}/{service_name}/terraform.tfstate"

    # Define a chave do item a ser deletado
    key = {
        'LockID': {
            'S': lock_id
        }
    }
           
    try:
        # Executa a operação delete-item no DynamoDB
        response_dynamodb = dynamodb.delete_item(
            TableName=dynamodb_table,
            Key=key
        )
        print(f"TableName={dynamodb_table},Key={key}")
        files_textbox.insert(tk.END, f"Comando DynamoDB executado com sucesso:\n{response_dynamodb}\n")
        
        # Executa a operação de remoção no S3
        response_s3 = s3.delete_object(
            Bucket=bucket_name,
            Key=tfstate_key
        )
        print(f"Bucket={bucket_name},Key={tfstate_key}")
        files_textbox.insert(tk.END, f"Comando S3 executado com sucesso:\n{response_s3}\n")
    except ClientError as e:
        messagebox.showerror("Error", f"Erro ao executar o comando:\n{e.response['Error']['Message']}")
        

def read_backend_hcl(folder_path):
    backend_hcl_path = os.path.join(folder_path, "backend.hcl")
    if not os.path.isfile(backend_hcl_path):
        return None, None, None
    
    with open(backend_hcl_path, 'r') as f:
        content = f.read()
    
    bucket_name = None
    dynamodb_table = None
    profile = None
    
    for line in content.splitlines():
        # Remove espaços em branco ao redor do sinal de igual
        line = line.replace(" ", "")
        if 'bucket=' in line:
            bucket_name = line.split('=')[1].strip().strip('"')
        elif 'dynamodb_table=' in line:
            dynamodb_table = line.split('=')[1].strip().strip('"')
        elif 'profile=' in line:
            profile = line.split('=')[1].strip().strip('"')
    
    return bucket_name, dynamodb_table, profile

def read_main_tf(folder_path):
    main_tf_path = os.path.join(folder_path, "main.tf")
    if not os.path.isfile(main_tf_path):
        return None
    
    with open(main_tf_path, 'r') as f:
        content = f.read()
    
    start = content.find("common_tags = {")
    end = content.find("}", start)
    if start == -1 or end == -1:
        return None
    
    tags_content = content[start + len("common_tags = {"):end].strip()
    tags = {}
    for line in tags_content.splitlines():
        key, value = line.split("=")
        tags[key.strip().strip('"')] = value.strip().strip('"')
    
    return tags

def create_tags_hcl(folder_path, tags):
    tags_hcl_path = os.path.join(folder_path, "tags.hcl")
    with open(tags_hcl_path, 'w') as f:
        f.write('locals {\n')
        for key in ["Asset_Category", "Data_Category", "Data_Type", "Project", "wiz_cig", "Flow", "Name", "Squad", "Service"]:
            if key in tags:
                f.write(f'  {key} = "{tags[key]}"\n')
        f.write('}\n')

def get_next_folder_path(current_folder_path):
    # Obtém o diretório pai da pasta atual
    parent_dir = os.path.dirname(current_folder_path)
    
    # Lista todas as pastas no diretório pai
    folders = [f for f in os.listdir(parent_dir) if os.path.isdir(os.path.join(parent_dir, f))]
    
    # Ordena as pastas em ordem alfabética
    folders.sort()
    
    # Encontra o índice da pasta atual na lista de pastas
    current_index = folders.index(os.path.basename(current_folder_path))
    
    # Obtém o índice da próxima pasta
    next_index = (current_index + 1) % len(folders)
    
    # Retorna o caminho da próxima pasta
    next_folder_path = os.path.join(parent_dir, folders[next_index])
    return next_folder_path

def search_and_create_hcl_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.json'):
                json_file_path = os.path.join(root, file)
                create_hcl_file(json_file_path)

def create_hcl_file(json_file_path):
    # Ler o conteúdo do arquivo json como texto
    with open(json_file_path, 'r') as f:
        data = f.readlines()
    
    hcl_content = []

    # Parte inicial do arquivo HCL
    hcl_content.append('locals {')
    hcl_content.append('  policy = jsonencode({')
    
    # Converter o conteúdo do JSON com indentação
    for line in data[1:-1]:
        line = line.rstrip()
        if ":" in line and not line.strip().startswith("\"arn:"):
            line_parts = line.split(":", 1)
            line_part1 = line_parts[0].replace("\"", "")
            line_part2 = line_parts[1].replace(",", "")
            line = line_part1 + " = " + line_part2

        hcl_content.append(f'  {line}')

    # Parte final do hcl
    hcl_content.append('  })')
    hcl_content.append('}')

    # Criar o arquivo hcl
    hcl_file_path = json_file_path.replace(".json", ".hcl")
    with open(hcl_file_path, 'w') as f:
        f.write('\n'.join(hcl_content))
        files_textbox.insert(tk.END, f"Arquivo trusted_policy.hcl criado em: {hcl_file_path}\n")
    

def process_files():
    folder_path = folder_path_var.get()
    files_textbox.insert(tk.END, "*****LOG Processamento*****\n")

    # Testes Iniciais
    # **************************
    if not folder_path:
        messagebox.showwarning("Warning", "Por favor, selecione uma pasta primeiro.")
        return  
    if not validate_folder(folder_path):
        messagebox.showerror("Error", "A pasta selecionada não é válida. Certifique-se de que contém os arquivos necessários.")
        return
    files_textbox.insert(tk.END, f"path: {folder_path}\n")

    # Obtem informações dos arquivos
    # *****************************
    region, service_type, service_name = extract_info_from_path(folder_path)
    files_textbox.insert(tk.END, f"região: {region} Serviço: {service_type} Nome: {service_name}\n")
    if not region or not service_type or not service_name:
        messagebox.showerror("Error", "Não foi possível extrair as informações do caminho da pasta.")
        return
    
    bucket_name, dynamodb_table, profile = read_backend_hcl(folder_path)
    if not bucket_name or not dynamodb_table or not profile:
        messagebox.showerror("Error", "Não foi possível extrair as informações do arquivo backend.hcl.")
        return

    # Converte todos arquivos jsons e hcls
    # ***********************************
    search_and_create_hcl_files(folder_path)

    session = boto3.Session(profile_name=profile)

    remove_old_tfstate(folder_path, service_type, region, service_name, bucket_name, dynamodb_table, session)

    service_type = service_type.lower()
    if service_type == "iam-roles":
        service_type = "iam-role"
    elif service_type == "iam-policies":
        service_type == "iam-policy"
    
    tags = read_main_tf(folder_path)
    if tags:
        create_tags_hcl(folder_path, tags)
        files_textbox.insert(tk.END, "Arquivo tags.hcl criado com sucesso.\n")
    else:
        messagebox.showerror("Error", "Não foi possível ler as tags do arquivo main.tf.")
        return
    
    create_terragrunt_hcl(folder_path, service_type)
    files_textbox.insert(tk.END, "Arquivo terragrunt.hcl criado com sucesso.\n")
    
    create_import_tf(folder_path, service_type, service_name, session)
    files_textbox.insert(tk.END, "Arquivo import.tf criado com sucesso.\n")
    print(service_type)

    try:
        # Verifica se os arquivos outputs.tf e variables.tf estão vazios e apaga se estiverem
        for file in ["outputs.tf", "variables.tf", "backend.hcl", "versions.tf", "main.tf"]:
            file_path = os.path.join(folder_path, file)
            if os.path.isfile(file_path): #and os.path.getsize(file_path) == 0
                files_textbox.insert(tk.END, f"Remove {file_path}\n")
                os.remove(file_path)
            else:
                print(f"Verifique os arquivos {file_path}.tf")

        # Adiciona a confirmação na caixa de texto
        files_textbox.insert(tk.END, f"Processamento concluído.\nRegião: {region}\nTipo de Serviço: {service_type}\nNome do Serviço: {service_name}\n\nComandos executados com sucesso.\n")
        
        # Mostra a última linha da caixa de texto
        files_textbox.see(tk.END)
        
        # Configura o files_textbox com a próxima pasta na estrutura de diretório
        next_folder_path = get_next_folder_path(folder_path)
        folder_path_var.set(next_folder_path)
        files_textbox.insert(tk.END, f"Próxima pasta: {next_folder_path}\n")
        
        print(f"refactor({service_type}/{service_name}): terragrunt migration")
    except ClientError as e:
        messagebox.showerror("Error", f"Erro ao executar o comando:\n{e.response['Error']['Message']}")

      

def commit_and_push():
    folder_path = folder_path_var.get()
    region, service_type, service_name = extract_info_from_path(folder_path)
    if not region or not service_type or not service_name:
        messagebox.showerror("Error", "Não foi possível extrair as informações do caminho da pasta.")
        return
    git_commit_and_push(folder_path, service_type, service_name)


# Cria a janela principal
root = tk.Tk()
root.title("Ferramenta de Migração de Repositório")
root.geometry("600x400")  # Define o tamanho da janela para 600x400 pixels

# Cria uma StringVar para armazenar o caminho da pasta
folder_path_var = tk.StringVar(value=load_last_folder())

# Cria e posiciona os widgets
select_button = tk.Button(root, text="Selecionar Pasta", command=select_folder)
select_button.pack(pady=10)

frame = tk.Frame(root)
frame.pack(pady=5)

folder_path_entry = tk.Entry(frame, textvariable=folder_path_var, width=50)
folder_path_entry.pack(side=tk.LEFT, padx=5)

# Adiciona a Scrollbar
text_frame = tk.Frame(root)
text_frame.pack(pady=10)

scrollbar = tk.Scrollbar(text_frame)
scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

files_textbox = tk.Text(text_frame, width=50, height=15, yscrollcommand=scrollbar.set)
files_textbox.pack(side=tk.LEFT)

scrollbar.config(command=files_textbox.yview)

# Adiciona os botões abaixo da caixa de texto
buttons_frame = tk.Frame(root)
buttons_frame.pack(pady=10)

process_button = tk.Button(buttons_frame, text="Processar", command=process_files)
process_button.pack(side=tk.LEFT, padx=5)

commit_button = tk.Button(buttons_frame, text="Commit e Push", command=commit_and_push)
commit_button.pack(side=tk.LEFT, padx=5)

# Executa a aplicação
root.mainloop()