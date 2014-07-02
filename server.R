#### Shiny Server ####

shinyServer(function(input, output, sessions){
  output$debug.show.name <- renderText({
    if (input$get.show == 0){return(NULL)}
    show <- trakt.search(input$show.query)
    return(show$title)
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
    ggvis(x = ~firstaired.posix, 
          y = ~rating, 
          fill = ~season,
          key := ~id) %>% 
    layer_points() %>%
    add_axis("x", title = "Airdate") %>%
    add_axis("y", title = "Rating") %>%
    add_legend("fill", title = "Season") %>%
    add_tooltip(all_values, "click") %>% 
    bind_shiny(plot_id = "ggvis")
  })
})
