#### Shiny Server ####
shinyServer(function(input, output, session) {
  
  cache_db <- dbConnect(RSQLite::SQLite(), "cache/tRakt.db")
  # on.exit(dbDisconnect(cache_db), add = TRUE)
  
  #### Caching observer ####
  observe({
    cached_shows <- tbl(cache_db, "shows") %>% collect()
    
    show_ids <- cached_shows$trakt
    names(show_ids) <- as.character(glue("{cached_shows$title} ({cached_shows$year})"))
    
    updateSelectizeInput(
      session, "shows_cached", choices = show_ids, selected = ""
    )
  })
  
  show_info <- eventReactive(input$get_show, {
    cat("show reactive", input$shows_cached, "\n")
    
    input_show <- as.integer(input$shows_cached)
    
    cat("input$show:", input_show, "\n")
    
    tbl(con, "shows") %>%
      filter(trakt == input_show) %>%
      collect()
  })
  
  output$show_name <- renderUI({
    show <- show_info()
    cat("show_name renderUI", show$title, "\n")
    show$title
  })

  
  observeEvent(input$get_show, {
    cat(input$shows_cached, "\n")
    
    if (input$get_show > 0) {
      cat("input$get_show is", input$get_show, "\n")
      hide(id = "intro-wellpanel")
      shinyjs::show(id = "show_info")
    }
  })
})
