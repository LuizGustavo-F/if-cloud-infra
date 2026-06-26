# Provisionamento de Infraestrutura (Terraform) - IF Cloud

Este diretório contém os arquivos de configuração do Terraform responsáveis pelo ciclo de vida das instâncias (VMs) e recursos de rede na nuvem privada baseada em OpenStack (MicroStack).

---

## Recursos Gerenciados

O arquivo `main.tf` automatiza a criação de:

1. **Instância Compute**  
   Criação de VMs Ubuntu 24.04 com o flavor `if.small` (2GB RAM)

2. **Floating IP**  
   Alocação dinâmica de um endereço IP na rede externa (`10.1.141.x`)

3. **Associação de Rede**  
   Vinculação automática do IP flutuante à instância

---

## Detalhes de Implementação (Pulo do Gato)

Para o funcionamento correto no laboratório do IF, as seguintes configurações foram aplicadas:

- **`insecure = true`**  
  Permite a conexão com a API do OpenStack mesmo com certificados SSL autoassinados

- **`config_drive = true`**  
  Força a injeção da chave SSH (`key_pair`) via um drive virtual de configuração, contornando falhas de roteamento no serviço de Metadata

- **Protocolo HTTPS**  
  Ajustado para a porta 5000 do controlador Nginx

---

## Comandos Úteis

### Inicializar o diretório (Baixar providers)

```bash
terraform init
```

### Planejar e Aplicar mudanças

```bash
terraform apply
```

### Destruir a infraestrutura

```bash
terraform destroy
```

---

##  Outputs

Ao final do `apply`, o Terraform exporta automaticamente o valor `ip_final_da_vm`, que deve ser utilizado como entrada (inventory) para os playbooks do Ansible.

---

*(Salve com `CTRL+O`, `Enter` e saia com `CTRL+X`)*

---

## 3. Sincronizar com o Gitea

Agora vamos subir essa documentação e as alterações que fizemos no `main.tf` hoje (o `config_drive` e o `output`):

```bash
cd /root/if-cloud-infra
git add terraform/main.tf terraform/README.md
git commit -m "docs: detalha provisionamento terraform e uso de config_drive"
git push origin main
```
