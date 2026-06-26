# Documentação de Infraestrutura - IF Cloud (Arquitetura GitOps)

Este repositório atua como a única fonte da verdade (Infrastructure as Code - IaC) para o provisionamento, configuração e automação da nuvem privada acadêmica do IFMT (Campus Cuiabá). 

A arquitetura evoluiu de um modelo de gerenciamento manual em um servidor único para um paradigma **GitOps** descentralizado e totalmente automatizado, operando sobre uma topologia robusta de múltiplos nós, oferecendo recursos de autoatendimento (Self-Service) para os alunos e pesquisadores do CTI.

## 1. Especificações da Infraestrutura Base (Hardware e Virtualização)
O ambiente foi modernizado e descentralizado para garantir resiliência e alta capacidade de processamento. A nuvem agora opera sobre um cluster corporativo de alta densidade reaproveitado da instituição, separando os planos de controle e computação.

### 1.1. Control Node (Nó de Gerenciamento OpenStack)
Servidor responsável por hospedar os serviços de controle da nuvem (APIs, Banco de Dados, Mensageria e agendamento).
* **Equipamento:** Avamar Gen4S Utility Node
* **Sistema Operacional:** Ubuntu 24.04 LTS
* **Processamento:** 2 x Intel Xeon E5-2680 v1
* **Memória RAM:** 256 GB
* **Armazenamento:** 1.2 TB HDD SAS
* **Rede:** 10.1.141.25

### 1.2. Compute Node (Hipervisor)
Servidor de força bruta focado exclusivamente em provisionar e sustentar as instâncias (VMs) dos alunos.
* **Equipamento:** Avamar Gen4S Storage Node
* **Sistema Operacional:** Ubuntu 24.04 LTS
* **Processamento:** 2 x Intel Xeon E5-2680 v1
* **Memória RAM:** 256 GB
* **Armazenamento:** 6 TB HDD SATA
* **Rede:** 10.1.141.26

### 1.3. Camada de Interface e Integração (Nutanix)
Ambiente consolidado do CTI responsável por hospedar as ferramentas de controle da esteira, garantindo que o portal não sofra downtime caso o cluster OpenStack passe por manutenções físicas.
* **Portal de Autoatendimento (Django):** Hospedado em VM isolada no cluster Nutanix.
* **Servidor de CI/CD (Gitea + Actions):** IP `10.1.141.15`

## 2. Topologia e Configuração de Rede
A conectividade dos servidores base exige IPs estáticos para garantir a estabilidade do hipervisor e das rotas de automação.

* **Interface de Rede Ativa (Control e Compute):** `eno1`
* **Gateway Padrão:** `10.1.141.254`
* **Servidores DNS:** `10.1.137.3`, `10.1.137.4`
* **Domínio de Busca:** `cba.local`

> **Nota de Restauração:** O arquivo YAML oficial de configuração do Netplan dos servidores físicos está salvo no diretório `/rede/config-netplan.yaml` deste repositório.

## 3. A Esteira de Automação (CI/CD)
O provisionamento de novos servidores não requer mais intervenção manual no painel do OpenStack. O fluxo de ponta a ponta funciona da seguinte forma:

1. **Frontend (Portal Django):** O aluno acessa a interface web, preenche o nome do projeto e seleciona o flavor da VM (ex: `if.small`).
2. **Integração (API Rest):** O portal realiza um *commit* automático injetando a nova máquina no arquivo `terraform/servidores.auto.tfvars`.
3. **Gatilho (Gitea Actions):** O repositório detecta a mudança e acorda o *Runner* (`act_runner`).
4. **Provisionamento (Terraform):** Conecta-se ao OpenStack e constrói a infraestrutura solicitada.
5. **Configuração Pós-Deploy (Ansible):** Assume o controle da VM recém-criada, atualiza pacotes e instala dependências vitais (Docker, Zabbix Agent).

### 3.1. O Princípio da Idempotência
A esteira do Ansible opera por estado desejado. A cada execução, ele revisita todas as instâncias ativas para garantir que nenhum servidor sofreu desvio de configuração (*Configuration Drift*), aplicando mudanças apenas nas máquinas novas ou corrigindo serviços que foram alterados indevidamente.

## 4. Arquitetura de Rede Avançada (Provider Network)
Para evitar o duplo NAT padrão do OpenStack e garantir acesso direto às instâncias, a infraestrutura opera no modelo de *Provider Network* (Rede Flat).

1. A interface física do servidor (`eno1`) foi anexada diretamente ao switch virtual (`br-ex`).
2. O pool de IPs Flutuantes aloca endereços acessíveis nativamente pela rede da instituição.
   * **Faixa Reservada para VMs:** `10.1.141.160` a `10.1.141.170`.
3. As instâncias recebem roteamento na Camada 2/3 da rede física, permitindo acesso direto via SSH sem a necessidade de *JumpHosts*.

## 5. Monitoramento de Recursos
A telemetria da nuvem atua em duas frentes distintas, consolidadas no servidor central `10.1.140.70`:

* **Monitoramento do Bare Metal:** Agente Zabbix instalado diretamente no Ubuntu host (Avamar Nodes) para aferir o *overhead* do hipervisor e a saúde dos discos SAS/SATA.
* **Monitoramento das Instâncias:** Injeção automatizada do Zabbix Agent via Ansible em todas as VMs criadas pelos alunos (Template Ubuntu 24.04).

## 6. Estrutura do Repositório
```
if-cloud-infra/
├── ansible/                   # Playbooks e inventário dinâmico (Instalação Docker e Zabbix)
├── terraform/                 # Arquivos de provisionamento OpenStack (.tf e .tfvars)
├── docs/                      # Diagramas e documentação de apoio
├── rede/                      # Backup de configurações estruturais (Netplan)
└── .gitea/workflows/          # Definição da esteira CI/CD (Pipeline)
```

## 7. Base de Conhecimento e Troubleshooting Histórico
Durante o provisionamento do ambiente, desafios arquiteturais foram resolvidos e registrados para referência:

* **Latência de I/O e Timeout de Metadados:** 
  * *Problema:* Falha na injeção do `cloud-init` via rede (`169.254.169.254`) por gargalo de disco.
  * *Solução:* Adoção obrigatória do parâmetro `--config-drive True` no Terraform para montagem de unidade de bloco local.
* **Segurança e Criptografia (Ubuntu 24.04):**
  * *Problema:* O SO restringe conexões baseadas em chaves RSA legadas.
  * *Solução:* Forçamento via *flags* do OpenSSH (`PubkeyAcceptedKeyTypes`) durante automações.
* **Controle de Acesso (ACLs) em Clientes Windows:**
  * *Problema:* Bloqueio de uso de chaves `.pem` devido a permissões herdadas do domínio (`UNPROTECTED PRIVATE KEY FILE`).
  * *Solução:* Restrição estrita via CMD (`icacls chave.pem /inheritance:r` e `/grant "%username%:R"`).

---
*Arquitetura mantida e desenvolvida pelo CTI - Instituto Federal de Mato Grosso.*