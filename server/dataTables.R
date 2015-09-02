# Episode dataTable
output$table_episodes <- DT::renderDataTable({
  if (!(isActive())){return(NULL)}
  show           <- show()
  if (is.null(show)){return(NULL)}
  episodes       <- show$episodes
  overview       <- gsub("'", "’", episodes$overview)
  # Temporarily disable until new shiny version is documented propery, use 'escape = FALSE'
  #episodes$title <- paste0("<a target='_blank' title ='",
  #                         overview, "' href='", episodes$url,
  #                         "'>", episodes$title, "</a>")
  episodes       <- episodes[table.episodes.columns]
  names(episodes)<- table.episodes.names
  return(episodes)
}, options = list(orderClasses = TRUE, 
                  lengthMenu = list(c(25, 50, -1), c('25', '50', 'All')),
                  pageLength = 50,
                  columnDefs = list(list(sWidth=c("10px"), 
                                         aTargets=list(0)))))
# Season dataTable
output$table_seasons <- DT::renderDataTable({
  if (!(isActive())){return(NULL)}
  show              <- show()
  if (is.null(show)){return(NULL)}
  seasons           <- show$seasons
  seasons$rating.sd <- round(seasons$rating.sd, 2)
  seasons           <- seasons[table.seasons.columns]
  names(seasons)    <- table.seasons.names
  return(seasons)
}, options = list(orderClasses = TRUE, paging = FALSE))
