# Perform SQL queries to gain insight about the dramas
# Interested in finding big names and big projects in the industry, etc.

# cdramas_df <- read.csv("data/cdramas.csv", header = TRUE)
# cast_df <- read.csv("data/cdrama_casts.csv", header = TRUE)

dcon <- dbConnect(SQLite(), dbname = "cdramas.sqlite")
# dbWriteTable(conn = dcon, name = "cdramas", cdramas_df,
#              append = TRUE, row.names = FALSE)
# dbWriteTable(conn = dcon, name = "casts", cast_df,
#              append = TRUE, row.names = FALSE)
dbListTables(dcon)

query <- function(sql_query) {
  res <- dbSendQuery(conn = dcon, sql_query)
  table <- dbFetch(res, -1)
  dbClearResult(res)
  return(table)
}

# Find the number of dramas with love in their English title
query("SELECT count(*)
       FROM cdramas
       WHERE LOWER(cdramas.title_en) LIKE '%love%'")

# Find people who have been in the most dramas (can include directors, etc.)
query("SELECT actor, actor_url, count(*)
       FROM casts
       GROUP BY actor_url
       ORDER BY count(*) DESC LIMIT 20")

# Find actors who have been in the most dramas since 2018
query("SELECT actor, actor_url, count(*)
       FROM cdramas INNER JOIN casts ON cdramas.mdl_url = casts.mdl_url
       WHERE year >= 2018 AND LOWER(casts.type) LIKE '%role%'
       GROUP BY actor_url
       ORDER BY count(*) DESC LIMIT 20")

# Find dramas with the largest cast size
query("SELECT cdramas.title_en, count(*)
       FROM cdramas INNER JOIN casts ON cdramas.mdl_url = casts.mdl_url
       GROUP BY cdramas.mdl_url 
       ORDER BY count(*) DESC LIMIT 20")

# Who are actors most involved in Romance dramas?
query("SELECT actor, actor_url, count(*) as num_dramas
       FROM cdramas INNER JOIN casts ON cdramas.mdl_url = casts.mdl_url
       WHERE LOWER(cdramas.genres) LIKE '%romance%' AND
             LOWER(casts.type) LIKE '%role%'
       GROUP BY actor_url
       ORDER BY count(*) DESC LIMIT 20")

# Identify fantasy "wuxia" dramas
query("SELECT title_en, year, eps
       FROM cdramas
       WHERE genres LIKE '%Fantasy%' AND genres LIKE '%Wuxia%'
       ORDER BY year DESC")

# Identify longest dramas
query("SELECT title_en, year, eps
       FROM cdramas
       ORDER BY eps DESC LIMIT 20")

dbDisconnect(dcon)
