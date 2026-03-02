# ☁️ IF Cloud - Infraestrutura como Código

##  Sobre o Projeto
O IF Cloud é uma plataforma provedora de serviços em nuvem privada, desenvolvida como projeto de extensão. O objetivo é fornecer infraestrutura robusta, gratuita e replicável (sandbox) para alunos e pesquisadores do Instituto, eliminando os altos custos e riscos associados a nuvens públicas (AWS, GCP).

## Objetivos
* Reaproveitamento de hardware local (Bare Metal).
* Virtualização de laboratórios com Hypervisor Tipo 1 (KVM/OpenStack).
* Automação de provisionamento utilizando Terraform e Ansible.
* Análise de viabilidade e overhead através de Benchmarks.

## 📂 Estrutura do Repositório
* `/docs` - Documentação de arquitetura e guias de uso.
* `/benchmark` - Scripts e resultados de testes (sysbench, fio).
* `/terraform` - Scripts de provisionamento de infraestrutura.
* `/ansible` - Playbooks de configuração dos laboratórios.
