# Configuração de Rede (Netplan) - Nós OpenStack (Avamar Gen4S)

Este diretório contém os backups e a documentação das configurações de rede (Netplan) utilizadas nos servidores físicos que compõem o cluster OpenStack do CTI. 

A infraestrutura é operada sobre dois nós distintos:
* **Control Node:** Avamar Gen4S Utility Node
* **Compute Node:** Avamar Gen4S Storage Node

## Arquitetura de Rede e Justificativa (Provider Network)

A configuração de rede destes servidores difere de um setup Linux tradicional. Para suportar a topologia de *Provider Network* (onde as VMs recebem IPs roteáveis da rede física do IFMT), o endereço IP principal de cada servidor **não está atribuído à interface de rede física** (`eno1`), mas sim a uma interface de bridge virtual (`br-ex`).

### Por que o IP não fica na interface física?

O OpenStack utiliza o switch virtual (`br-ex`) para orquestrar o tráfego externo das instâncias (VMs). A interface física (`eno1`) é anexada como uma porta dentro desse switch lógico. Manter um IP configurado diretamente na interface física enquanto ela atua como membro do bridge causa:

1. **Conflitos de Roteamento:** O kernel do Linux perde a referência exata de qual interface deve processar os pacotes, resultando em perda de conectividade intermitente.
2. **Problemas de Resolução ARP:** Inconsistências de MAC Address e respostas ARP duplicadas na rede do laboratório.
3. **Falha de Conectividade nas VMs:** O roteamento dos IPs Flutuantes (Floating IPs) para as instâncias é quebrado.

### A Solução Adotada em Ambos os Nós

Para garantir a estabilidade do hipervisor e o roteamento correto das máquinas dos alunos, o Netplan de ambos os servidores foi estruturado da seguinte forma:

* **Interface Física (`eno1`):** Configurada sem endereço IP (`dhcp4: no`, sem bloco `addresses`). Atua estritamente como o enlace físico (Uplink) entre o switch virtual e o switch real do laboratório.
* **Bridge Virtual (`br-ex`):** Configurada com o endereço IP estático de gerência de cada respectivo nó, Gateway (`10.1.141.254`) e Servidores DNS (`10.1.137.3`, `10.1.137.4`). Todo o tráfego do host e das instâncias transita de forma limpa por esta interface.