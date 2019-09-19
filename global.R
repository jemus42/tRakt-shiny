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
library(cliapp)

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
  
  # Try tvposter first
  url <- ret[["tvposter"]][[1]][["url"]]
  
  if (rlang::has_name(ret, "tvposter")) {
    url <- pluck(ret, "tvposter") %>% 
      bind_rows() %>% 
      filter(lang == "en") %>%
      arrange(likes) %>%
      head(1) %>%
      pull(url)
  } else if (rlang::has_name(ret, "seasonposter")) {
    url <- pluck(ret, "seasonposter") %>% 
      bind_rows() %>% 
      filter(lang == "en") %>%
      arrange(likes) %>%
      head(1) %>%
      pull(url)
  }

  if (is.character(url)) {
    url
  } else {
    cliapp::cli_alert_danger("No fanart: {ret$name} ({tvdbid})")
    character(1)
  }
}

get_fanart_poster("76738")
# 77712
