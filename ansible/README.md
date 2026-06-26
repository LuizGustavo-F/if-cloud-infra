# Automação de Configuração (Ansible) - IF Cloud

Este diretório contém a base de **Infrastructure as Code (IaC)** para a configuração de software e serviços das máquinas virtuais provisionadas no OpenStack.  
O objetivo é garantir que toda VM nasça **padronizada e monitorada**, sem intervenção manual.

---

##  O que o Playbook `setup_vm.yml` faz?

Atualmente, a automação está configurada para entrar em qualquer máquina recém-criada pelo Terraform e executar as seguintes tarefas de forma **idempotente**:

1. **Atualização do Sistema**  
   Atualiza o cache do gerenciador de pacotes (`apt`)

2. **Docker Engine**  
   Instala o Docker e suas dependências (`ca-certificates`, `curl`) para habilitar o uso de containers na nuvem

3. **Monitoramento (Zabbix)**  
   - Baixa o repositório oficial do Zabbix (versão 7.0 para Ubuntu 24.04)  
   - Instala o `zabbix-agent`  
   - Garante que o serviço inicie automaticamente com a VM  

---

## Pré-requisitos

Para executar o Ansible a partir do nó de controle (Nutanix), é obrigatório possuir a chave de segurança privada do OpenStack.

1. A chave `chave-producao.pem` deve estar no nó de controle  
2. A chave **precisa** estar blindada (somente leitura para o dono):

```bash
chmod 400 /caminho/para/chave-producao.pem
```

---

##  Como Executar

### 1. Teste de Conexão (Ping)

Valida se o Ansible consegue acessar a máquina e se o `config_drive` injetou a chave corretamente:

```bash
ansible app_servers -i hosts.ini -m ping
```

---

### 2. Provisionamento Completo

Aplica todas as configurações do playbook na VM:

```bash
/ usr / local / bin / ansible-playbook -i hosts.ini setup_vm.yml
```

---

### 3. Salve o Legado no Gitea

Agora, vamos carimbar essa documentação no seu repositório oficial:

```bash
cd /root/if-cloud-infra
git add ansible/README.md
git commit -m "docs: adiciona documentacao detalhada do modulo ansible"
git push origin main
```

---

*(Salve o arquivo com `CTRL+O`, `Enter`, e feche com `CTRL+X`)*