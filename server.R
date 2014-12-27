#### Shiny Server ####

shinyServer(function(input, output, session){
  
  #### Data pulls ####
  # Need to depend on actionButton, hence the isolate() ¯\_(ツ)_/¯
  show <- reactive({
    if (input$get_show == 0){return(NULL)}
     # Initiate progress bar
     withProgress(session, min = 0, max = 5, {
      # Use isolate() on show_query to not execute on every update of the input
      query        <- isolate(input$show_query)
      query_cached <- isolate(input$shows_cached)
      # textInput is favored over selectizeInput containing chached data
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
      show$overview <- trakt.search(query)
      if (!is.null(show$overview$error)){
        warning(paste0(show$overview$error, ": ", query))
        updateTextInput(session, inputId = "show_query", label = "Try again…", value = "")
        return(NULL)
      }
      
      show_id       <- show$overview$tvdb_id
      showindex     <- data.frame(title = show$overview$title, id = show$overview$tvdb_id)
      
      # Let's pretend this is a smart solution for caching
      cache_titles(showindex, cacheDir)
      cachedfile    <- paste0(show_id, ".rds")
      cachedpath    <- file.path(cacheDir, cachedfile)
      
      if (file.exists(cachedpath) && (file.info(cachedpath)$mtime - Sys.time()) > -30){
        setProgress(detail = "Reading from cache…", value = 3)
        show <- readRDS(file = cachedpath)
      } else {
        setProgress(detail = "Getting season data…", value = 2)
        show$seasons  <- trakt.getSeasons(show_id)
        setProgress(detail = "Getting episode data (this takes a while…)", value = 3)
        show$episodes <- trakt.getEpisodeData2(show_id, show$seasons$season)
        show$seasons  <- get_season_ratings(show$episodes, show$seasons)
        setProgress(detail = "Caching results…", value = 4)
        saveRDS(object = show, file = cachedpath)
        setProgress(detail = "Done!", value = 5)
      }
      show$episodes <- make_tooltip(show$episodes, keyvar = "tooltip")
      return(show)
      }) # End progressbar after the return(), which apparently is a biggie
  })
  
  #### Actual plotting ####
  # This is done in observe(), for some actionButton reactivity reason
  observe({
    if (input$get_show == 0){return(NULL)}
    # The 0 - 100 range thing should only be active for ratings
    if (input$btn_scale_y_range && input$btn_scale_y_variable != "rating"){
      updateCheckboxInput(session, inputId = "btn_scale_y_range", value = FALSE)
    } else if (input$btn_scale_y_zero && input$btn_scale_y_variable == "rating"){
      updateCheckboxInput(session, inputId = "btn_scale_y_zero", value = FALSE)
    }
    show    <- isolate(show())
    if (is.null(show)){return(NULL)}
    label_x <- names(btn.scale.x.choices[btn.scale.x.choices == input$btn_scale_x_variable])
    label_y <- names(btn.scale.y.choices[btn.scale.y.choices == input$btn_scale_y_variable])
    var_x   <- input$btn_scale_x_variable
    var_y   <- input$btn_scale_y_variable
    
    plot <- show$episodes %>% ggvis(x    = as.name(var_x),
                                    y    = as.name(var_y),
                                    fill = ~season)
    plot <- plot %>% layer_points(key := ~tooltip, size.hover := 200, stroke := NA, stroke.hover := "gray", strokeWidth := 2)
    if ("Show" %in% input$btn_trendlines){
      plot <- plot %>% layer_model_predictions(model = "lm", se = F, stroke := "black")
    }
    if ("Season" %in% input$btn_trendlines){
      plot <- plot %>% group_by(season) %>% layer_model_predictions(model = "lm", se = F, stroke = ~season)
      plot <- plot %>% hide_legend("stroke")
    }
    if (input$btn_scale_y_range == TRUE){
      plot <- plot %>% scale_numeric("y", domain = c(0, 100))
    }
    plot <- plot %>% scale_numeric("y", zero = input$btn_scale_y_zero)
    plot <- plot %>% add_axis("x", title = label_x)
    plot <- plot %>% add_axis("y", title = label_y)
    plot <- plot %>% add_legend("fill", title = "Season", orient = "left")
    plot <- plot %>% add_tooltip(function(epdata){epdata$tooltip}, "hover")
    plot <- plot %>% set_options(width = 900, height = 500, renderer = "canvas")
    plot <- plot %>% bind_shiny(plot_id = "ggvis")
  })
  
  #### Output Assignments ####
  output$show_name <- renderText({
    if (input$get_show == 0){return("Show Title will appear here soon. Are you excited?")}
    show      <- show()
    if (is.null(show)){return("Looks like I didn’t find anything, try again maybe?")}
    overview      <- show$overview
    label_ended   <- tags$span(class = "label label-default", "ended")
    label_continuing <- tags$span(class = "label label-success", "continuing")
    
    if (overview$ended){
      if (overview$year != max(show$episodes$year)){
        runtime <- paste0("(", overview$year, " - ", max(show$episodes$year), ") ", label_ended)
      } else {
        runtime <- paste0("(", overview$year, ") ", label_ended)
      }
    } else {
      runtime <- paste0("(", overview$year, ") ", label_continuing)
    }
    showurl   <- paste0("<a href=", overview$url, ">", overview$title, "</a> ",
                      runtime)
    return(showurl)
    
  })
  
  output$show_overview <- renderUI({
    if (input$get_show == 0){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    show           <- show$overview
    overview       <- p(class = "lead", show$overview)
    return(overview)
  })
  
  output$show_ratings <- renderUI({
    if (input$get_show == 0){return(NULL)}
    show                <- show()
    if (is.null(show)){return(NULL)}
    
    show_rating_total    <- paste0(show$overview$ratings$percentage, "%")
    show_rating_episodes <- paste0(round(mean(show$episodes$rating), 2), "%")
    show_votes           <- show$overview$ratings$votes
    show_ratings_sd      <- paste0(round(sd(show$episodes$rating), 2), "%")
    show_flipcount       <- get_flipcount(show$overview$title)$count
    
    output <- fluidRow(
                column(2, h4("Show Rating"), show_rating_total),
                column(2, h4("Episode ", tags$abbr(mu, title = "Average")), show_rating_episodes),
                column(2, h4("Episode ", tags$abbr(sigma, title = "Standard Deviation")), show_ratings_sd),
                column(2, h4("Total Votes"), show_votes),
                column(2, h4("Times", tags$a(href='http://tisch.ding.si', "flipped")), show_flipcount)
              )
    return(output)
  })
  
  output$show_banner <- renderUI({
    if (input$get_show == 0){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    show           <- show$overview
    # Get image link, and use https
    banner         <- sub("http:", "https:", show$images$poster)
    image          <- tags$img(src = banner, width = 250, class = "img-rounded")
    return(image)
  })
  
  output$show_links <- renderUI({
    if (input$get_show == 0){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    overview       <- show$overview
    imdb           <- paste0("http://www.imdb.com/title/",         overview$imdb_id)
    tvrage         <- paste0("http://www.tvrage.com/shows/id-",    overview$tvrage_id)
    tvdb           <- paste0("http://thetvdb.com/?tab=series&id=", overview$tvdb_id)
    wiki           <- paste0("http://en.wikipedia.org/wiki/Special:Search?search=list of ", 
                             overview$title, " episodes&go=Go")
    
    output <- tags$span(bullet, tags$strong(tags$a(href = imdb,   "IMDb")), 
                        bullet, tags$strong(tags$a(href = tvrage, "TVRage")),
                        bullet, tags$strong(tags$a(href = tvdb,   "TheTVDB")),
                        bullet, tags$strong(tags$a(href = wiki,   "Wikipedia")), bullet)
    return(output)
    
  })
  
  #### Data tables ####
  output$table_episodes <- renderDataTable({
    if (input$get_show == 0){return(NULL)}
    show           <- show()
    if (is.null(show)){return(NULL)}
    episodes       <- show$episodes
    overview       <- gsub("'", "’", episodes$overview)
    # Temporarily disable until new shiny version is documented propery, use 'escape = FALSE'
    #episodes$title <- paste0("<a target='_blank' title ='",
    #                         overview, "' href='", episodes$url,
    #                         "'>", episodes$title, "</a>")
    episodes       <- episodes[table.episodes.columns]
    names(episodes)<- table.episodes.names
    return(episodes)
  }, options = list(orderClasses = TRUE, 
                    columnDefs = list(list(sWidth=c("10px"), 
                                           aTargets=list(0)))))
  
  output$table_seasons <- renderDataTable({
    if (input$get_show == 0){return(NULL)}
    show              <- show()
    if (is.null(show)){return(NULL)}
    seasons           <- show$seasons
    seasons$rating.sd <- round(seasons$rating.sd, 2)
    seasons           <- seasons[table.seasons.columns]
    names(seasons)    <- table.seasons.names
    return(seasons)
  }, options = list(orderClasses = TRUE))
  
  #### Parsing url querys ####
  observe({
    url_query    <- session$clientData$url_search
    query_parsed <- as.data.frame(parseQueryString(url_query))
    
    # Take actions on queries
    if (!is.null(query_parsed$show)){
      updateTextInput(session, inputId = "show_query", value = query_parsed$show)
    }
    
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
    input$get_show
    
    indexfile <- file.path(cacheDir, "showtitles.rds")
    if (!file.exists(indexfile)){
      fix_cached_index(cacheDir)
      reset_title_cache(cacheDir)
    }
    
    showindex  <- readRDS(indexfile)
    ids        <- showindex$title
    names(ids) <- showindex$title
    randomshow <- sample(ids, 1)
    updateSelectizeInput(session, inputId = "shows_cached",
                         choices = ids, selected = randomshow)
  })
})
