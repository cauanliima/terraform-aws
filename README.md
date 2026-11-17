# Terraform AWS

Este repositório reúne exemplos de infraestrutura como código com Terraform para AWS, organizados em módulos/pastas independentes para demonstrar a criação de rede e instâncias EC2, além do uso de `remote state`.

## Estrutura do repositório

```text
terraform-aws/
├── aws-common/                         # configuração base do provider AWS
├── aws-vnet/                           # criação de VPC, subnet, gateway e security group
├── aws-vm-com-vnet-remote-state/        # criação de EC2 conectada à VPC via remote state
├── aws.md                              # instruções de variáveis de ambiente AWS
├── README.md                           # documentação geral do projeto
└── .git/
```

## Descrição das pastas

### `aws-common`

Contém a configuração mínima do provider AWS e a definição da região padrão.

Arquivos principais:
- `main.tf`: define o provider `hashicorp/aws` com versão `~> 6.0` e usa `var.region`.
- `variables.tf`: define a variável `region` com valor padrão `sa-east-1`.

### `aws-vnet`

Cria uma rede VPC na AWS com infraestrutura básica para acesso público.

Recursos provisionados:
- VPC
- Subnet pública
- Internet Gateway
- Route Table pública
- Associação da subnet à tabela de roteamento
- Security Group com regras de entrada para SSH, HTTP e porta `30080`
- Saída de rede para internet

Arquivos principais:
- `main.tf`: configura o backend S3 para estado remoto com bucket `cauan-terraform-state-2026` e chave `aws-vpc/terraform.tfstate`
- `network.tf`: define os recursos de rede e segurança
- `locals.tf`: define `common_tags` com `owner = "cauanlima"` e `managed-by = "terraform"`
- `variables.tf`: região padrão `sa-east-1`
- `outputs.tf`: expõe `subnet_id` e `security_group_id`

### `aws-vm-com-vnet-remote-state`

Cria uma instância EC2 em uma VPC previamente criada e acessa os dados da rede por `terraform_remote_state`.

Funcionalidades:
- busca a AMI Debian 12 x86_64
- cria um `aws_key_pair` usando a chave pública `id_rsa.pub`
- cria um Elastic IP público
- cria uma interface de rede vinculada à subnet da VPC remota
- associa o EIP à interface de rede
- cria a instância EC2 com `t3.micro` e volume raiz de `64 GB`

Arquivos principais:
- `main.tf`: define o backend S3 e carrega o estado remoto da VPC via `data "terraform_remote_state" "vpc"`
- `vm.tf`: provisiona AMI, key pair, EIP, network interface, associação e instância EC2
- `locals.tf`: tags compartilhadas da infraestrutura
- `variables.tf`: região padrão `sa-east-1`
- `outputs.tf`: expõe `vm_public_ip`

## Fluxo de uso

1. Configure as credenciais da AWS:
   - consulte o arquivo `aws.md`
   - defina as variáveis de ambiente `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_DEFAULT_REGION`

2. Inicialize a VPC:

```bash
cd aws-vnet
terraform init
terraform plan
terraform apply
```

3. Após a VPC ficar disponível no backend remoto, provisiona a VM:

```bash
cd ../aws-vm-com-vnet-remote-state
terraform init
terraform plan
terraform apply
```

4. A saída final da VM expõe o IP público da instância EC2.

## Observações importantes

- O projeto usa backend remoto S3 para armazenamento do estado:
  - bucket: `cauan-terraform-state-2026`
  - região: `sa-east-1`
- A criação da VM depende da VPC criada em `aws-vnet`, pois ela lê os IDs da subnet e do security group a partir do estado remoto.
- A chave pública da instância está no arquivo `aws-vm-com-vnet-remote-state/id_rsa.pub`.
- O projeto define tags padrão em todos os recursos, como `owner` e `managed-by`.

## Requisitos

- Terraform >= 1.3.0
- Provider AWS `~> 6.0`
- Credenciais válidas da AWS
- Permissões para criar VPCs, subnets, security groups, gateways e instâncias EC2

## Arquivo de ambiente AWS

O arquivo `aws.md` contém as variáveis de ambiente necessárias para autenticação na AWS, por exemplo:

```bash
SET AWS_ACCESS_KEY_ID=
SET AWS_SECRET_ACCESS_KEY=
SET AWS_DEFAULT_REGION="sa-east-1"
```

## Conclusão

Este repositório serve como exemplo prático de criação básica de infraestrutura AWS com Terraform, incluindo:
- criação de rede em VPC
- configuração de segurança
- uso de backend S3 para estado remoto
- provisionamento de instância EC2 conectada à rede existente

Se o objetivo for aplicar todos os recursos do projeto, a ordem correta é primeiro `aws-vnet` e depois `aws-vm-com-vnet-remote-state`.
