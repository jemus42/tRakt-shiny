#### Shiny Server ####
shinyServer(function(input, output, session){
  
  #### Define a global "active" state ####
  # Parsing url querys
  url_show_query <- reactive({
    url_query    <- session$clientData$url_search
    query_parsed <- as.data.frame(parseQueryString(url_query))
    message("is.null(query_parsed$show):")
    message(is.null(query_parsed$show))
    if (!(is.null(query_parsed$show))){
      message(paste0("query_parsed$show is '", query_parsed$show, "'"))
      return(NULL)
    } else {
      message(paste0("query_parsed$show is '", query_parsed$show, "'"))
      return(query_parsed$show)
    }
  })
  
  observe({
    url_show_query <- url_show_query()
    if (input$get_show > 0 || !is.null(url_show_query)){
      updateCheckboxInput(session, "isActive", value = TRUE)
      message(paste0("Activate. url_show_query is '", url_show_query, "'"))
      message(is.null(url_show_query))
    }
  })
  
  isActive <- reactive(label = "isActive", {
    url_show_query <- url_show_query()
    if (input$get_show > 0 || !is.null(url_show_query)){
      return(TRUE)
    } else {
      return(FALSE)
    }
  })
    
  #### Data pulls ####
  # Need to depend on actionButton, hence the isolate() ¯\_(ツ)_/¯
  show <- reactive(label = "show", {
    if (!(is.null(url_show_query()))){
      query_url <- url_show_query()
    } else {
      query_url <- NULL
    }
    if (!(isActive())){return(NULL)}
    # Initiate progress bar
    withProgress(session, min = 0, max = 5, {
    # Use isolate() on show_query to not execute on every update of the input
    query        <- isolate(input$show_query)
    query_cached <- isolate(input$shows_cached)
    # textInput is favored over selectizeInput containing chached data
    # but query_url should take precedence over all
    if (query_cached == "" && query == ""){
      return(NULL)
    } else if (query == "" && query_cached != ""){
      query <- query_cached
    }
    
    # Inititalize show object as a list
    show          <- list()
    
    setProgress(message = "Fetching data from Trakt.tv…",
                detail  = "Getting general show information…", value = 1)
    
    # Starting to pull data
    if (is.null(query_url)){
      if (grepl(pattern = "^trakt:", x = query)){
        slug <- substring(query, 7)
        show$info <- trakt.show.summary(slug, extended = "full,images")
      } else {
        show$info <- trakt.search(query)
      }
    } else {
      show$info <- trakt.show.summary(query_url)
    }
    
    if (!is.null(show$info$error)){
      warning(paste0(show$info$error, ": ", query))
      updateTextInput(session, inputId = "show_query", label = "Try again…", value = "")
      return(NULL)
    }
    
    show_id    <- show$info$ids$slug
    showindex  <- data.frame(title = show$info$title, id = show_id)
    message(paste("Getting", show_id))
    
    # Let's pretend this is a smart solution for caching
    cache_titles(showindex, cacheDir)
    cachedfile <- paste0(show_id, ".rds")
    cachedfile <- file.path(cacheDir, cachedfile)
    
    if (file.exists(cachedfile) && (file.info(cachedfile)$mtime - Sys.time()) > -14){
      setProgress(detail = "Reading from cache…", value = 3)
      show <- readRDS(file = cachedfile)
    } else {
      show$summary <- trakt.show.summary(show_id)
      setProgress(detail = "Getting season data…", value = 2)
      show$seasons  <- trakt.getSeasons(show_id)
      setProgress(detail = "Getting episode data (this takes a while…)", value = 3)
      show$episodes <- trakt.getEpisodeData(show_id, show$seasons$season)
      show$episodes$rating <- 10 * show$episodes$rating
      show$seasons  <- get_season_ratings(show$episodes, show$seasons)
      setProgress(detail = "Caching results…", value = 4)
      saveRDS(object = show, file = cachedfile)
      setProgress(detail = "Done!", value = 5)
    }
    show$episodes <- make_tooltip(show$episodes, keyvar = "tooltip")
    return(show)
    }) # End progressbar after the return(), which apparently is a biggie
  })
  
  #### Actual plotting ####
  source("server/episode_plot.R", local = TRUE)
  
  #### Output Assignments ####
  output$show_name <- renderText({
    if (!(isActive())){return("Show Title will appear here soon. Are you excited?")}
    show      <- show()
    if (is.null(show)){return("Looks like I didn’t find anything, try again maybe?")}
    summary          <- show$summary
    label_ended      <- tags$span(class = "label label-default", "ended")
    label_continuing <- tags$span(class = "label label-success", "continuing")
    
    if (summary$status == "ended"){
      if (summary$year != max(show$episodes$year)){
        runtime <- paste0("(", summary$year, " - ", max(show$episodes$year), ") ", label_ended)
      } else {
        runtime <- paste0("(", summary$year, ") ", label_ended)
      }
    } else {
      runtime <- paste0("(", summary$year, ") ", label_continuing)
    }
    showurl <- paste0("<a href='http://trakt.tv/shows/", show$info$ids$slug, "'>", summary$title, "</a> ", runtime)
    return(showurl)
    
  })
  
  output$show_overview <- renderUI({
    if (!(isActive())){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    show           <- show$info
    overview       <- p(class = "lead", show$overview)
    return(overview)
  })
  
  # Assemble ratings displayed in the show info box
  output$show_ratings <- renderUI({
    if (!(isActive())){return(NULL)}
    show                <- show()
    if (is.null(show)){return(NULL)}
    
    show_rating_total    <- paste0(round(10 * show$summary$rating, 1), "%")
    show_rating_episodes <- paste0(10 * round(mean(show$episodes$rating, na.rm = T), 2), "%")
    show_votes           <- show$summary$votes
    show_ratings_sd      <- paste0(10 * round(sd(show$episodes$rating, na.rm = T), 2), "%")
    show_flipcount       <- get_flipcount(show$info$title)$count
    
    output <- fluidRow(
                column(2, h4("Show Rating"), show_rating_total),
                column(2, h4("Episode ", tags$abbr(mu, title = "Average")), show_rating_episodes),
                column(2, h4("Episode ", tags$abbr(sigma, title = "Standard Deviation")), show_ratings_sd),
                column(2, h4("Total Votes"), show_votes),
                column(2, h4("Times", tags$a(href = "http://tisch.ding.si", "flipped")), show_flipcount)
              )
    return(output)
  })
  
  # Assemble the show banner (needs work)
  output$show_banner <- renderUI({
    if (!(isActive())){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    # Get image link, and use https
    banner         <- sub("http:", "https:", show$info$images$poster$medium)
    image          <- tags$img(src = banner, width = 250, class = "img-responsive img-thumbnail")
    #return(list(src = show$images$poster, class = "img-rounded", width = 250))
  })
  
  # Assemble the links displayed under the show overview
  output$show_links <- renderUI({
    if (!(isActive())){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    ids            <- show$info$ids
    imdb           <- paste0("http://www.imdb.com/title/",         ids$imdb)
    tvrage         <- paste0("http://www.tvrage.com/shows/id-",    ids$tvrage)
    tvdb           <- paste0("http://thetvdb.com/?tab=series&id=", ids$tvdb)
    wiki           <- paste0("http://en.wikipedia.org/wiki/Special:Search?search=list of ", 
                             show$info$title, " episodes&go=Go")
    
    output <- tags$span(bullet, tags$strong(tags$a(href = imdb,   "IMDb")), 
                        bullet, tags$strong(tags$a(href = tvrage, "TVRage")),
                        bullet, tags$strong(tags$a(href = tvdb,   "TheTVDB")),
                        bullet, tags$strong(tags$a(href = wiki,   "Wikipedia")), bullet)
    return(output)
    
  })
  
  #### Data tables ####
  source("server/dataTables.R", local = TRUE)
  
  observe({
    url_query    <- session$clientData$url_search
    query_parsed <- as.data.frame(parseQueryString(url_query))
    
#     # Take actions on queries
#     if (!is.null(query_parsed$show)){
#       updateTextInput(session, inputId = "show_query", value = query_parsed$show)
#     }
    
    if (!is.null(query_parsed$debug)){
      if (query_parsed$debug == "1"){
        updateCheckboxInput(session, "debug", value = TRUE)
      }
    }
  })
  
  output$usage_stats <- renderPlot({
    url_query    <- session$clientData$url_search
    query_parsed <- as.data.frame(parseQueryString(url_query))
    if (is.null(query_parsed$debug)){return(NULL)}
    titles       <- file.path(cacheDir, "showtitles.rds")
    if (query_parsed$debug == "1" && file.exists(titles)){
      archived <- readRDS(file = titles)
      p <- ggplot(data = archived, aes(x = reorder(title, requests), y = requests))
      p <- p + geom_bar(stat = "identity")
      p <- p + coord_flip()
      p <- p + labs(y = "Times Requested", x = "Show Title", title = "Usage Statistics")
      return(p)
    } else {
      return(NULL)
    }
  })
  
  #### Caching observer ####
  observe({
    #input$get_show
    
    indexfile <- file.path(cacheDir, "showtitles.rds")
    if (!file.exists(indexfile)){
      fix_cached_index(cacheDir)
      reset_title_cache(cacheDir)
    }
    
    showindex  <- readRDS(indexfile)
    ids        <- as.character(showindex$title)
    names(ids) <- showindex$title
    randomshow <- sample(ids, 1)
    updateSelectizeInput(session, inputId = "shows_cached",
                         choices = ids, selected = randomshow)
  })
})
