# Data cleanup helpers

cleanup_show_summary <- function(show) {
  show %>%
    select(-matches("^type$|^score$|^avail.*translations$")) %>%
    mutate(
      genres = map_chr(genres, paste0, collapse = ", ")
    ) %>%
    rename(show_id = trakt)
}
