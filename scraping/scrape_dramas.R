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


# Generate genre dataframe ------------------------------------------------
# cdramas_df <- read.csv("data/cdramas.csv", header = TRUE)
unique_genres <- paste(cdramas_df$genres, collapse=", ")
unique_genres <- unlist(strsplit(unique_genres, split = ", "))
unique_genres <- sort(unique(unique_genres))
# Remove the "" genre
unique_genres <- unique_genres[-1]

genres_df <- data.frame(
  mdl_url = cdramas_df$mdl_url,
  title_en = cdramas_df$title_en,
  title_zh = cdramas_df$title_zh,
  genres = cdramas_df$genres)

for (genre in unique_genres) {
  genres_df[genre] <- as.numeric(grepl(genre, cdramas_df$genres, fixed=TRUE))
}

write.csv(genres_df, "data/cdrama_genres.csv", row.names = FALSE)



# Generate tags dataframe -------------------------------------------------
# cdramas_df <- read.csv("data/cdramas.csv", header = TRUE)
unique_tags <- paste(cdramas_df$tags, collapse=", ")
unique_tags <- unlist(strsplit(unique_tags, split = ", "))
# There are 1877 unique tags if we include them all
# Filter to those that have at least 20 dramas
unique_tags <- table(unique_tags)[table(unique_tags) >= 20]
unique_tags <- names(unique_tags)
# Remove the "" tag
unique_tags <- unique_tags[-1]

tags_df <- data.frame(
  mdl_url = cdramas_df$mdl_url,
  title_en = cdramas_df$title_en,
  title_zh = cdramas_df$title_zh,
  tags = cdramas_df$tags)

for (tag in unique_tags) {
  tags_df[tag] <- as.numeric(grepl(tag, cdramas_df$tags, fixed=TRUE))
}

write.csv(tags_df, "data/cdrama_tags.csv", row.names = FALSE)
