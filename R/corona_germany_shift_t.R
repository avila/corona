library(tidyverse)

wiki_url_de <- "https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Germany"
page_de <- xml2::read_html(wiki_url_de)


df_de <- page_de %>% rvest::html_nodes("table") %>% .[[4]] %>% 
  rvest::html_table(fill = TRUE, trim=T, header=FALSE) %>% filter(row_number() %in% (3:18) ) %>% 
  na_if("—") 

first_date <- as.Date("2020-02-24")
names(df_de) <- c("state", as.character(first_date + 0:(ncol(df_de)-2)))

df_de <- df_de %>% 
  pivot_longer(-state, names_to = "date") %>% 
  mutate(date = as.Date(date))

df_de$value <- readr::parse_number(df_de$value)
#df_de$value <- df_de$value %>% replace_na(0)
df_de$state <- as.factor(df_de$state)

lp <- df_de %>% 
  mutate(state=fct_reorder2(state, date, value)) %>% 
  ggplot(mapping = aes(date, value, group=state)) +
  geom_line(aes(color=state)) + 
  scale_y_log10() + theme(axis.title.x=element_blank())
  

th <- 10
df_cnt<- df_de %>% group_by(state) %>% 
  mutate(check = if_else(value>=th, 1, 0)) %>% 
  filter(check==1) %>% group_by(state) %>% 
  mutate(t = ave(1:length(state), df_cnt$state, FUN = seq_along)) %>% 
  ungroup(state)
  

df_cnt %>%
  mutate(state=fct_reorder2(state, t, value)) %>% 
  
  ggplot(mapping = aes(t, value, group=state)) +
  geom_line() + geom_point(aes(colour=state)) +
  scale_y_log10() + 
  scale_x_continuous(name=paste("Days after", th, "first infections in each state")) +
  theme(axis.title.y=element_blank(), 
        legend.title = element_blank()) + 
  ggtitle("COVID-19 infections in Germany by state")
  

  
        