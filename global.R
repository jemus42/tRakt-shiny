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
if (!'rCharts' %in% installed.packages()) install_github("rCharts", "ramnathv", dependencies = TRUE)
library(rCharts)
# See http://ramnathv.github.io/rCharts/
# and http://bl.ocks.org/patilv/raw/7360262/

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

make_tooltip <- function(show.episodes){
  id <- paste0("<strong>",                  show.episodes$epid, "</strong><br />",
               "<strong>Title:</strong> ",  show.episodes$title, "<br />",
               "<strong>Aired:</strong> ",  show.episodes$firstaired.string, "<br />",
               "<strong>Rating:</strong> ", show.episodes$rating, "%<br />",
               "<strong>Votes:</strong> ",  show.episodes$votes, "<br />",
               "<strong>Loved:</strong> ",  show.episodes$loved, "<br />",
               "<strong>Hated:</strong> ",  show.episodes$hated)
  
  show.episodes$id <- id
  return(show.episodes)
}
