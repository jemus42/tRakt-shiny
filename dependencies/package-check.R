#### Package dependency checking ####
# Small script to check for potentially required packages.
# Installs them if necessary and loads them via library()
# Author: lukas@quantenbrot.de

# Define a list of required/suggested packages
suggested_packages <- read.csv("dependencies/packages.csv", 
                               header = T, stringsAsFactor = F, strip.white = T)

# Define a function to check for packages, install if necessary and load afterwards
check_and_load <- function(pkg = NULL, quiet = TRUE){
  if (is.null(pkg$name) || !is.character(pkg$name) || length(pkg$name) != 1){
    stop("No package defined ¯\\_(ツ)_/¯ Doing nothing.")
  }
  if (!quiet) message("Checking if ", pkg$name, " is installed…")
  installed <- (pkg$name %in% installed.packages())
  if (!installed){
    message(pkg$name, " not found, trying to install from ", pkg$src, "…")
    if (pkg$src == "CRAN"){
      install.packages(pkg$name, dependencies = TRUE)
    } else if (pkg$src == "github"){
      if (!("devtools" %in% installed.packages())){install.packages("devtools")}
      require(devtools)
      install_github(pkg$github)
    }
  } else {
    if (!quiet) message(pkg$name, " is installed, skipping installation…")
  }
  if (!quiet) message("Loading ", pkg$name)
  suppressPackageStartupMessages(library(pkg$name, character.only = T))
}

# Execute previous function on defined packages
for (pkg in seq_len(nrow(suggested_packages))){
  check_and_load(suggested_packages[pkg, ], quiet = TRUE)
}

# Cleanup
rm(pkg, suggested_packages, check_and_load)
