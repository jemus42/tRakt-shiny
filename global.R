#### Loading libraries ####
# if (!("devtools" %in% installed.packages())) install.packages("devtools")
# devtools::install_deps(upgrade = "never")

library(shiny)
library(shinyjs)
library(shinythemes)
# library(DT)
# library(plotly)
library(tRakt)
library(RSQLite)
library(DBI)
library(dplyr)
library(dbplyr)
library(glue)
library(purrr)

# Database connection -----
cache_db <- function() {
  dbConnect(RSQLite::SQLite(), "cache/tRakt.db")
}

#### Setting some values ----
## Define some HTML characters
# bullet <- HTML("&#8226;")
# mu     <- HTML("&#956;")
# sigma  <- HTML("&#963;")

# Helper functions ----

# Get posters from fanart.tv
# tvdbid <- 353764
get_fanart_poster <- function(tvdbid, api_key = "113407042401248f50123d1c112abf0d") {
  query <- paste0("https://webservice.fanart.tv/v3/tv/", tvdbid, "?api_key=", api_key)
  ret <- httr::content(httr::GET(query))
  ret_url <- ret$tvposter[[1]]$url

  if (is.character(ret_url) & nchar(ret_url) > 10) {
    return(ret_url)
  } else {
    message("Possibly broken fanart: ", tvdbid)
    return("")
  }
}
