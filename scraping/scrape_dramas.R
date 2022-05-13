# With URLs obtained from scrape_titles.R, visit each drama's page to further
# collect various details of interest. Drama details are stored in a spreadsheet.

cdramas_df <- read.csv("data/cdramas_basic.csv", header = TRUE)

details_df <- data.frame(mdl_url = character(), title_zh = character(), 
                         genres = character(), tags = character())

for (end_url in cdramas_df$mdl_url) {
  drama_url <- paste0("https://mydramalist.com", end_url)
  page <- read_html(drama_url)
  
  title_zh <- page %>%
    html_nodes("[class='list-item p-a-0'] > a") %>%
    html_attr("title") %>% na.omit() %>% paste()
  # deals with case of missing native title
  if (length(title_zh) == 0) {
    title_zh <- NA
  }
  
  # get rating?
  
  genres <- page %>%
    html_nodes("[class='list-item p-a-0 show-genres'] > a") %>%
    html_text() %>%
    paste(collapse = ", ")
  
  # drama_genres <- page %>%
  #   html_nodes("[class='list-item p-a-0 show-genres']") %>%
  #   html_text() %>%
  #   str_replace("Genres:", "") %>%
  #   #str_extract("Genres: ([\\s\\S]*)\$") %>%
  #   str_replace_all("\\s+", " ") %>% str_trim()
  
  tags <- page %>%
    html_nodes("[class='list-item p-a-0 show-tags'] > span > a") %>%
    html_text() %>%
    paste(collapse = ", ")
  
  # drama_tags <- page %>%
  #   html_nodes("[class='list-item p-a-0 show-tags']") %>%
  #   html_text() %>%
  #   str_replace_all("(Tags:|\\(Vote or add tags\\))", "") %>%
  #   #str_extract("Genres: ([\\s\\S]*)\$") %>%
  #   str_replace_all("\\s+", " ") %>% str_trim()
  
  details_df[nrow(details_df) + 1,] <- c(end_url, title_zh, genres, tags)
}

cdramas_df <- merge(cdramas_df, details_df, by = "mdl_url", sort = FALSE) # column order does change
write.csv(cdramas_df, "data/cdramas.csv", row.names = FALSE)
  