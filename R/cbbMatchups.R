#' Retrieve Matchups and Scores for a Specific Date
#'
#' This function retrieves NCAA basketball matchups, scores, and boxscore links for a given date from Sports Reference.
#' By default, it fetches games for the current date. The results include both away and home team details, as well as final scores and a link to the boxscore.
#'
#' @param date A Date object or string representing the desired date (default is the current system date, \code{Sys.Date()}).
#'
#' @return A tibble containing the following columns:
#' \itemize{
#'   \item \code{date} - The date of the games.
#'   \item \code{away_team} - The name of the away team.
#'   \item \code{home_team} - The name of the home team.
#'   \item \code{away_score} - The final score of the away team (integer or \code{NA} if unavailable).
#'   \item \code{home_score} - The final score of the home team (integer or \code{NA} if unavailable).
#'   \item \code{boxscore_url} - A URL linking to the game’s boxscore, or \code{NA} if not available.
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Retrieve games for today's date
#' games_today <- matchupsDate()
#' print(games_today)
#'
#' # Retrieve games for a specific date
#' games_specific_date <- matchupsDate(as.Date("2024-12-01"))
#' print(games_specific_date)
#' }
#'
#' @import dplyr
#' @importFrom lubridate month day year
#' @import rvest
matchupsDate <- function(date = Sys.Date()) {

  month <- month(date)
  day <- day(date)
  year <- year(date)

  base_url <- "https://www.sports-reference.com/cbb/boxscores/index.cgi"
  page_url <- paste0(base_url, "?month=", month, "&day=", day, "&year=", year)

  page <- read_html(page_url)

  # Selector for men's games
  games_nodes <- page %>% html_elements("div.game_summary.nohover.gender-m")

  if (length(games_nodes) == 0) {
    message("No games found for this date.")
    return(tibble())
  }

  games_df <- lapply(games_nodes, function(node) {
    rows <- node %>% html_elements("table.teams tr")

    # The first two rows should correspond to away/home teams:
    away_row <- rows[1]
    home_row <- rows[2]

    away_team <- away_row %>% html_element("td a") %>% html_text(trim = TRUE)
    away_score <- away_row %>% html_element("td.right") %>% html_text(trim = TRUE)

    home_team <- home_row %>% html_element("td a") %>% html_text(trim = TRUE)
    home_score <- home_row %>% html_element("td.right") %>% html_text(trim = TRUE)

    # Extract the boxscore link
    boxscore_link <- node %>%
      html_element("td.right.gamelink a") %>%
      html_attr("href")

    # Convert scores to integers
    away_score <- suppressWarnings(as.integer(away_score))
    home_score <- suppressWarnings(as.integer(home_score))

    # Construct the tibble
    tibble(
      date = date,
      away_team = away_team,
      home_team = home_team,
      away_score = away_score,
      home_score = home_score,
      boxscore_url = if (!is.na(boxscore_link)) paste0("https://www.sports-reference.com", boxscore_link) else NA_character_
    )
  }) %>% bind_rows()

  return(games_df)
}

