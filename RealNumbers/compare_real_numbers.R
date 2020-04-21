## library  --------------------------------------------------------------------
library(tidyverse)


## read data -------------------------------------------------------------------

#filenames <- dir("data/brasilio/cartorio", full.names = TRUE)
filenames <- fs::dir_ls("data/brasilio/cartorio")

df_merged <- map_dfr(filenames, ~read_csv(.x), .id = "file_source") %>% 
  mutate(file_source = as.Date(
    tools::file_path_sans_ext(basename(file_source), compression = TRUE), 
    format="%Y_%m_%d")
  ) %>% 
  mutate(df_age = abs(file_source - max(file_source))) %>% 
  mutate(data_age = abs(file_source - date)) %>% 
  filter(between(date, min(file_source) - 49, max(file_source))) %>% 
  group_by(file_source, date, df_age, data_age) %>% 
  summarise_at(vars(matches("^new((?!2019).)*$", perl = T)), sum, na.rm=TRUE) %>% 
  select(file_source, date, df_age, data_age, everything()) %>% 
  arrange(desc(date), df_age) %>% ungroup()
  

## helper function  ------------------------------------------------------------
replace_inf_or_nan <- function(.x) {
  ifelse(is.infinite(.x), NA_real_,
         ifelse(is.nan(.x), 0, .x))
}
replace_inf <- function(.x) {
  ifelse(is.infinite(.x), NA_real_, .x)
}

## gen calc data ---------------------------------------------------------------
df_mutated <- df_merged %>% group_by(date) %>% 
  mutate(week_day = format(date, "%a"), 
         week_day_source = format(file_source, "%a")) %>%
  mutate(
    rate_covid = (new_deaths_covid19 - lag(new_deaths_covid19, default = 0)) / new_deaths_covid19,
    rate_respi = (new_deaths_respiratory_failure_2020 - lag(new_deaths_respiratory_failure_2020, default = 0)) / new_deaths_respiratory_failure_2020, 
    rate_pneu = (new_deaths_pneumonia_2020 - lag(new_deaths_pneumonia_2020,default = 0)) / new_deaths_pneumonia_2020
  ) %>% 
  filter_at(vars(starts_with("rate")), any_vars(!is.infinite(.) & !is.nan(.) )) %>% 
  select(file_source, date, df_age, data_age, starts_with("week"), starts_with("rate"), everything()) %>% 
  ungroup() 

#view(df_mutated)
df_mutated %>% filter(df_age != 0, !is.na(rate_covid), !is.infinite(rate_covid)) %>%
  group_by(data_age) %>% #view
  ggplot(aes(x=data_age, y=rate_covid)) +
  geom_point(alpha=.34) + 
  #geom_quantile(method = "rqss", lambda = 1/20, quantiles=.5, se=T)
  #geom_smooth(method = lm, formula = y ~ splines::bs(x, 10), se = T) +
  #stat_smooth(method = "gam", formula = y ~ s(x, k=30), size = 1) 
  #geom_smooth(method = lm, formula = y~quantreg::rq(x), se = T)
  geom_smooth(col="red", lty=2, span=.2)




  


# fit loess --------------------------------------------------------------------

# summarise by data_age
df_summd <- df_mutated %>% filter(df_age != 0, !is.na(rate_covid)) %>% 
  group_by(data_age) %>% 
  summarise(mean = mean(rate_covid, na.rm = TRUE),
            median = median(rate_covid, na.rm = TRUE),
            sd= sd(rate_covid, na.rm = TRUE)) %>% 
  filter_at(vars(starts_with("m")), any_vars(!is.infinite(.) | !is.nan(.) ))
  

df_summd %>% 
  filter(data_age<30) %>% 
  ggplot(aes(x=data_age, y=mean, col="mean")) + geom_line(stat="identity") + geom_point() + 
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd, col="sd"), width=.2,
                position=position_dodge(0.05)) + 
  geom_line(aes(y=median, col="median")) + 
  geom_point(data= filter(df_mutated, df_age != 0, !is.na(rate_covid), !is.infinite(rate_covid)), 
         aes(x=data_age, y=rate_covid, col="pontos"), alpha=.1)

x <- rep(NA, length = nrow(df_summd))
#i <- 2
for (i in seq_along(df_summd$mean)) {
  cat(i, ":")
  x[i] <- sum(df_summd$mean[i:nrow(df_summd)] ,na.rm = TRUE)
  #cat(x, "\n")
}
x2 <- x[!is.infinite(x)]
df_latest <- df_mutated %>% filter(file_source == max(file_source))
df_latest %>% 
  mutate(x2 = c(x2 + 1e-30,rep(0,nrow(df_latest)-length(x2) ))) %>% 
  mutate(exp_nd_covid = -(sign(x2)+x2) * new_deaths_covid19) -> yy

yy
yy$new_deaths_covid19 %>% sum
yy$exp_nd_covid %>% sum %>% round()

plot(yy$exp_nd_covid)

df_mutated$new_deaths_covid19 %>% head(10)
view(df_mutated)


df_tocalc <- df_mutated %>% 
  filter_at(vars(starts_with("rate")), any_vars(!is.infinite(.) & !is.nan(.) )) %>% #view
  mutate_at(vars(starts_with("rate")), replace_inf) %>% 
  #filter_at(vars(starts_with("rate")), all_vars(!is_na)) %>% view # does not work
  filter_at(vars(starts_with("rate")), all_vars(. < Inf)) %>% 
  mutate(data_age = as.numeric(data_age))


calc_loess <- loess(rate_covid ~ data_age, data=df_tocalc) # 10% smoothing span
predict(calc_loess) %>% plot

loessMod10 <- loess(uempmed ~ index, data=economics, span=0.10) # 10% smoothing span

fit <- lm(rate_covid ~ factor(data_age) + week_day_source-1, data=df_tocalc) %>% summary()
  

  








