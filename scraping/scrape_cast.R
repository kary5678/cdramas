# With URLs obtained from scrape_titles.R, visit each drama's cast page
# collect names of cast members for each dramas (producers, etc. included)

library(rvest)
library(tidyverse)

cdramas_df <- read.csv("data/cdramas.csv", header = TRUE)

cast_df <- data.frame(mdl_url = character(), actor_url = character(),
                      actor = character(), role = character(), type = character())
cast_cols <- colnames(cast_df)

for (end_url in cdramas_df$mdl_url) {
  drama_url <- paste0("https://mydramalist.com", end_url, "/cast")
  page <- read_html(drama_url)
  
  names <- page %>%
    html_nodes("[class='col-xs-9 col-sm-8 p-a-0']") %>%
    html_text() %>% str_trim() %>%
    str_split_fixed(pattern = "\\s{2,}", n = 3) 
  # split each entry into the actor's name, role name, and role type
  # it is not perfect depending on formatting/missing data, so get unique URLs
  
  actor_urls <- page %>%
    html_nodes("[class='col-xs-9 col-sm-8 p-a-0'] > a") %>%
    html_attr("href") 
  
  cast_df <- rbind(cast_df, cbind(rep(end_url, nrow(names)), actor_urls, names))
}
colnames(cast_df) <- cast_cols

write.csv(cast_df, "data/cdrama_casts.csv", row.names = FALSE)
