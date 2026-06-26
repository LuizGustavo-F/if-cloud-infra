variable "lista_de_vms" {
  description = "Mapa contendo os nomes, tamanhos e chaves de todas as VMs"
  type = map(object({
    tamanho   = string
    chave_pub = optional(string, "") # Opcional para não quebrar as VMs antigas
  }))
}