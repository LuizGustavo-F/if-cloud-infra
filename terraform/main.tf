terraform {
  backend "local" {
    path = "/root/estado-terraform/producao.tfstate"
  }
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Autenticação na API do OpenStack
provider "openstack" {
  region   = "microstack"
  insecure = true
}


# secgoup rule (firewall)
resource "openstack_networking_secgroup_rule_v2" "zabbix_agent_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10050
  port_range_max    = 10050
  remote_ip_prefix  = "10.1.140.70/32" 
  security_group_id = "d7c02cf1-bfef-482c-b25a-633177af6b6c" # ID do grupo 'default'
}

# construção da lista de VM's
resource "openstack_compute_instance_v2" "vm" {
  for_each        = var.lista_de_vms
  name            = each.key
  flavor_name     = each.value.tamanho
  image_name      = "Ubuntu-24.04-LTS"
  
  key_pair        = "chave-producao"
  config_drive    = true
  security_groups = ["default"]
  network {
    name = "test"
  }

  user_data = each.value.chave_pub != "" ? "#cloud-config\nssh_authorized_keys:\n  - ${each.value.chave_pub}\n" : ""
}

# solicita lista de ip's disponiveis
resource "openstack_networking_floatingip_v2" "fip" {
  for_each = var.lista_de_vms
  pool     = "external"
}

# vincula ip na maquina
resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  for_each    = var.lista_de_vms
  floating_ip = openstack_networking_floatingip_v2.fip[each.key].address
  instance_id = openstack_compute_instance_v2.vm[each.key].id
}

# aciona a esteira
resource "local_file" "ansible_inventory" {
  content  = <<EOF
[app_servers]
%{ for nome, vm in openstack_compute_instance_v2.vm ~}
${nome} ansible_host=${openstack_networking_floatingip_v2.fip[nome].address} ansible_user=ubuntu ansible_ssh_private_key_file=../chave-producao.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor ~}
EOF
  filename = "../ansible/hosts.ini"
}

# aciona ansible para conf final
resource "null_resource" "run_ansible" {

  triggers = {
    ids_das_vms = join(",", [for vm in openstack_compute_instance_v2.vm : vm.id])
  }
  depends_on = [
    openstack_compute_floatingip_associate_v2.fip_assoc,
    local_file.ansible_inventory
  ]
  provisioner "local-exec" {
    command = "sleep 45 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/hosts.ini ../ansible/setup_vm.yml"
  }
}