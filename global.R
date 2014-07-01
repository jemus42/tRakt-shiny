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

## Set API key ##
if (!file.exists("key.json")){
  stop("Place your key.json in the root of this directory")
} else {
  options(trakt.apikey = jsonlite::fromJSON("key.json")$apikey)
}
