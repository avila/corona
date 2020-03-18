library(magrittr)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)

wiki_url <- "https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Germany"
page_de <- xml2::read_html(wiki_url)

first_date <- as.Date("2020-02-24")

df_de <- page_de %>% rvest::html_nodes("table") %>% .[[4]] %>% 
  rvest::html_table(fill = TRUE, trim=TRUE, header=FALSE) %>%
  filter(row_number() %in% (3:18) ) %>% 
  na_if("—")

names(df_de)<- c("state", as.character(first_date + 0:(ncol(df_de)-2)))

df_de <- df_de %>% 
  tidyr::pivot_longer(-state, names_to = "Date") %>% 
  mutate(Date = as.Date(Date)) %>% 
  mutate(value = parse_number(value)) %>% 
  replace_na(list(value=0))

if (interactive()) { head(df_de) }

write_csv(df_de, path = file.path("~/devel/corona/data/COVID_19_de_wiki.csv"))

if (!interactive())   print("done!")



# RKI data ---------------------------------------------------------------------

url <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html"
page_rki <- xml2::read_html(url)

# get latest date of downloaded data
list_of_files <- list.files("~/devel/corona/data/rki_data/")
max_downloaded_date <- str_extract(list_of_files, "[0-9]{4}_[0-9]{2}_[0-9]{2}") %>% 
  as.Date(format="%Y_%m_%d") %>% max()

# get date of latest online data in RKI website
df_stand <- page_rki %>% rvest::html_nodes("p") %>% rvest::html_text()
df_stand <- head(df_stand[startsWith(df_stand, "Stand:")],1) %>% 
  str_extract_all(pattern = "\\d+", simplify = T) %>% .[1:3] %>% 
  paste(sep="", collapse = "/") %>% as.Date(format="%d/%m/%y")

if (df_stand > max_downloaded_date | is.na(max_downloaded_date)) {
  

  df_rki <- page_rki %>% rvest::html_nodes("table") %>% .[[1]] %>% 
    rvest::html_table(fill = TRUE, trim=F, header=T) 
  
  names(df_rki) <- c("Bundesland","Anzahl", "Differenz_Vortag", "Erkr_p_100k_Einw", "Todesfaelle", "Bes_betroffene")
  
  df_rki_exp <- df_rki %>% filter(Bundesland != "") %>% 
    mutate_at(.vars = c("Anzahl", "Differenz_Vortag", "Erkr_p_100k_Einw", "Todesfaelle"),
              ~parse_number(.x, locale = locale("de", decimal_mark = ",")))
  
  df_rki_exp <- df_rki_exp %>% mutate(date=df_stand)  
  file_path <- file.path(paste0("~/devel/corona/data/rki_data/",
                                format(df_stand, "%Y_%m_%d"), ".csv"))
  write_csv(df_rki_exp, path = file_path)
} else {
  print(
    paste("Data already downloaded. Lastest: ", df_stand) 
  )
}


