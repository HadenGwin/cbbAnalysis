#' Acquire a given team's four factor statistics
#'
#' This function retrieves and calculates the four-factor metrics for a specific team from a provided season webpage.
#' The metrics include Effective Field Goal Percentage (eFG%), Offensive Rebound Percentage (ORB%), Turnover Percentage (TOV%), Free Throws per Field Goal Attempt (FT/FGA), and Offensive Rating (ORTG).
#'
#' @param season_url  an html link to a team's webpage
#'
#' @return A tibble containing the calculated metrics for the team, including:
#' \itemize{
#'   \item \code{Poss} - Estimated number of possessions.
#'   \item \code{eFG_pct} - Effective Field Goal Percentage.
#'   \item \code{ORB_pct} - Offensive Rebound Percentage.
#'   \item \code{TOV_pct} - Turnover Percentage.
#'   \item \code{FT_FGA} - Free Throws Made per Field Goal Attempted.
#'   \item \code{ORTG} - Offensive Rating, points scored per 100 possessions.
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' season_url <- "https://www.sports-reference.com/cbb/schools/teamname/2024.html"
#' team_metrics <- calculate_team_metrics(season_url)
#' print(team_metrics)
#' }
#'
#' @import rvest
#' @import dplyr
#'
calculate_team_metrics <- function(season_url) {

  #Load the season page
  season_page <- tryCatch({
    read_html(season_url)
  }, error = function(e) {
    stop("Failed to load the Season page.")
  })

  #Extract the Player Per Game table
  per_game_table <- season_page %>%
    html_element("#div_players_per_game") %>%
    html_table(fill = TRUE) %>%
    as_tibble()

  if (nrow(per_game_table) == 0) {
    stop("Failed to extract the Player Per Game table.")
  }

  #Filter for the "Team Totals" row
  team_totals <- per_game_table %>%
    filter(.data$Player == "Team Totals")

  if (nrow(team_totals) == 0) {
    stop("Team Totals row not found in the Player Per Game table.")
  }

  #Extract the team/opp table
  team_table <- season_page %>%
    html_element("#div_season-total_per_game") %>%
    html_table(fill = TRUE) %>%
    as_tibble(.name_repair = "minimal")

  if (nrow(team_table) == 0) {
    stop("Failed to extract the table.")
  }

  #Assign column names if needed
  colnames(team_table) <- c(
    "Entity", "G", "MP", "FG", "FGA", "FG_pct",
    "FG2", "FGA2", "FG2_pct", "FG3", "FGA3",
    "FG3_pct", "FT", "FTA", "FT_pct", "ORB", "DRB",
    "TRB", "AST", "STL", "BLK", "TOV", "PF", "PTS"
  )

  #Filter for "Team" and "Opponent" rows
  team_row <- team_table %>% filter(Entity == "Team")
  opp_row <- team_table %>% filter(Entity == "Opponent")

  if (nrow(team_row) == 0 || nrow(opp_row) == 0) {
    stop("Failed to extract team or opponent rows.")
  }

  #Extract the relevant stats
  FGA <- as.numeric(team_totals$FGA)
  ORB <- as.numeric(team_totals$ORB)
  TOV <- as.numeric(team_totals$TOV)
  FTA <- as.numeric(team_totals$FTA)
  eFG <- as.numeric(team_totals$`eFG%`)
  PTS <- as.numeric(team_totals$PTS)

  teamORB <- as.numeric(team_row$ORB)
  oppDRB <- as.numeric(opp_row$DRB)

  #Extract TOV, FGA, and FTA values
  TOV <- as.numeric(team_row$TOV)
  FGA <- as.numeric(team_row$FGA)
  FTA <- as.numeric(team_row$FTA)
  FT  <- as.numeric(team_row$FT)

  #Calculate possessions
  poss <- FGA - ORB + TOV + (0.475 * FTA)
  #Calculate ORB%
  orb_percentage <- teamORB / (teamORB + oppDRB)
  #Calculate TOV%
  tov_percentage <- 100 * TOV / (FGA + (0.475 * FTA) + TOV)
  #Calculate FT/FGA
  ft_fga <- FT / FGA
  #calculate ORTG
  Ortg = PTS/poss * 100

  #Create the dataframe
  team_metrics <- tibble(
    Team = "Team Totals",
    Poss = poss,
    eFG_pct = eFG,
    ORB_pct = orb_percentage,
    TOV_pct = tov_percentage,
    FT_FGA = ft_fga,
    ORTG = Ortg
  )

  return(team_metrics)
}
