#### Loading libraries ####

if (!'devtools' %in% installed.packages()) install.packages("devtools", dependencies=TRUE)
library(devtools)
if (!'tRakt' %in% installed.packages()) install_github("jemus42/tRakt-package", dependencies=TRUE)
library(tRakt)
if (!'shiny' %in% installed.packages()) install.packages("shiny", dependencies=TRUE)
library(shiny)
if (!'ggvis' %in% installed.packages()) install.packages("ggvis", dependencies=TRUE)
library(ggvis)
if (!'ggplot2' %in% installed.packages()) install.packages("ggplot2", dependencies=TRUE)
library(ggplot2)
# "Warning in install.packages : package ‘rmarkdown’ is not available (for R version 3.1.0)"
if (!'rmarkdown' %in% installed.packages()) install_github("rstudio/rmarkdown", dependencies=TRUE)
library(rmarkdown)
if (!'shinyIncubator' %in% installed.packages()) install_github("rstudio/shiny-incubator", dependencies=TRUE)
library(shinyIncubator)
if (!'rCharts' %in% installed.packages()) install_github("ramnathv/rCharts", dependencies=TRUE)
library(rCharts)
if (!'plyr' %in% installed.packages()) install.packages("plyr", dependencies=TRUE)
library(plyr)

## Set API key ##
if (file.exists("key.json")){
  message("Reading API key from key.json")
  options(trakt.apikey = jsonlite::fromJSON("key.json")$apikey)
} else if (file.exists("key.txt")){
  message("Reading API key from key.txt")
  options(trakt.apikey = read.table("key.txt", stringsAsFactors = F)[1,1])
} else {
  stop("Place your key.json or key.txt in the root of this directory")
}

#### Set/find/create/save cache dir ####
cacheDir <- "cache"
if (!file.exists(cacheDir)){
  dir.create(cacheDir)
}

cache_titles <- function(showindex, cache_dir){
  titles <- file.path(cache_dir, "showtitles.rds")
  if (!file.exists(titles)){
    showindex$requests <- 1
    saveRDS(showindex, file = titles)
  } else {
    temp <- readRDS(file = titles)
    if (!(showindex$id %in% temp$id)){
      showindex$requests <- 1
      temp               <- rbind(temp, showindex)
      temp$title         <- as.character(temp$title)
      temp               <- plyr::arrange(temp, title)
      saveRDS(temp, file = titles)
    } else {
      temp$requests[temp$id == showindex$id] <- temp$requests[temp$id == showindex$id] + 1
      saveRDS(temp, file = titles)
    }
  }
}

## Fix cache index
fix_cached_index <- function(cacheDir = "cache"){
  cached <- sub(".rds", "", dir(cacheDir), ignore.case = T)
  for (id in cached){
    if (id == "showtitles"){next}
    show  <- trakt.show.summary(id)
    index <- data.frame(title = show$title, id = show$tvdb_id)
    cache_titles(index, cacheDir)
  }
}

reset_title_cache <- function(cacheDir = "cache"){
  temp          <- readRDS(file.path(cacheDir, "showtitles.rds"))
  temp$title    <- as.character(temp$title)
  temp          <- plyr::arrange(temp, title)
  temp$requests <- 0
  saveRDS(temp, file.path(cacheDir, "showtitles.rds"))
}


#### Setting some values ####
## Define some HTML characters
bullet <- HTML("&#8226;")
mu     <- HTML("&#956;")
sigma  <- HTML("&#963;")

## UI elements ##
btn.scale.x.choices <- c("Total Episode Numbers" = "epnum",
                         "Episodes per Season"   = "episode",
                         "Airdate"               = "firstaired.posix")

btn.scale.y.choices <- c("Rating" = "rating",
                         "Votes"  = "votes")

table.episodes.columns <- c("epnum", "epid", "title", "firstaired.string", "rating", "votes", "loved", "hated")
table.episodes.names   <- c("#", "Episode ID", "Title", "Airdate", "Rating (%)", "Votes", "Loved", "Hated")

table.seasons.columns  <- c("season", "episodes", "avg.rating.season", "rating.sd", "top.rating.episode", "lowest.rating.episode")
table.seasons.names    <- c("Season", "Episodes", "Average Rating", paste("Episode", sigma), "Highest Rating", "Lowest Rating")

#### Helper functions ####

make_tooltip <- function(show.episodes, keyvar = "tooltip"){
  strings <- paste0("<strong>",                  show.episodes$epid, "</strong><br />",
               "<strong>Title:</strong> ",  show.episodes$title, "<br />",
               "<strong>Aired:</strong> ",  show.episodes$firstaired.string, "<br />",
               "<strong>Rating:</strong> ", show.episodes$rating, "%<br />",
               "<strong>Votes:</strong> ",  show.episodes$votes, "<br />",
               "<strong>Loved:</strong> ",  show.episodes$loved, "<br />",
               "<strong>Hated:</strong> ",  show.episodes$hated)
  
  show.episodes[[keyvar]] <- strings
  return(show.episodes)
}

# Easy string addition
# via http://adv-r.had.co.nz/Functions.html#infix-functions

`%+%` <- function(a, b) paste(a, b, sep = "")

## Check number of flips
# How often has a show been flipped on http://tisch.ding.si?

get_flipcount <- function(showname = NULL){
  showname <- gsub(" ", "+", showname)
  baseURL  <- "http://api.l3vi.de/flips.json?flippable="
  query    <- baseURL %+% showname
  response <- jsonlite::fromJSON(query)
  return(response)
}

## Get season average ratings etc

get_season_ratings <- function(show.episodes = NULL, show.seasons = NULL){
  if (is.null(show.episodes) | is.null(show.seasons)){
    stop("You need to provide episode and season datasets")
  }
  seasons <- plyr::join(show.seasons, 
                 plyr::ddply(show.episodes, .(season), plyr::summarize, 
                             avg.rating.season     = round(mean(rating), 1), 
                             rating.sd             = round(sd(rating), 2), 
                             top.rating.episode    = max(rating), 
                             lowest.rating.episode = min(rating)))
  seasons$season <- factor(seasons$season, ordered = T)
  return(seasons)
}
