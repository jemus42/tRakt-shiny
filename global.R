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
# if (!'rmarkdown' %in% installed.packages()) install.packages("rmarkdown", dependencies=TRUE)
# library(rmarkdown)

## Set API key ##
if (!file.exists("key.json")){
  stop("Place your key.json in the root of this directory")
} else {
  options(trakt.apikey = jsonlite::fromJSON("key.json")$apikey)
}

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
