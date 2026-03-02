
# 📊 Resultados de Benchmark - Linha de Base (Bare Metal)

Este documento registra os resultados dos testes de estresse realizados diretamente no hardware físico (Ubuntu Server 24.04), sem nenhuma camada de virtualização. Estes dados servirão como linha de base para calcular o *overhead* computacional do Hypervisor (KVM/OpenStack) no projeto IF Cloud.

## 🖥️ Teste de Estresse de CPU
Utilizamos o `sysbench` para calcular números primos, forçando todos os núcleos do processador.
* **Comando:** `sysbench cpu --cpu-max-prime=20000 --threads=$(nproc) run`
* **Threads utilizadas:** 12
* **Desempenho (Eventos por segundo):** 2607.59
* **Latência Média:** 4.60 ms
* **Latência Máxima:** 10.30 ms

## 🧠 Teste de Velocidade de Memória RAM
Teste de escrita massiva na memória para verificar a largura de banda.
* **Comando:** `sysbench memory --memory-block-size=1M --memory-total-size=100G --threads=$(nproc) run`
* **Volume transferido:** 100 GB (Blocos de 1MB)
* **Velocidade de Transferência:** 27644.42 MiB/sec
* **Latência Média:** 0.39 ms

## 💾 Teste de I/O de Disco (Leitura e Escrita Aleatória)
Utilizamos o `fio` para simular um cenário real de banco de dados ou múltiplos laboratórios acessando o disco simultaneamente (Random Read/Write).
* **Comando:** `fio --name=teste_baremetal --ioengine=libaio --rw=randrw --bs=4k --numjobs=1 --size=2G --iodepth=64 --runtime=60 --time_based --end_fsync=1`
* **Leitura (Read):** * IOPS: 79
  * Bandwidth (Largura de banda): 317 KiB/s
* **Escrita (Write):** * IOPS: 80
  * Bandwidth (Largura de banda): 321 KiB/s
