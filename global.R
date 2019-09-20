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

cache_db_con <- cache_db()

source(here::here("db_helpers.R"))
source(here::here("data_helpers.R"))
# on.exit(dbDisconnect(cache_db_con), add = TRUE)

cache_shows_tbl    <- tbl(cache_db_con, "shows")
cache_posters_tbl  <- tbl(cache_db_con, "posters")
cache_seasons_tbl  <- tbl(cache_db_con, "seasons")
cache_episodes_tbl <- tbl(cache_db_con, "episodes")

#### Setting some values ----
app_title <- glue("attrakttv v{desc::desc_get_version()}")

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

# get_fanart_poster("76738")
# 77712


# Show status
# https://trakt.docs.apiary.io/#reference/shows/summary/get-a-single-show
# Note: When getting full extended info, 
# the status field can have a value of returning series (airing right now), 
# in production (airing soon), planned (in development), canceled, or ended.

label_show_status <- function(status) {
  bs3_badge <- function(badge_type, label) {
    glue('<span class="label label-{badge_type}">{label}</span>')
  }
  # bs4_badge <- function(badge_type, label) {
  #   glue('<span class="badge badge-{badge_type}">{label}</span>')
  # }
  status <- str_to_title(status)
  
  case_when(
    status %in% c("ended") ~ bs3_badge("default", status),
    status %in% c("returning series") ~ bs3_badge("primary", status),
    status %in% c("in production", "planned") ~ bs3_badge("info", status),
    status %in% c("canceled") ~ bs3_badge("danger", status),
    TRUE ~ bs3_badge("default", status)
  )
}


