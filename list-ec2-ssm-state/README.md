# SSM Agent Checker

**Disclaimer:** O código pode levar alguns minutos para finalizar sua execução em contas com um número elevado de instâncias e/ou use múltiplas regiões.

Este projeto é utilizado para varrer todas as instâncias EC2 de uma conta na AWS e retornar o status de instalação do SSM Agent em cada uma delas.

Para utilizar o script tenha a ferramenta [poetry](https://github.com/python-poetry/poetry) instalada e execute o seguinte comando:

```poetry install```

Em seguida, para executar o script:

```bash
poetry shell
python src/main.py
```

Importante notar que o script utiliza a variável de ambiente ```AWS_PROFILE``` para criar o arquivo de output contendo as informações de status das instância, portanto, certifique-se de que essa variável esteja definida corretamente antes da execução do script.

Abaixo segue um exemplo de output e como interpretá-lo

```json
{
  "instances": {
    "us-east-1": [
      {
        "id": "i-08798566a16aa3499",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/Cron",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": null
      },
      {
        "id": "i-08bad8dbca3cc8aad",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/NAT-Gateway",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": null
      },
      {
        "id": "i-0f1c508050d72836b",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/stream",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": "FullArmStream"
      },
      {
        "id": "i-0384195444918a614",
        "instance_profile": null,
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": null
      },
      {
        "id": "i-03ccba9a167aecfa8",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/mongo",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": null
      },
      {
        "id": "i-041aa3d13479c8e72",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/fullarm-deploy",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": null
      },
      {
        "id": "i-025ae84575d7bb2b1",
        "instance_profile": null,
        "is_running": false,
        "is_ssm_present": false,
        "auto_scaling_group_name": null
      },
      {
        "id": "i-06ca7ac4748c511ec",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/FullArm-Adm",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": "FullArmADM"
      },
      {
        "id": "i-05a2c3e84aeba2875",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/ecsInstanceRole",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": "EC2ContainerService-Consumers-EcsInstanceAsg-BN3S5ELJFAIR"
      },
      {
        "id": "i-0f0dfc39ed9992edb",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/FullArmAPI",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": "FullArmAPI"
      },
      {
        "id": "i-0da6fe530e06d035c",
        "instance_profile": "arn:aws:iam::958501182148:instance-profile/aws-elasticbeanstalk-ec2-role",
        "is_running": true,
        "is_ssm_present": false,
        "auto_scaling_group_name": "awseb-e-pg9khemxkv-stack-AWSEBAutoScalingGroup-92MEXEE7BAN9"
      }
    ]
  },
  "ssm_cases": {
    "cant_verify": [
      "i-017c7454a3c22f665",
      "i-07ff32379e1f81ac7",
      "i-099f30866c62d73d0"
    ],
    "installed": [
      "i-05dea8764f0cf6540"
    ],
    "not_installed": [
      "i-0c11154fb4b23e285",
      "i-05ce41d3d58b42b1f",
      "i-099f30866c62d73d0"
    ],
    "not_installed_inside_ag": [
      "i-0f1c508050d72836b (FullArmStream)",
      "i-06ca7ac4748c511ec (FullArmADM)",
      "i-0b15d64d53d660a7a (EC2ContainerService-Consumers-EcsInstanceAsg-1VOJ3BPI2LWL0)",
      "i-0aa14c11cd4b96173 (EC2ContainerService-Gateways-EcsInstanceAsg-Q7W8VKI4OGDY)"
    ],
    "not_installed_with_instance_profile": [
      "i-08798566a16aa3499 (Cron)",
      "i-0f1c508050d72836b (stream)",
      "i-03ccba9a167aecfa8 (mongo)"
    ]
  }
}
```
O objeto ```instances``` é dividido por regiões, sendo que cada região possui uma lista de suas instâncias e algumas informações adicionais como: instance profile, presença de ssm e se faz parte de um auto scaling group.

O objeto ```ssm_cases``` possui cinco listas, sendo elas:

* ```cant_verify```: agrupa todas as instâncias que não estão ativas no momento representando assim aquelas onde não foi possível verificar a instalação do SSM Agent.
* ```installed```: instâncias com SSM Agent instalado e funcionando.
* ```not_installed```: instâncias sem o SSM Agent instalado.
* ```not_installed_inside_ag```: instâncias sem o SSM Agent instalado e que fazem parte de um Auto Scaling Group. Note que ```not_installed_inside_ag``` ⊄ ```not_installed```. Entre parentêses está o nome do Auto Scaling Group.
* ```not_installed_with_instance_profile```: instâncias sem o SSM Agent instalado e que possuem um instance profile atachado. Entre parentêses está o nome do instance profile.