# Scrape the titles and basic information from http://mydramalist.com/
# Interested in Chinese dramas released from 2012 to 2022 as of 5/10/22, with
# at least a 1.0 rating to filter out less relevant dramas that would have missing data

library(rvest)
library(tidyverse)

cdramas_df <- data.frame(title_en = character(), mdl_url = character(),
                        year = integer(), eps = integer())

for (num in 1:158) {
  mdl_url <- paste0("https://mydramalist.com/search?adv=titles&ty=68&co=2&re=2012,2022&rt=1,10&st=3&so=top&page=", num)
  page <- read_html(mdl_url)
  
  drama_titles <- page %>%
    html_nodes("h6") %>%
    html_text() %>%
    str_sub(end = -3)
  
  drama_urls <- page %>%
    html_nodes("a.block") %>%
    html_attr("href") 
  
  drama_details <- page %>%
    html_nodes("span.text-muted") %>%
    html_text() %>%
    strsplit(",")
  
  drama_years <- str_extract(sapply(drama_details, "[[", 1), "[0-9]{4}")
  drama_eps <- str_extract(sapply(drama_details, "[[", 2), "[0-9]+")
  
  page_df <- data.frame(drama_titles, drama_urls, drama_years, drama_eps)
  colnames(page_df) <- colnames(cdramas_df)
  cdramas_df <- rbind(cdramas_df, page_df)
}

write.csv(cdramas_df, "data/cdramas_basic.csv", row.names = FALSE)
