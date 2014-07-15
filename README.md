tRakt-shiny
===========

This is `tRakt-shiny` (dummy name) version `0.2.1`. 

Using the [trakt.tv](http://trakt.tv) API to graph show data and whatevs.  
To run it, use `shiny::runGitHub(username = "jemus42", repo = "tRakt-shiny")`.  
Note that this only works with a `key.json` or `key.txt` file containing your trakt.tv API key.  
Whoopsie.  
Maybe you'd rather look at [jemus42.shinyapps.io/tRakt](https://jemus42.shinyapps.io/tRakt/) to see it live™.

## Dependencies
* The [tRakt](https://github.com/jemus42/tRakt-package)-package with its dependencies
* [shiny](http://shiny.rstudio.com)
* [ggvis](http://ggvis.rstudio.com)
* [rmarkdown](http://rmarkdown.rstudio.com)
* [shinyIncubator](https://github.com/rstudio/shiny-incubator)

When you clone this repository, `source`ing `global.R` should automatically install any missing dependency it finds.

## What this should be soon:
[graphtv.kevinformatics.com](http://graphtv.kevinformatics.com), but with more R, more [trakt.tv](http://trakt.tv), and such and such.
