#### Shiny Server ####
library(dplyr)
library(glue)

library(RSQLite)
# library(DBI)

con <- dbConnect(RSQLite::SQLite(), "cache/tRakt.db")

shinyServer(function(input, output, session) {
  
  #### Caching observer ####
  observe({
    cached_shows <- tbl(con, "shows") %>% collect()
    
    show_ids <- cached_shows$show_id
    names(show_ids) <- as.character(glue("{cached_shows$title} ({cached_shows$year})"))
    
    updateSelectizeInput(
      session, "shows_cached", choices = show_ids, selected = NULL
    )
  })
  
  show_info <- eventReactive(input$get_show, {
    cat("show reactive", input$shows_cached, "\n")
    tbl(con, "shows") %>%
      filter(show_id == !!input$shows_cached) %>%
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
