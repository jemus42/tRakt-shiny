#### Shiny Server ####

shinyServer(function(input, output, session){
  
  #### Data pulls ####
  # Need to depend on actionButton, hence the isolate() ¯\_(ツ)_/¯
  show.overview <- reactive({
    if (input$get.show == 0){return(NULL)}
    isolate({
      show <- trakt.search(input$show.query)
    })
    return(show)
  })

  show.episodes <- reactive({
    withProgress(session, min = 0, max = 5, {
    if (input$get.show == 0){return(NULL)}
      setProgress(message = "Fetching data from Trakt.tv…",
                  detail = "Getting general show information…",
                  value = 1)
      show          <- show.overview()
      setProgress(detail = "Getting season data…",
                  value = 2)
      show.seasons  <- trakt.getSeasons(show$tvdb_id)
      setProgress(detail = "Initializing episode dataset…",
                  value = 3)
      show.episodes <- initializeEpisodes(show.seasons)
      setProgress(detail = "Getting episode data (this takes a while…)",
                  value = 4)
      show.episodes <- trakt.getEpisodeData(show$tvdb_id, show.episodes)
      setProgress(detail = "Done!",
                  value = 5)
      return(show.episodes)
    })
  })
  
  #### Actual plotting ####
  # This is done in observe(), for some actionButton reactivity reason
  observe({
    if (input$get.show == 0){return(NULL)}
    epdata <- transform(show.episodes(), id = paste0(epid, " - ", title))
    
    plot <- epdata %>% ggvis(y = ~rating, fill = ~season, key := ~id)
    plot <- plot %>%  layer_points(prop("x", as.name(input$btn.scale.x)), size.hover := 200)
    if (input$btn.scale.y == TRUE){
      plot <- plot %>% scale_numeric("y", domain = c(0, 100))
    }  
    plot <- plot %>% add_axis("x", title = names(btn.scale.x.choices[btn.scale.x.choices == input$btn.scale.x]))
    plot <- plot %>% add_axis("y", title = "Rating")
    plot <- plot %>% add_legend("fill", title = "Season", orient = "left")
    plot <- plot %>% add_tooltip(show_tooltip, "hover")
    plot <- plot %>% bind_shiny(plot_id = "ggvis")
  })
  
  #### Output Assignments ####
  output$show.name <- renderText({
    if (input$get.show == 0){return(NULL)}
    show    <- show.overview()
    showurl <- paste0("<a href=", show$url, ">", show$title, "</a>", " (", show$year, ")")
    return(showurl)
  })
  
  output$show.overview <- renderText({
    if (input$get.show == 0){return(NULL)}
    show     <- show.overview()
    overview <- paste0("<div class='well'><p>", show$overview, '</p></div>')
    return(overview)
  })
})
