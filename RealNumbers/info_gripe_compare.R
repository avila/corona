library(tidyverse)


df_casos_br <- read_csv("data/infogripe/casos_br.csv")
df_casos_br %>% 
  ggplot(aes(y=casos, x=epiweek, group=ano, color=as.character(ano))) +
  geom_line() + 
  scale_x_continuous(breaks = seq(-12, 53, 4), minor_breaks = seq(-10, 63*7)/7)
View(df_casos_br)



reg_pattern2 <- "- (\\d+)"
reg_pattern1 <- '\\[(\\d+)'
df_2020 <- df_casos_br %>% filter(ano == 2020) 
df_2020 %>% mutate(
  # lb = as.numeric(stringr::str_match(value, reg_pattern)[2]),
  # ub = as.numeric(stringr::str_match(value, reg_pattern)[3]),
  a = readr::parse_number(as.numeric(stringr::str_extract(value, reg_pattern1)))#,  b = readr::parse_number(as.numeric(stringr::str_extract(value, reg_pattern2)))
)



str_split(str_extract(df_2020$value, match2), "-") %>% as.character() %>% 
  readr::parse_number()

value <- c("8297 [4524 - 14672] (100.0 % do país)","8297 [1234524 - 14123672] (100.0 % do país)")

match1 <- "\\[(\\d+)"
match2 <- "- (\\d+)"
reg_pattern <- "\\[(\\d+) - (\\d+)\\]"
stringr::str_extract(value, reg_pattern1) %>% readr::parse_number()
df_2020$lb <- readr::parse_number(stringr::str_extract(df_2020$value, match1))
df_2020$ub <- readr::parse_number(stringr::str_match(df_2020$value, match2)[,2])
df_2020
