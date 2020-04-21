

mygrid <- data.frame(
  name = c("Roraima", "Amapá", "Ceará", "Pará", "Amazonas", "Maranhão", "Rio Grande do Norte", "Paraíba", "Acre", "Piauí", "Rondônia", "Tocantins", "Pernambuco", "Mato Grosso", "Alagoas", "Sergipe", "Goiás", "Bahia", "Distrito Federal", "Espírito Santo", "Mato Grosso do Sul", "Minas Gerais", "Rio de Janeiro", "São Paulo", "Paraná", "Rio Grande do Sul", "Santa Catarina"),
  code = c("RR", "AP", "CE", "PA", "AM", "MA", "RN", "PB", "AC", "PI", "RO", "TO", "PE", "MT", "AL", "SE", "GO", "BA", "DF", "ES", "MS", "MG", "RJ", "SP", "PR", "RS", "SC"),
  row = c(1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 7, 7),
  col = c(2, 3, 4, 2, 1, 3, 5, 6, 1, 4, 2, 3, 5, 2, 6, 5, 3, 4, 3, 5, 2, 4, 5, 4, 3, 4, 3),
  stringsAsFactors = FALSE
)
geofacet::grid_preview(mygrid)

