library(magrittr)
library(dplyr)

# set url path -----------------------------------------------------------------
url_paths <- c(
  Confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv",
  Deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv",
  Recovered = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
)

# read data --------------------------------------------------------------------
(df_raw <- purrr::map_dfr(url_paths,
                          ~readr::read_csv(.x), .id = "Category"))
df_tidy <- df_raw %>% 
  tidyr::pivot_longer(cols = -c("Category", "Province/State", "Country/Region", "Lat", "Long"),
                      names_to = "date") %>% 
  rename(Country_Region = "Country/Region",  Province_State = "Province/State") %>% 
  mutate(Date = as.Date(date, format = "%m/%d/%y")) %>%
  group_by(Category, Country_Region, Date) %>% 
  summarise(value = sum(value)) %>% 
  select(Country_Region, Date, Category, value) %>% 
  arrange(Country_Region, Date)

# write data -------------------------------------------------------------------
readr::write_csv(df_tidy, path = file.path("~/devel/corona/data/CSSEGISandData_COVID_19_tidy.csv"))
if (!interactive())   print("done!")
