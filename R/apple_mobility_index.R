library(tidyverse)
library(tsibble)


### Apple data  ----------------------------------------------------------------

# todo: fetch straight from net
(df_apple <- read_csv("data/covid19-apple.csv") %>% 
  pivot_longer(-c("geo_type", "region", "transportation_type"),
               names_to = "date") %>% 
  rename(variable = transportation_type,
         location=region) %>% 
  mutate(date=as.Date(date), 
         data_source="apple") %>% 
   filter(geo_type=="country/region") %>% 
   select(-geo_type)
)

### Google data  ---------------------------------------------------------------


url <- paste0("https://raw.githubusercontent.com/datasciencecampus/",
              "google-mobility-reports-data/master/csvs/",
              "international_national_trends_G20_20200410.csv")

(df_google <- read_csv(url) %>% 
  pivot_longer(-c("Country", "location", "category"), names_to = "date") %>% 
  mutate(date=as.Date(date),
         data_source="google") %>%
  rename(country_code=Country,
         variable = category) %>% 
    select(-country_code)
)


### ECDC data  -----------------------------------------------------------------

if (lubridate::hour(Sys.time()) < 8) {
  time <- (Sys.Date() - lubridate::days(1)) %>% format("%Y-%m-%d")
} else {
  time <- Sys.Date() %>% format("%Y-%m-%d")
}
url <- paste("https://www.ecdc.europa.eu/sites/default/files/documents/",
             "COVID-19-geographic-disbtribution-worldwide-",
             time, ".xlsx", sep = "")

#download the dataset from the website to a local temporary file
httr::GET(url, httr::authenticate(":", ":", type="ntlm"),
          httr::write_disk(tf <- tempfile(fileext = ".xlsx",
                                          pattern = "covid_")))

#read the Dataset sheet into “R”
(df_ecdc <- readxl::read_excel(tf) %>% 
    rename(location = countriesAndTerritories, 
           date = dateRep) %>% 
    arrange(location, date) %>% 
    mutate(
      date = as.Date(date),
      data_source="ecdc"
      #location = tools::toTitleCase(str_to_lower(str_replace_all(location, "_", " ")))
    ) %>% group_by(location) %>% 
    mutate(cum_cases = cumsum(cases), 
           cum_deaths = cumsum(deaths)) %>%
    pivot_longer(cols = c(cases, deaths, cum_cases, cum_deaths), 
                 names_to = "variable") %>% 
    select(c("date", "location", "variable", "value", "data_source"))
)
 

### Merge all data -------------------------------------------------------------

df_google_w <- df_google %>%
  unite("variable", data_source, variable, sep = ".") %>% 
  pivot_wider(names_from = variable, values_from = value)
df_apple_w <- df_apple %>%
  unite("variable", data_source, variable, sep = ".") %>% 
  pivot_wider(names_from = variable, values_from = value)
df_ecdc_w <- df_ecdc %>%
  unite("variable", data_source, variable, sep = ".") %>% 
  pivot_wider(names_from = variable, values_from = value)

by_cols <- c("location", "date")
df_merged_w <- df_google_w %>% left_join(df_apple_w, by = by_cols) %>% 
  left_join(df_ecdc_w,by = by_cols) %>% 
  pivot_longer(-by_cols, names_to = "variable") %>% 
  pivot_wider(names_from = variable, values_from = value)
View(df_merged_w)

names(df_merged_w) <- names(df_merged_w) %>% snakecase::to_snake_case()
df_merged_w %>% names
df_merged_w_tidy <- df_merged_w %>% mutate(
  ecdc.cases = replace_na(ecdc.cases, 0), 
  ecdc.deaths = replace_na(ecdc.deaths, 0)) %>% 
  fill(ecdc.cum_cases) %>% 
  fill(ecdc.cum_deaths) %>% 
  mutate(ecdc.cum_cases = replace_na(ecdc.cum_cases, 0), 
         ecdc.cum_deaths = replace_na(ecdc.cum_deaths , 0)) 
df_merged_w

df_merged_w_tidy %>% filter(location=="Brazil", !is.na(all())) %>% select(-c(location, date)) 



df_final <- df_merged_w_tidy %>% group_by(location) %>% 
  mutate(ecdc.cum_cases = slide_dbl(ecdc.cum_cases, mean, .size = 31), 
         ecdc.cum_deaths = slide_dbl(ecdc.cum_deaths, mean, .size = 31)) %>% 
  mutate(
    lag_ecdc.cum_cases = difference(log(ecdc.cum_cases), default = 0),
    lag_ecdc.cum_deaths = difference(log(ecdc.cum_deaths),default = 0)
  ) %>% 
  mutate(lag_ecdc.cum_cases = replace_na(lag_ecdc.cum_cases, 0), 
         lag_ecdc.cum_deaths = replace_na(lag_ecdc.cum_deaths , 0)) %>% 
  ungroup() 

x <- df_final %>% select(-c(location, date))
cormat <- round(cor(x),3)
head(cormat)
reshape2::melt(cormat) %>% ggplot(aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile() + scale_x_discrete(guide = guide_axis(n.dodge = 4)) 











