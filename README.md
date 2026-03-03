# ☁️ IF Cloud - Infraestrutura como Código

## 🌥 Visão de Produto – IF Cloud

Para alunos de pós-graduação e pesquisadores do Instituto Federal que necessitam de infraestrutura computacional robusta, escalável e reprodutível para execução de experimentos acadêmicos, mas enfrentam limitações orçamentárias e barreiras financeiras associadas à nuvem pública, o IF Cloud é uma plataforma de nuvem acadêmica institucional que permite provisionar servidores e laboratórios virtuais sob demanda, de forma gratuita, segura e controlada, promovendo autonomia tecnológica e fortalecimento da pesquisa aplicada.

Diferente de provedores comerciais como AWS e GCP, que operam com cobrança em moeda estrangeira e risco financeiro para estudantes, nosso produto reutiliza a infraestrutura local da instituição para oferecer um ambiente sandbox estável, sustentável e acessível, eliminando barreiras econômicas e incentivando a democratização do acesso à computação em nuvem.

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
