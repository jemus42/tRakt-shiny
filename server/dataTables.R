# Episode dataTable
output$table_episodes <- DT::renderDataTable({
  if (!(isActive())){return(NULL)}
  show           <- show()
  if (is.null(show)){return(NULL)}
  episodes       <- show$episodes
  overview       <- gsub("'", "’", episodes$overview)
  episodes$title <- paste0("<a target='_blank' title ='",
                           overview, "' href='", episodes$url,
                           "'>", episodes$title, "</a>")
  episodes       <- episodes[table.episodes.columns]
  names(episodes)<- table.episodes.names
  
  episodes <- datatable(episodes, style = "bootstrap", rownames = FALSE, escape = F,
                        options = list(orderClasses = TRUE, 
                                       lengthMenu = list(c(25, 50, -1), c('25', '50', 'All')),
                                       pageLength = 50))
  return(episodes)
})
# Season dataTable
output$table_seasons <- DT::renderDataTable({
  if (!(isActive())){return(NULL)}
  show              <- show()
  if (is.null(show)){return(NULL)}
  seasons           <- show$seasons
  seasons$rating.sd <- round(seasons$rating.sd, 2)
  seasons           <- seasons[table.seasons.columns]
  names(seasons)    <- table.seasons.names
  
  seasons <- datatable(seasons, style = "bootstrap", rownames = FALSE,
                       options = list(orderClasses = TRUE, paging = FALSE))
  return(seasons)
})
