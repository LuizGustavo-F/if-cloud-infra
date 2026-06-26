## Passo 1.2: Criar a Instância

Execute o comando `server create` utilizando os parâmetros definidos nas listagens anteriores. Certifique-se de associar uma chave de acesso válida:

```bash
microstack.openstack server create \
  --image "Ubuntu-24.04-LTS" \
  --flavor if.small \
  --network test \
  --key-name chave-producao \
  Nome_Da_Sua_VM
```

## Passo 1.3: Alocação e Associação de IP Flutuante (Floating IP)

Para permitir que a máquina virtual receba conexões externas ou internet direta de fora da rede virtualizada do OpenStack, é preciso atrelar um IP Flutuante à instância:

```bash
# 1. Criar/Alocar um novo IP flutuante a partir do pool da rede pública
microstack.openstack floating ip create external

# 2. Associar o IP gerado (ex: 10.1.141.X) à sua nova máquina virtual
microstack.openstack server add floating ip Nome_Da_Sua_VM <IP_GERADO>
```

## Passo 1.4: Acesso Remoto Segurado via SSH

Com o IP associado e as regras do Security Group permitindo o tráfego na porta 22 (SSH), execute o acesso a partir do seu terminal de preferência usando a chave privada correspondente:

```bash
ssh -i /caminho/da/sua/chave_privada ubuntu@<IP_FLUTUANTE_DA_VM>
```

### Lista de comandos basicos

```bash
# 1. Listar key de acesso ao horizon
sudo snap get microstack config.credentials.keystone-password

# 2. Listar imagens disponiveis
microstack.openstack image list

# 3. Listar flavors (predefinições)
microstack.openstack flavor list

# 4. Listar todos os servidores disponiveis
microstack.openstack server list

# 5. Listar interfaces disponiveis no servidor
microstack.openstack network list
```