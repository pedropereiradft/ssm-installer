# SSM Agent Instance Profile Attacher

Este projeto é responsável por associar um instance profile a uma instância EC2 e configurar a atualização automática do SSM Agent.

O projeto irá criar dois role, um que permite a EC2 ser gerenciada pelo SSM e outro que permite o SSM executar automações. Em seguida uma associação é criada para realizar a automação de atachar o primeiro role em todas as instâncias EC2 listadas.

Existe ainda uma segunda associação, ```update_ssm_agent_automation``` responsável por automatizar o processo de atualização do SSM Agent. Por padrão ela está desabilitada pela variável ```count = 0```. Isso é feito pois no geral as contas já possuem essa automação habilitada. Caso queira ativá-la, troque o valor para ```1```.

Abaixo segue a documentação do terraform aqui desenvolvido porém, nota-se que a única variável onde recomenda-se alteração é ```ec2_ids_list``` sendo que as outras podem ser utilizadas com o valor default. Nota-se ainda que o bloco ```backend``` também deve ser alterado com as informações do bucket de destino.

--------
## Requirements

| Name | Version |
|------|---------|
| terraform | > 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| null | n/a |
| time | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ec2\_ids\_list | Lista de IDs das instâncias EC2 onde será anexado o instance profile. | `list(string)` | n/a | yes |
| iam\_role\_for\_ssm\_automation\_description | n/a | `string` | `"IAM role que permite o SSM realizar automações."` | no |
| iam\_role\_for\_ssm\_automation\_name | Nome do IAM role que permite o SSM executar automações. | `string` | `"CloneAmazonSSMRoleForAutomationAssumeQuickSetup"` | no |
| instance\_profile\_role\_description | n/a | `string` | `"Instance profile que permitira o SSM gerenciar a instância EC2."` | no |
| instance\_profile\_role\_name | Nome do instance profile que permitira o SSM gerenciar a instância EC2. | `string` | `"CloneAmazonSSMRoleForInstancesQuickSetup"` | no |
| policy\_for\_ssm\_automation\_name | Nome da policy que permite o SSM realizar automações. | `string` | `"CloneSSSMOnboardingInlinePolicyAndQuickSetup"` | no |

## Outputs

No output.


## Execução

Para executar o projeto:

```bash
terraform init

terraform apply
```

Caso seja necessário executar um ```terraform destroy``` note que a AWS por padrão não deleta um instance profile quando o role que o representa é deletado. Desta forma, será necessário executar o seguinte comando manualmente: 

```aws iam delete-instance-profile --instance-profile-name CloneAmazonSSMRoleForInstancesQuickSetup```

Do contrário, as automações subsequentes irão falhar.

