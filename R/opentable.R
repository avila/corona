library(tidyverse)

sys_time_local_old <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "en_US.UTF-8")


# About the data:
# This data shows year-over-year seated diners at restaurants on the OpenTable
# network across all channels: online reservations, phone reservations, and
# walk-ins. For year-over-year comparisons by day, we compare to the same day of
# the week from the same week in the previous year. For example, we’d compare
# Tuesday of week 11 in 2020 to Tuesday of week 11 in 2019. Only states or
# cities with 50+ restaurants in the sample are included. All restaurants on the
# OpenTable network in either period are included.
# source: https://www.opentable.com/state-of-industry

df_ot <- read_csv("data/state_of_industry_data.csv") %>%
  pivot_longer( -c(Type, Name), names_to = "Date", values_to = "Value") %>% 
  mutate(Date = as.Date(Date, format="%m/%d"))

countries1 <- c("Germany", "United States", "United Kingdom", "Global")
countries2 <- c("Mexico", "Ireland", "Canada", "Australia")

df_ot <- df_ot %>% mutate(
  Group = case_when(Name %in% countries1 ~ 1,
                    Name %in% countries2 ~ 2))

df_ot %>% filter(Group == 1) %>% 
  ggplot(aes(x = Date, y = Value, color=Value)) + 
  geom_line(show.legend = F) +
  facet_grid(rows = Name~.) +
  theme(legend.position = "none") + 
  
  ggtitle("Year-over-year Variation of Reastaurant Reservations",
          "OpenTable data (https://www.opentable.com/state-of-industry)") +
  geom_text(aes(label = Value, y=Value-15))


for (i in 1:2) {
  plot <- df_ot %>% filter(Group == i) %>% 
    ggplot(aes(x = Date, y = Value, color=Value)) + 
    geom_line(show.legend = F) + geom_point() +
    facet_grid(rows = Name~.) +
    theme(legend.position = "none", 
          axis.title=element_blank()) + 
    scale_y_continuous(breaks = seq(-100, 0, by = 20)) +
    scale_x_date(breaks="week", minor_breaks = "day") +
    
    
    ggtitle("Year-over-year Variation of Reastaurant Reservations",
            "Percentage change (OpenTable https://www.opentable.com/state-of-industry)") +
    geom_text(aes(label = Value), nudge_y=-13, nudge_x = -1/5, size=3)
  print(plot)
}

