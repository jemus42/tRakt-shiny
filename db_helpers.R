# show_id <- 1960
# show_query <- "24"

options(caching_debug = TRUE)

# Check if a table exists in db, if not, create it
check_cache_table <- function(table_name, reference_table) {
  if (!(dbExistsTable(cache_db_con, table_name))) {
    dbCreateTable(cache_db_con, table_name, reference_table)
  }
}

is_already_cached <- function(table_name, show_id) {
  if (dbExistsTable(cache_db_con, table_name)) {
    cached_ids <- tbl(cache_db_con, table_name) %>% 
      pull(show_id) %>%
      unique()
    
    already_cached <- show_id %in% cached_ids
  } else {
    already_cached <- FALSE
  }
  
  already_cached
}

cache_add_show <- function(show_query = NULL, show_id = NULL, replace = FALSE) {
  
  if (!is.null(show_query)) {

    res <- cache_add_show_query(show_query = show_query, replace = replace)
    
    if (is.null(res)) {
      return(NULL)
    }
        
  } else if (!is.null(show_id)) {
    
    show_id <- as.character(show_id)
    already_cached <- is_already_cached("shows", show_id)
    
    if ((already_cached & replace) | (!already_cached)) {
      
      ret <- trakt.shows.summary(show_id, extended = "full")
      ret <- cleanup_show_summary(ret)
      cache_add_data("shows", ret, replace = replace)
      
    } else if (getOption("caching_debug")) {
      cli_alert_info("Show '{show_id}' already cached, not downloading")
    }
    
    invisible(show_id)
    
  } else {
    stop("Gotta pick one yo")
  }
}


cache_add_show_query <- function(show_query, replace = FALSE) {
  
  ret <- trakt.search(
    show_query, type = "show", n_results = 1, extended = "full"
  )
  
  if (identical(ret, tibble())) return(NULL)
  
  ret <- cleanup_show_summary(ret)
  
  already_cached <- is_already_cached("shows", ret$show_id)
  
  if ((already_cached & replace) | (!already_cached)) {

    cache_add_data("shows", ret, replace = replace)
    
  } else if (getOption("caching_debug")) {
    cli_alert_info("Show '{show_id}' already cached, not updating")
  }
  
  invisible(ret$show_id)
}


cache_add_episodes <- function(show_id, replace = FALSE) {
  
  show_id <- as.character(show_id)
  already_cached <- is_already_cached("episodes", show_id)
  
  if ((already_cached & replace) | (!already_cached)) {
    ret <- trakt.seasons.summary(show_id, extended = "full", episodes = TRUE)
    
    episodes <- ret %>%
      pull(episodes) %>%
      bind_rows() %>%
      select(-available_translations) %>%
      mutate(show_id = show_id)
    
    seasons <- ret %>%
      select(-episodes) %>%
      mutate(show_id = show_id)
    
    cache_add_data("seasons", seasons, replace = replace)
    cache_add_data("episodes", episodes, replace = replace)
  } else if (getOption("caching_debug")) {
    cliapp::cli_alert_info(
      "Episodes for '{show_id}' already cached, not replacing"
    )
  }
  
  
  # Return show_id
  # unique(show_id)
}

cache_add_data <- function(table_name, new_data, replace = FALSE) {
  # cached | replace | what do
  # TRUE   | TRUE    | -> drop, write
  # TRUE   | FALSE   | -> do nothing
  # FALSE  | TRUE    | -> write
  # FALSE  | FALSE   | -> write
  new_data <- new_data %>%
    mutate(cache_date = as.numeric(lubridate::now(tzone = "UTC")))
  
  if (rlang::has_name(new_data, "first_aired")) {
    new_data <- new_data %>%
      mutate(first_aired = as.numeric(first_aired))
  }
  if (rlang::has_name(new_data, "updated_at")) {
    new_data <- new_data %>%
      mutate(updated_at = as.numeric(updated_at))
  }
  
  # Only check/create table after cache_date has been added
  check_cache_table(table_name, new_data)
  
  # Not needed once I settle on a global ID / name
  matching_id <- "show_id"
  
  current_id <- new_data %>%
    pull(!!sym(matching_id)) %>%
    unique() %>%
    as.character()
  
  # Get ids of data already in cache
  cached_ids <- tbl(cache_db_con, table_name) %>% 
    pull(!!sym(matching_id)) %>%
    unique()
  
  already_cached <- current_id %in% cached_ids
  
  # Delete if already cached and replace = TRUE
  if (already_cached & replace) {
    
    if (getOption("caching_debug")) {
      cli_alert_info("Deleting and replacing show '{current_id}' at '{table_name}'")
    }
    
    query <- glue_sql("
      DELETE FROM {table_name}
      WHERE ({`matching_id`} = {current_id});
    ", .con = cache_db_con)
    
    res <- dbSendStatement(cache_db_con, query)
    # dbHasCompleted(res)
    # dbGetRowsAffected(res)
    dbClearResult(res)
    
    dbWriteTable(cache_db_con, table_name, new_data, append = TRUE)
  }
  
  if (!already_cached) {
    if (getOption("caching_debug")) cli_alert_success("Not in cache, writing")
    dbWriteTable(cache_db_con, table_name, new_data, append = TRUE)
  }
  
  if (already_cached & !replace & getOption("caching_debug")) {
    cli_alert_info("Not replacing '{current_id}' data already in '{table_name}'")
  }
}
  
