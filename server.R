#### Shiny Server ####

shinyServer(function(input, output, session){
  output$debug.show.name <- renderText({
    if (input$get.show == 0){return(NULL)}
    show <- trakt.search(input$show.query)
    showurl <- paste0("<a href=", show$url, ">", show$title, "</a>", " (", show$year, ")")
    return(showurl)
  })
    
  show.episodes <- reactive({
    if (input$get.show == 0){return(NULL)}
    show          <- trakt.search(input$show.query)
    #show.summary  <- trakt.show.summary(show$tvdb_id)
    #show.stats    <- trakt.show.stats(show$tvdb_id)
    show.seasons  <- trakt.getSeasons(show$tvdb_id)
    show.episodes <- initializeEpisodes(show.seasons)
    show.episodes <- trakt.getEpisodeData(show$tvdb_id, show.episodes)
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
})
