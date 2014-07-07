#### Shiny Server ####

shinyServer(function(input, output, session){
  
  #### Data pulls ####
  # Need to depend on actionButton, hence the isolate() ¯\_(ツ)_/¯
  show <- reactive({
    if (input$get_show == 0){return(NULL)}
    isolate({
     # withProgress(session, min = 0, max = 5, {
        show          <- list()
        show$overview <- trakt.search(input$show_query)
        show_id       <- show$overview$tvdb_id
        #setProgress(message = "Fetching data from Trakt.tv…",
        #            detail = "Getting general show information…", value = 1)
  
        cachedfile    <- paste0(show_id, ".rds")
        cachedpath    <- file.path("cache", cachedfile)
        
        if (file.exists(cachedpath)){
        #  setProgress(detail = "Reading from cache…", value = 3)
          show$episodes <- readRDS(file = cachedpath)
        } else {
        #  setProgress(detail = "Getting season data…", value = 2)
          show$seasons  <- trakt.getSeasons(show_id)
        #  setProgress(detail = "Initializing episode dataset…", value = 3)
          show$episodes <- initializeEpisodes(show$seasons)
        #  setProgress(detail = "Getting episode data (this takes a while…)", value = 4)
          show$episodes <- trakt.getEpisodeData(show_id, show$episodes)
        #  setProgress(detail = "Caching results…", value = 5)
          saveRDS(object = show$episodes, file = cachedpath)
        #  setProgress(detail = "Done!", value = 6)
        }
     # })
    })
    return(show)
  })
  
  #### Actual plotting ####
  # This is done in observe(), for some actionButton reactivity reason
  observe({
    if (input$get_show == 0){return(NULL)}
    Sys.sleep(.1)
    show    <- show()
    epdata  <- make_tooltip(show$episodes)
    label.x <- names(btn.scale.x.choices[btn.scale.x.choices == input$btn_scale_x_variable])
    label.y <- names(btn.scale.y.choices[btn.scale.y.choices == input$btn_scale_y_variable])
    
    plot <- epdata %>% ggvis(x    = as.name(input$btn_scale_x_variable),
                             y    = as.name(input$btn_scale_y_variable), 
                             fill = ~season, 
                             key  := ~id)
    plot <- plot %>% layer_points(size.hover := 200)
    if (input$btn_scale_y_range == TRUE){
      plot <- plot %>% scale_numeric("y", domain = c(0, 100))
    }  
    plot <- plot %>% add_axis("x", title = label.x)
    plot <- plot %>% add_axis("y", title = label.y)
    plot <- plot %>% add_legend("fill", title = "Season", orient = "left")
    plot <- plot %>% add_tooltip(function(epdata){epdata$id}, "hover")
    plot <- plot %>% bind_shiny(plot_id = "ggvis")
  })
  
  #### Output Assignments ####
  output$show.name <- renderText({
    if (input$get_show == 0){return(NULL)}
    isolate({
      show    <- show()
      show    <- show$overview
      showurl <- paste0("<a href=", show$url, ">", show$title, "</a>", 
                        " (", show$year, ")", " — ", show$ratings$percentage, "% Rating / ",
                        show$ratings$votes, " Votes")
      return(showurl)
    })
  })
  
  output$show.overview <- renderUI({
    if (input$get_show == 0){return(NULL)}
    show           <- show()
    show           <- show$overview
    banner         <- show$images$banner
    imageContainer <- tags$div(align = "center", tags$img(src = banner))
    overview       <- p(show$overview)
    output         <- wellPanel(imageContainer, 
                                h3("Show summary"), overview)
    return(output)
  })
  
  output$table.episodes <- renderDataTable({
    if (input$get_show == 0){return(NULL)}
    show           <- show()
    episodes       <- show$episodes
    episodes$title <- paste0("<a href='", episodes$url.trakt, "'>", episodes$title, "</a>")
    episodes       <- episodes[table.episodes.columns]
    names(episodes)<- table.episodes.names
    return(episodes)
  }, options = list(bSortClasses = TRUE))
})
