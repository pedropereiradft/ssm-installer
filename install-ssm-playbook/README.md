# SSM Agent Installer

Este projeto é utilizado para instalar o SSM Agent em uma instância. Ele utiliza a ferramenta ```ansible``` a qual identifica qual o sistema operacional instalado na instância e de acordo com este realiza a instalação do agente de maneira adequada.

Para utilizar o projeto, primeiramente preencha as informações relativas ao host no arquivo ```inventory/hosts.yml```. Feito isso execute:

```ansible-playbook playbook.yml```

Atualmente o projeto é capaz de realizar a instalação do agente nas seguinte distribuições:

  * Amazon Linux 1/2
  * CentOS 6/7/8
  * RHEL 6/7/8
  * Debian 8/9/10
  * SUSE 12
  * Ubuntu 14/16/18/20

Caso o sistema operacional do host onde você deseje instalar o agente não esteja contemplado acima, favor incluí-lo no arquivo ```playbook.yml```.