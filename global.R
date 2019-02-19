#### Loading libraries ####
source("dependencies/package-check.R")

## Set API key ##
if (is.null(getOption("trakt.client.id"))) {
  get_trakt_credentials()
}


#### Setting some values ----
##Define some HTML characters
bullet <- HTML("&#8226;")
mu     <- HTML("&#956;")
sigma  <- HTML("&#963;")

# UI elements 
btn.scale.x.choices <- c(
  "Total Episode Numbers" = "epnum",
  "Episodes per Season" = "episode",
  "Airdate" = "first_aired"
)

btn.scale.y.choices <- c(
  "Rating" = "rating",
  "Votes" = "votes"
)

table.episodes.columns <- c("epnum", "epid", "title", "first_aired.string", "rating", "votes")
table.episodes.names <- c("#", "Episode ID", "Title", "Airdate", "Rating", "Votes")

table.seasons.columns <- c("season", "episode_count", "rating", "votes", "avg.rating.season", "rating.sd", "top.rating.episode", "lowest.rating.episode")
table.seasons.names <- c("Season", "Episodes", "Rating", "Votes", "Average Rating", "Episode sd", "Highest Rating", "Lowest Rating")

# Helper functions ----

# Get posters from fanart.tv
# tvdbid <- 353764
get_fanart_poster <- function(tvdbid, api_key = "113407042401248f50123d1c112abf0d") {
  query <- paste0("https://webservice.fanart.tv/v3/tv/", tvdbid, "?api_key=", api_key)
  ret <- httr::content(httr::GET(query))
  ret_url <- ret$tvposter[[1]]$url

  if (is.character(ret_url) & nchar(ret_url) > 10) {
    return(ret_url)
  } else {
    message("Possibly broken fanart: ", tvdbid)
    return("")
  }
}

# JS for button clicks ----

jscode <- '
  $(function() {
    var $els = $("[data-proxy-click]");
      $.each(
      $els,
        function(idx, el) {
          var $el = $(el);
            var $proxy = $("#" + $el.data("proxyClick"));
              $el.keydown(function (e) {
              if (e.keyCode == 13) {
            $proxy.click();
          }
        });
      }
    );
  });
  '
