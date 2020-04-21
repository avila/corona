## Download data 
library(tidyverse)

# some parameters
sys_time_local_old <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "pt_BR.utf8")

max_date <- as.Date("2020-04-15")


df_older <- read_csv("./data/brasilio/cartorio/2020_04_15.csv.gz") %>% 
  mutate(df = as.character(max(date)))
(older_updated_at <- max(df_older$date))

latest_url <- "https://data.brasil.io/dataset/covid19/obito_cartorio.csv.gz"
df_newer <- readr::read_csv(latest_url) %>%
  mutate(df = as.character(max(date)))
(newer_updated_at <- max(df_newer$date))

check_state_on_date <- function(.data, check_date=Sys.Date()) {
  .data %>% filter(date == check_date | isTRUE(check_date)) %>% 
    select(date, df, deaths_respiratory_failure_2020,
           deaths_pneumonia_2020, deaths_covid19) %>%
    group_by(date) %>% 
    summarise_if(is_numeric, sum, na.rm=TRUE)
}

df_bind <- data_frame()
for (check_date in seq(as.Date("2020-03-01"), Sys.Date(), by="days")) {
  
  xx <- df_older %>% 
    check_state_on_date(check_date = check_date) %>%
    mutate(df = "df_older")
  yy <- df_newer %>% 
    check_state_on_date(check_date = check_date) %>%
    mutate(df = "df_newer")
  (df_bind <- df_bind %>%  
      bind_rows(xx, yy))
}

rm(xx,yy)
gc()


## labels for plot
labels <- c(newer_updated_at, older_updated_at) %>% 
    format("%d de %B") %>% paste("Óbitos registrados no sistema até dia", .)

labs_title <- paste0("Óbitos com Suspeita ou Confirmação de COVID-19 Lavrados em Cartório")
labs_subtitle <- paste0("Comparação entre registros obtidos em ", format(older_updated_at, "%d"), 
                        " e ", format(newer_updated_at, "%d de %B"), " (dados acumulados até ",
                        format(older_updated_at, "%d/%m"), ")")
labs_caption <- paste0(
  "*As datas são referentes ao dia do óbito e não à data de registro. ",
  "Código: github.com/avila/corona","\n",
  "Fonte: https://transparencia.registrocivil.org.br/cartorios. ",
  "Dados limpos: https://brasil.io/dataset/covid19/obito_cartorio"
)

p1 <- df_bind %>%
  filter(date <= older_updated_at) %>% 
  pivot_longer(-c(date, df)) %>% 
  filter(name=="deaths_covid19") %>% 
  ggplot(aes(x=date, y=value, color=df, fill=df)) +
  geom_bar(alpha=1/2,  stat="identity", position = "dodge", show.legend = T) +
  scale_color_brewer(labels=labels, name=NULL,palette = "Set1",
                      aesthetics = c("colour", "fill")) + 
  theme(legend.position = c(0.3, .85), 
        axis.title = element_blank(), 
        axis.text.x = element_blank(), 
        #axis.ticks = element_blank()
        ) + 
  scale_x_date(date_breaks = "week", date_minor_breaks = "day", 
               date_labels = "%d de %b") +
  labs(title = labs_title, 
       subtitle = labs_subtitle) #+ 
  #ggthemes::canva_pal("Modern and minimal")

p2 <- df_bind %>% pivot_wider(names_from = df, values_from = c(deaths_respiratory_failure_2020, 
                                                               deaths_pneumonia_2020,
                                                               deaths_covid19)) %>% 
  mutate(diff_res = deaths_respiratory_failure_2020_df_newer - deaths_respiratory_failure_2020_df_older, 
         diff_pne = deaths_pneumonia_2020_df_newer - deaths_pneumonia_2020_df_older, 
         diff_cov = deaths_covid19_df_newer - deaths_covid19_df_older) %>% 
  mutate(diff_lag_cov = diff_cov - lag(diff_cov)) %>% 
  pivot_longer(-date) %>% 
  filter(grepl("^diff", name)) %>% 
  filter(name == "diff_lag_cov") %>% #View()
  filter(date <= newer_updated_at) %>% 
  ggplot(aes(x=date, y=value)) +
  geom_bar(stat = "identity") +
  theme(axis.title = element_blank()) +
  scale_x_date(date_breaks = "week", date_minor_breaks = "day", 
               date_labels = "%d/%m") +
  labs(title = "Diferença diária (em diferente escala)",
       subtitle = "Observa-se uma um atraso em parte dos registros de pouco mais de duas semanas",
       caption = labs_caption)


# merge plots
cowplot::plot_grid(p1, p2, nrow = 2, 
                   rel_heights = c(5,3),
                   align = "v", axis = "b")

ggsave(filename = "./results/graphs/fig_diff_cartorio.png", dpi = 320, 
       height = 7, width = 8)
