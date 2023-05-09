cdramas_df <- read.csv("data/cdramas.csv", header = TRUE)
cast_df <- read.csv("data/cdrama_casts.csv", header = TRUE)

# Find the top 50 words used in drama titles
title_words <- gsub("[^A-Za-z0-9\\' ]", " ", paste(cdramas_df$title_en, collapse=" ")) #single string of all words
title_words <- unlist(strsplit(tolower(title_words), "\\s+")) #character vector of all words
word_freq <- sort(table(title_words), decreasing = TRUE)
output <- word_freq[1:50]
cat(paste(rownames(output), output, sep=":"), sep = ", ")

# Find the top words used in the native titles
title_chars <- gsub("\\s+", "", paste(cdramas_df$title_zh, collapse = ""))
title_chars <- unlist(strsplit(title_chars, split = ""))
char_freq <- sort(table(title_chars), decreasing = TRUE)
output2 <- char_freq[1:50]
cat(paste(rownames(output2), output2, sep=":"), sep = ", ")
