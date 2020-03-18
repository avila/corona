library(magrittr)
library(dplyr)
library(tidyr)

url <- "http://plataforma.saude.gov.br/novocoronavirus/#COVID-19-brazil/"
page_br <- xml2::read_html(url)

df_br <- page_br %>% rvest::html_node(xpath = '/html/body/div[2]/div[2]/div[6]/div')
df_br

  rvest::html_table(fill = TRUE, trim=T, header=T) %>% 
  filter(row_number() %in% (2:(n()-1)) ) %>% 
  rename 

br_states <- c("AL", "AM", "BA", "DF", "ES", "GO", "MG", "PE", "PR", "RJ", "RN",
               "RS", "SC", "SP", "MS", "SE", "AC", "RO", "PA", "RR", "AP", "TO",
               "MA", "PI", "CE", "PB", "MT")

