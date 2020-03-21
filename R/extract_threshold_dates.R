library(tidyverse)

df <- read_csv("data/our_world_in_data_corona.csv")

df_fun_calc <- function(df, th=1, var=NULL) {
  varname <- paste0("th_", i)
  mutate(df, !!varname := 
           case_when(category %in% c("daily cases", "daily deaths") ~ NA_character_,
                     value >= i & lag(value) < i ~ as.character(date),
                     TRUE ~ NA_character_))
}

for (i in c(1, 5, 10, 25, 50 , 100)) {
  df <- df %>% group_by(location, category) %>% 
    df_fun_calc(th = i) 
}
df <- df %>% ungroup()

df_dates <- df %>% select(location, category, starts_with("th")) %>% 
  pivot_longer(-c(location, category)) %>% filter(!is.na(value)) %>% 
  pivot_wider(c(location, category, name, value)) %>% 
  select(location, category, th_1, th_5, th_10, th_25, th_50, th_100 ) %>% 
  mutate(th_1 = 
    if_else(
      !is.na(th_5) & is.na(th_1), "2020-02-25", th_1
    ))

write_csv(df_dates, "data/threshold_dates.csv")
