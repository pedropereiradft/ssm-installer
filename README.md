# SSM Agent Installer Helper

Este projeto está dividido em três partes e ele tem como intuito auxiliar no processo de instalação do SSM Agent em instâncias. 
O processo de instalação pode ser divido da seguinte maneira:
* instalação do SSM Agent na instância
* atachar um instance profile na instância

**Observação**: Para evitar problemas conhecidos, a ordem de execução recomendada é: atachar instance profile nas instâncias alvo (```attach-iam-to-ec2```) e após isso instalar o agente (```install-ssm-playbook```). 

Dessa forma a divisão do projeto está feita da seguinte forma:

* ```list-ec2-ssm-state```: lista o estado de instalação do SSM Agent em todas as instâncias EC2 de uma conta AWS.
* ```install-ssm-playbook```: instala o SSM Agent nas distribuições mais comumente usadas.
* ```attach-iam-to-ec2```: atacha o instance profile necessário para que as instâncias EC2 sejam geridas pelo SSM.

O projeto ```list-ec2-ssm-state``` agrupa o output em 4 divisões, isso se dá devido a alguns casos especiais no processo de instalação do SSM Agent, os casos são descritos abaixo:

* Instâncias dentro de um auto scaling group: este representa um caso especial pelo fato de que as instâncias podem ser extremamente efêmeras, dessa forma a instalação perderia seu efeito rapidamente. Nesses casos existem três soluções:
    * Alterar o launch template do auto scaling group colocando os [passos de instalação](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html) do SSM Agent no ```user data```.
    * Criar uma nova ami para o auto scaling group e instalar o ssm agent nela. Após isso alterar o launch template para utilizar a nova AMI.
    * Executar a instalação da maneira usual. Essa opção é listada pois existem casos onde as instâncias de um auto scaling group não são destruídas com frequência, não havendo assim a necessidade de overhead de alteração do launch template.


* Instâncias com um instance profile atachado: este representa um caso especial pois um dos requisitos para a instalação do SSM Agent funcionar é que a instância tenha um instance profile com policies especificas atachadas e devido a uma restrição da AWS, uma instância EC2 só pode ter um instance profile atachado. Dessa forma a solução é alterar o instance profile que está atachado atualmente e incluir manualmente a managed policy ```AmazonSSMManagedInstanceCore```.

## Troubleshooting

Em caso de problemas durante a instalação consulte o seguinte [artigo](https://aws.amazon.com/premiumsupport/knowledge-center/systems-manager-ec2-instance-not-appear/).