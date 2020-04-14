library(tidyverse)
sys_time_local_old <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "pt_BR.utf8")

url <- paste0("https://raw.githubusercontent.com/datasciencecampus/google-mobility-reports-data/master/csvs/",
              "international_local_area_trends_G20_20200410.csv")
tib_translate <- tibble(
  categ_pt = c("Recreação", "Mercearias e farmácias", "Parques", "Transporte Público", "Locais de trabalho", "Residências"),
  category = c("Retail & recreation", "Grocery & pharmacy", "Parks", "Transit stations", "Workplace", "Residential"))

df <- read_csv(url) %>% 
  pivot_longer(-c("Country", "location", "category"), names_to = "date") %>% 
  mutate(date=as.Date(date)) %>% rename(country=Country) %>% 
  left_join(tib_translate)

upd <- format(max(df$date), "%d de %B")

df %>% filter(country=="BR") %>% 
  ggplot(aes(x=date, y=value, group=location)) +
  geom_line(alpha=1/5) +
  #geom_point(alpha=1/5) +
  #geom_smooth(method = "loess", se = T) +
  scale_x_date(date_breaks = "2 week", date_minor_breaks = "day", date_labels = "%b %d") +
  facet_wrap(~categ_pt) +
  gghighlight::gghighlight()
  ggtitle("Relatório de Mobilidade Google COVID-19: Estados Brasileiros", 
          paste0("Variação percentual, comparado ao baseline entre 3 jan - 6 fev")) +
  labs(caption = paste0("Código: github.com/avila\n",
                        "Dados retirados do relatório de ", upd, "\n",
                        "Dados extraídos do Mobility Report graph extractor (mobius) ",
                        "[github.com/datasciencecampus]"))
  

  
  
df %>% 
  #filter(country=="BR") %>% 
  ggplot(aes(x=date, y=value, group=location)) +
  geom_line(alpha=1/20) +
  #geom_point(alpha=1/5) +
  #geom_smooth(method = "loess", se = T) +
  scale_x_date(date_breaks = "2 week", date_minor_breaks = "day", date_labels = "%b %d") +
  facet_wrap(~categ_pt) +
  ggtitle("Google COVID-19 Community Mobility Report", 
          paste0("Estados Brasileiros (Baseado no relatório de ", upd, ")")) +
  labs(caption = "Código: github.com/avila\n\nDados extraídos usando Mobility Report graph extractor (mobius)\n do github.com/datasciencecampus")



## check 
df %>% 
  filter(country=="BR", location=="State of Acre") %>% 
  ggplot(aes(x=date, y=value, group=location)) +
  geom_line() +
  geom_area(mapping=aes(x=date, fill="#9898fb", alpha=1.)) +
  #geom_point(alpha=1/5) +
  #geom_smooth(method = "loess", se = T) +
  scale_x_date(date_breaks = "2 week", date_minor_breaks = "day", date_labels = "%b %d") +
  facet_wrap(~categ_pt) +
  ggtitle("Google COVID-19 Community Mobility Report", 
          paste0("Estados Brasileiros (Baseado no relatório de ", upd, ")")) +
  labs(caption = "Código: github.com/avila\n\nDados extraídos usando Mobility Report graph extractor (mobius)\n do github.com/datasciencecampus")







sys_time_local_old <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", sys_time_local_old)
