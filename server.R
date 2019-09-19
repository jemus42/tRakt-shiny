#### Shiny Server ####
cache_db <- cache_db()
# on.exit(dbDisconnect(cache_db), add = TRUE)

cache_shows_tbl    <- tbl(cache_db, "shows")
cache_posters_tbl  <- tbl(cache_db, "posters")
cache_seasons_tbl  <- tbl(cache_db, "seasons")
cache_episodes_tbl <- tbl(cache_db, "episodes")

shinyServer(function(input, output, session) {
  
  #### Caching observer ####
  observe({
    cached_shows <- cache_shows_tbl %>% collect()
    
    show_ids <- cached_shows$show_id
    names(show_ids) <- as.character(glue("{cached_shows$title} ({cached_shows$year})"))
    
    updateSelectizeInput(
      session, "shows_cached", choices = show_ids, selected = ""
    )
  })
  
  show_info <- eventReactive(input$get_show, {
    cat("show reactive", input$shows_cached, "\n")
    
    input_show <- as.integer(input$shows_cached)
    
    cat("input$show:", input_show, "\n")
    
    show_tmp <- cache_shows_tbl %>% filter(show_id == input_show)
    
    if (!is_already_cached("posters", input_show)) {
      tibble(show_id = input_show, show_poster = get_fanart_poster(pull(show_tmp, tvdb))) %>%
        cache_add_data("posters", .)
    }
    
    show_tmp %>%
      left_join(
        tbl(cache_db, "posters") %>%
          select(show_id, show_poster),
        by = "show_id"
      ) %>%
      collect()
  })
  
  output$show_overview <- renderUI({
    show <- show_info()
    cat("show_name renderUI", show$title, "\n")

    fluidRow(
      column(2, img(src = show$show_poster, width = "120px")),
      column(
        10, 
        h2(show$title),
        p(show$overview)
      )
    )
  })

  
  observeEvent(input$get_show, {
    cat(input$shows_cached, "\n")
    
    if (input$get_show > 0) {
      # cat("input$get_show is", input$get_show, "\n")
      hide(id = "intro-wellpanel")
      shinyjs::show(id = "show_overview")
    }
  })
})
