# Guia Rápido: Configuração de IPs Flutuantes (MicroStack CLI)

Este roteiro substitui a rede externa padrão (falsa) do MicroStack por uma sub-rede real da infraestrutura, limitando a distribuição de IPs a um range específico (Allocation Pool) para evitar conflitos na rede física.

## Fase 1: Identificação e Isolamento

O MicroStack bloqueia a exclusão da sub-rede padrão (geralmente 10.20.20.0/24) porque o roteador virtual de teste já nasce conectado a ela (Erro 409: ConflictException). É preciso isolar a rede primeiro.

### 1. Identifique o ID da sub-rede padrão:
```bash
sudo microstack.openstack subnet list
```

(Anote o NOME ou o ID da sub-rede atrelada à rede external, geralmente chamada ipv4-subnet ou external-subnet).

### 2. Identifique o Roteador:
```bash
sudo microstack.openstack router list
```

(Anote o nome do roteador, por padrão é test-router).

### 3. Desplugue o Roteador da rede externa:
```bash
sudo microstack.openstack router unset --external-gateway test-router
```

### 4. Limpe IPs Flutuantes residuais (Se houver):
```bash
sudo microstack.openstack floating ip list
```

(Se listar algum IP da rede antiga, apague com o comando abaixo. Se não listar nada, pule este passo).

```bash
sudo microstack.openstack floating ip delete <ID_DO_IP>
```

## Fase 2: Exclusão e Recriação

Com a rede antiga isolada de qualquer dispositivo, o bloqueio de segurança do OpenStack é desfeito.

### 1. Delete a sub-rede antiga:
```bash
sudo microstack.openstack subnet delete <NOME_OU_ID_DA_SUBNET_ANTIGA>
```

### 2. Crie a nova Sub-rede Oficial (Ex: VLAN 241):
Neste passo, injetamos as configurações exatas do laboratório. O parâmetro --no-dhcp é obrigatório para que o OpenStack não atue como servidor DHCP na rede física da instituição.

```bash
sudo microstack.openstack subnet create vlan241-ext   --network external   --subnet-range 10.1.141.0/24   --no-dhcp   --gateway 10.1.141.254   --allocation-pool start=10.1.141.160,end=10.1.141.170   --dns-nameserver 10.1.137.3   --dns-nameserver 10.1.137.4
```

## Fase 3: Reintegração

Agora que a rede external possui a sub-rede correta e com o cofre de IPs configurado, o roteador virtual precisa ser reconectado para dar acesso à internet para as futuras instâncias.

### 1. Reconecte o roteador à rede externa:
```bash
sudo microstack.openstack router set --external-gateway external test-router
```

## Status Esperado após a execução:

As instâncias criadas nas redes internas sairão para a internet passando pelo test-router, que agora encaminha o tráfego para o gateway físico 10.1.141.254.

Ao solicitar um IP Flutuante (Floating IP) para expor uma VM, o OpenStack sorteará automaticamente um endereço disponível apenas entre o final .160 e .170.
