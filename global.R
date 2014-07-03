#### Loading libraries ####

if (require(tRakt)){
  message("tRakt package is installed")
} else {
  message("tRakt package not installed, doing so…")
  library(devtools)
  install_github("jemus42/tRakt-package")
}

library(shiny)
library(ggvis)
library(rmarkdown)

## Set API key ##
if (!file.exists("key.json")){
  stop("Place your key.json in the root of this directory")
} else {
  options(trakt.apikey = jsonlite::fromJSON("key.json")$apikey)
}

#### Setting some values ####
btn.scale.x.choices <- c("Total Episode Numbers" = "epnum",
                         "Airdate"               = "firstaired.posix")


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

