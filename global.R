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
