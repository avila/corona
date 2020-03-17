library(tidyverse)

url_path <- "https://covid.ourworldindata.org/data/full_data.csv"
df <- read_csv(url_path) %>%
  pivot_longer(-c(location, date), names_to = "name")




selected_countries <- c(
  "Germany", "Italy", "United Kingdom", "Brazil", "China"
)
category <- unique(df$name)[3]

options(scipen = 999)
fun_dot <- function(x) format(x, big.mark = " ",
                              scientific = FALSE,
                              decimal.mark = )
df %>% 
  filter(location %in% selected_countries, name==category) %>% 
  mutate(location=fct_reorder2(location, date, value)) %>% 
  
  #mutate(state=fct_reorder2(state, t, value)) %>% 
  
  ggplot(aes(x=date, y=value, colour=location)) + 
  geom_point() +
  geom_line() + scale_y_log10(labels=fun_dot)


th <- 50
df_cnt <- df %>% filter(name==category) %>% 
  group_by(location) %>% 
  mutate(check = if_else(value>=th, 1, 0)) %>% 
  filter(check==1) %>% group_by(location) %>% 
  mutate(date = ave(1:length(location), df$location, FUN = seq_along)) %>% 
  ungroup(location) %>% arrange(date) %>% 
  #filter(location %in% selected_countries) %>% 
  mutate(location=fct_reorder2(location, date, value))

`%!in%` <- Negate(`%in%`)

th <- 50
df_cnt %>% 
  filter(location %!in% c("International",  "World")) %>% 
  group_by(location) %>% 
  mutate(label = ifelse(date == max(date),
                        as.character(location), 
                        NA_character_)) %>% 
  ggplot(aes(x=date, y=value, colour=location)) + 
  geom_point() +
  geom_line() + 
  ggrepel::geom_label_repel(aes(label = label),
                            nudge_x = 1,
                            na.rm = TRUE) + 
  theme(legend.position = "none") + 
  scale_y_log10(name="Infections (log scale)", labels=fun_dot, 
                breaks=2^(0:20) * 1) + 
  scale_x_continuous(name=paste0("Days since ", th, "th death"), 
                     breaks=seq(0, 1e3, 7)) + 
  ggtitle("Comparison of COVID-19 fatalities by country")



pop_data <- readr::read_csv("./data/pop_data.csv",
                            #locale = locale(grouping_mark = "."),
                            col_types = cols(Density = col_skip(), 
                                             GrowthRate = col_skip(),
                                             WorldPercentage = col_skip(), 
                                             area = col_skip(),
                                             dropdownData = col_skip(), 
                                             rank = col_skip()))

th = 0.01
df_pop <- left_join(df, pop_data, by = c("location"="name")) %>%
  mutate(pop2020 = pop2020 * 1e3)
df_pop %>% mutate(pop_value = value / pop2020 * 1e5) %>%
  filter(name==category) %>% 
  group_by(location) %>% 
  mutate(check = if_else(pop_value>=th, 1, 0)) %>% 
  filter(check==1) %>% group_by(location) %>% 
  mutate(date = ave(1:length(location), df$location, FUN = seq_along)) %>% 
  ungroup(location) %>% arrange(date) %>% 
  #filter(location %in% selected_countries) %>% 
  mutate(location=fct_reorder2(location, date, pop_value)) %>% 
  
  filter(location %!in% c("International",  "World")) %>% 
  group_by(location) %>% 
  mutate(label = ifelse(date == max(date),
                        as.character(location), 
                        NA_character_)) %>% 
  ggplot(aes(x=date, y=pop_value, colour=location)) + 
  geom_point() + geom_line() + 
  ggrepel::geom_label_repel(aes(label = label),
                            nudge_x = 1,
                            na.rm = TRUE) + 
  theme(legend.position = "none") + 
  scale_y_log10(name="(log scale)", labels=fun_dot, 
                breaks=2^(0:20) / 1000 ) + 
  scale_x_continuous(name=paste0("Days since ", th, "th case"), 
                     breaks=seq(0, 1e3, 7)) + 
  ggtitle("Fatalities by 100.000 inhabitants")

