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

## Set API key ##
if (file.exists("key.json")){
  message("Reading API key from key.json")
  options(trakt.apikey = jsonlite::fromJSON("key.json")$apikey)
} else if (file.exists("key.txt")){
  message("Reading API key from key.json")
  options(trakt.apikey = read.table("key.txt", stringsAsFactors = F)[1,1])
} else {
  stop("Place your key.json or key.txt in the root of this directory")
}

#### Setting some values ####
btn.scale.x.choices <- c("Total Episode Numbers" = "epnum",
                         "Episodes per Season"   = "episode",
                         "Airdate"               = "firstaired.posix")

btn.scale.y.choices <- c("Rating" = "rating",
                         "Votes"   = "votes")

table.episodes.columns <- c("epid", "title", "firstaired.string", "rating", "votes", "loved", "hated")
table.episodes.names   <- c("Episode ID", "Title", "Airdate", "Rating (%)", "Votes", "Loved", "Hated")

#### Helper functions ####
all_values <- function(x) {
  if(is.null(x)) return(NULL)
  paste0(names(x), ": ", format(x), collapse = "<br />")
}

show_tooltip <- function(show, idvars = NULL) {
  if(is.null(show)) return(NULL)
  if(!is.null(show$firstaired.posix)){
    show$firstaired.posix <- paste(as.character(as.POSIXct(show$firstaired.posix/1000, origin = lubridate::origin, tz = "UTC")),
                                   lubridate::tz(show$firstaired.posix))
  }
  names(show) <- sub("firstaired.posix", "Aired", names(show))
  names(show) <- sub("rating", "Rating", names(show))
  names(show) <- sub("season", "Season", names(show))
  names(show) <- sub("id", "Title", names(show))
  names(show) <- sub("epnum", "Episode Number", names(show))
  
  paste0("<strong>", names(show), "</strong>: ", format(show), collapse = "<br />")  
}

make_tooltip <- function(show.episodes){
  rating  <- paste0("<strong>Rating:</strong> ", show.episodes$rating, "%")
  votes   <- paste0("<strong>Votes:</strong> ",  show.episodes$votes)
  loved   <- paste0("<strong>Loved:</strong> ",  show.episodes$loved)
  hated   <- paste0("<strong>Hated:</strong> ",  show.episodes$hated)
  id <- paste0("<strong>",                  show.episodes$epid, "</strong><br />",
               "<strong>Title:</strong> ",  show.episodes$title, "<br />",
               "<strong>Aired:</strong> ",  show.episodes$firstaired.string, "<br />",
               "<strong>Rating:</strong> ", show.episodes$rating, "%<br />",
               "<strong>Votes:</strong> ",  show.episodes$votes, "<br />",
               "<strong>Loved:</strong> ",  show.episodes$loved, "<br />",
               "<strong>Hated:</strong> ",  show.episodes$hated)
  
  show.episodes$id <- id
  #show.episodes$id <- paste(epid, title, airdate, rating, votes, loved, hated, collapse = "<br />")
  return(show.episodes)
}
