#### Shiny Server ####
shinyServer(function(input, output, session) {
  
  # Caching observer ----
  observe({
    cached_shows <- cache_shows_tbl %>% 
      collect() %>%
      arrange(desc(cache_date))
    
    show_ids <- paste0("cache:", cached_shows$show_id)
    names(show_ids) <- as.character(glue("{cached_shows$title} ({cached_shows$year})"))
    
    updateSelectizeInput(
      session, "shows_cached", choices = show_ids, selected = sample(show_ids, 1)
    )
  })
  
  # Show info reactiveEvent ----
  show_info <- eventReactive(input$get_show, {

    if (stringr::str_detect(input$shows_cached, "^cache:")) {
      cli_alert_info("cached show detected {input$shows_cached}")
      
      input_show <- input$shows_cached %>%
        stringr::str_extract(., "\\d+")
      
    } else {
      input_show <- input$shows_cached %>%
        stringr::str_remove(., "^cache:") %>%
        cache_add_show()
      
      cli_alert_info("input_show after caching attempt is {input_show}")
    }
    
    if (is.null(input_show)) {
      return(NULL)
    } else {
      show_tmp <- cache_shows_tbl %>% filter(show_id == input_show)
    }
    
    if (!is_already_cached("posters", input_show)) {
      tibble(show_id = input_show, show_poster = get_fanart_poster(pull(show_tmp, tvdb))) %>%
        cache_add_data("posters", .)
    }
    
    show_tmp %>%
      left_join(
        cache_posters_tbl %>%
          select(show_id, show_poster),
        by = "show_id"
      ) %>%
      collect()
  })
  
  # Show overview output ----
  output$show_overview <- renderUI({
    show <- show_info()
    # cat("show_name renderUI", show$title, "\n")

    if (!is.null(show)) {
      fluidRow(
        column(2, tags$figure(img(src = show$show_poster, width = "120px"))),
        column(
          10, 
          h2(a(href = glue("https://trakt.tv/shows/{show$slug}"), show$title)),
          p(stringr::str_trunc(show$overview, 200, "right"))
        )
      )
    } else {
      fluidRow(
        column(
          10, offset = 1,
          h2("Nothing found :("),
          p("Try entering the show title, but like... try harder.")
        )
      )
    }

  })

  
  # get_show observer ----
  observeEvent(input$get_show, {
    # cat(input$shows_cached, "\n")
    
    if (input$get_show > 0) {
      # cat("input$get_show is", input$get_show, "\n")
      hide(id = "intro-wellpanel")
      shinyjs::show(id = "show_overview")
    }
  })
})
