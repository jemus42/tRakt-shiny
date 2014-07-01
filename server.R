#### Shiny Server ####

shinyServer(function(input, output, sessions){
  output$debug.show.name <- renderText({
    if (input$get.show){
      show <- trakt.search(input$show.query)
      return(show$title)
    }
  })
  
  show.episodes <- reactive({
    show          <- trakt.search(input$show.query)
    show.summary  <- trakt.show.summary(show$tvdb_id)
    show.stats    <- trakt.show.stats(show$tvdb_id)
    show.seasons  <- trakt.getSeasons(show$tvdb_id)
    show.episodes <- initializeEpisodes(show.seasons)
    show.episodes <- trakt.getEpisodeData(show$tvdb_id, show.episodes)
  })
  
  observe({
    show.episodes() %>% 
    ggvis(x = ~firstaired.posix, 
          y = ~rating, 
          fill = ~season) %>% 
    layer_points() %>%
    add_axis("x", title = "Airdate") %>%
    add_axis("y", title = "Rating") %>%
    add_legend("fill", title = "Season") %>%
    add_tooltip(function(data){paste0("Rating: ", data$rating)}, "hover") %>% 
    bind_shiny("ggvis")
  })
})
