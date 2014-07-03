#### Shiny Server ####

shinyServer(function(input, output, session){
  
  show.overview <- reactive({
    input$get.show
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
  
  observe({
    if (input$get.show == 0){return(NULL)}
    epdata <- transform(show.episodes(), id = paste0(epid, " - ", title))
    
    epdata %>% 
      ggvis(y = ~rating, fill = ~season, key := ~id) %>%
      layer_points(prop("x", as.name(input$btn.scale.x)), size.hover := 200) %>%
      add_axis("x", title = names(btn.scale.x.choices[btn.scale.x.choices == input$btn.scale.x])) %>%
      add_axis("y", title = "Rating") %>%
      add_legend("fill", title = "Season", orient = "left") %>%
      add_tooltip(show_tooltip, "hover") %>% 
      bind_shiny(plot_id = "ggvis")
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
    show <- show.overview()
    return(show$overview)
  })
})
