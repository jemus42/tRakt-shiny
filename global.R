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

#### Helper functions ####
all_values <- function(x) {
  if(is.null(x)) return(NULL)
  paste0(names(x), ": ", format(x), collapse = "<br />")
}
