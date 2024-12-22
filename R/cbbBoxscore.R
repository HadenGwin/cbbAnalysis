#' Extract Four-Factor Metrics from a Boxscore
#'
#' This function retrieves advanced and basic basketball statistics from a Sports Reference boxscore webpage and calculates four-factor metrics for two teams in a matchup. The four factors include Effective Field Goal Percentage (eFG%), Turnover Percentage (TOV%), Offensive Rebound Percentage (ORB%), and Free Throws Made per Field Goal Attempted (FT/FGA).
#'
#' @param boxscore_url A string containing the URL of the boxscore page. The URL must link to a valid Sports Reference game page.
#'
#' @return A tibble with the following columns:
#' \itemize{
#'   \item \code{Team} - The identifier of the team.
#'   \item \code{Poss} - The estimated number of possessions.
#'   \item \code{eFG_pct} - Effective Field Goal Percentage.
#'   \item \code{TOV_pct} - Turnover Percentage.
#'   \item \code{ORB_pct} - Offensive Rebound Percentage.
#'   \item \code{FT_FGA} - Free Throws Made per Field Goal Attempted.
#'   \item \code{Ortg} - Offensive Rating (points scored per 100 possessions).
#'   \item \code{Final} - The final score of the team in the game.
#' }
#'
#' @details
#' This function extracts and processes advanced and basic statistics for both teams in a matchup using the provided boxscore URL. It dynamically identifies the team IDs on the page and calculates metrics based on extracted data.
#' If the \code{boxscore_url} is missing or invalid, the function returns an empty tibble or raises an error.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' boxscore_url <- "https://www.sports-reference.com/cbb/boxscores/2024-01-01-game.html"
#' four_factors <- create_four_factors(boxscore_url)
#' print(four_factors)
#' }
#'
#' @import rvest
#' @import dplyr
create_four_factors <- function(boxscore_url) {

  if (is.na(boxscore_url)) {
    message("Boxscore URL is missing. Returning an empty tibble.")
    return(tibble())
  }

  page <- tryCatch({
    read_html(boxscore_url)
  }, error = function(e) {
    stop("Failed to load the boxscore page. Check the URL.")
  })

  # Extract div IDs for advanced box scores
  div_ids <- page %>%
    html_elements("div[id^='box-score-advanced-']") %>%
    html_attr("id")

  # Extract team IDs and remove suffixes like '_sh'
  team_ids_from_divs <- gsub("box-score-advanced-", "", div_ids)
  team_ids_from_divs <- gsub("_sh$", "", team_ids_from_divs)  # Remove the '_sh' suffix

  if (length(team_ids_from_divs) < 2) {
    stop("Failed to extract team IDs from the page.")
  }

  # Assign team IDs dynamically
  team1_id <- team_ids_from_divs[1]
  team2_id <- team_ids_from_divs[2]

  # Extract totals row for Team 1 (Advanced)
  aTeamAdvancedNode <- page %>%
    html_element(paste0("#box-score-advanced-", team1_id)) %>%
    html_elements("tr") %>%
    Filter(function(x) grepl("School Totals", html_text(x, trim = TRUE), ignore.case = TRUE), .)

  if (length(aTeamAdvancedNode) == 0) {
    stop("Failed to find the 'School Totals' row for Team 1 (Advanced).")
  }

  aTeamAdvanced <- aTeamAdvancedNode[[1]] %>%
    html_elements("td") %>%
    html_text(trim = TRUE)

  # Extract totals row for Team 2 (Advanced)
  hTeamAdvancedNode <- page %>%
    html_element(paste0("#box-score-advanced-", team2_id)) %>%
    html_elements("tr") %>%
    Filter(function(x) grepl("School Totals", html_text(x, trim = TRUE), ignore.case = TRUE), .)

  if (length(hTeamAdvancedNode) == 0) {
    stop("Failed to find the 'School Totals' row for Team 2 (Advanced).")
  }

  hTeamAdvanced <- hTeamAdvancedNode[[1]] %>%
    html_elements("td") %>%
    html_text(trim = TRUE)

  # Extract totals row for Team 1 (Basic)
  aTeamBasicNode <- page %>%
    html_element(paste0("#box-score-basic-", team1_id)) %>%
    html_elements("tr") %>%
    Filter(function(x) grepl("School Totals", html_text(x, trim = TRUE), ignore.case = TRUE), .)

  if (length(aTeamBasicNode) == 0) {
    stop("Failed to find the 'School Totals' row for Team 1 (Basic).")
  }

  aTeamBasic <- aTeamBasicNode[[1]] %>%
    html_elements("td") %>%
    html_text(trim = TRUE)

  # Extract totals row for Team 2 (Basic)
  hTeamBasicNode <- page %>%
    html_element(paste0("#box-score-basic-", team2_id)) %>%
    html_elements("tr") %>%
    Filter(function(x) grepl("School Totals", html_text(x, trim = TRUE), ignore.case = TRUE), .)

  if (length(hTeamBasicNode) == 0) {
    stop("Failed to find the 'School Totals' row for Team 2 (Basic).")
  }

  hTeamBasic <- hTeamBasicNode[[1]] %>%
    html_elements("td") %>%
    html_text(trim = TRUE)

  # Extract FT and FGA
  aTeamFT <- as.numeric(aTeamBasic[11])
  aTeamFGA <- as.numeric(aTeamBasic[3])
  hTeamFT <- as.numeric(hTeamBasic[11])
  hTeamFGA <- as.numeric(hTeamBasic[3])

  # Calculate FT/FGA
  aTeamFTFGA <- aTeamFT / aTeamFGA
  hTeamFTFGA <- hTeamFT / hTeamFGA
  # Calculate possessions
  aPoss <- as.numeric(aTeamBasic[3]) - as.numeric(aTeamBasic[14]) +
    as.numeric(aTeamBasic[20]) + (0.475 * as.numeric(aTeamBasic[12]))

  hPoss <- as.numeric(hTeamBasic[3]) - as.numeric(hTeamBasic[14]) +
    as.numeric(hTeamBasic[20]) + (0.475 * as.numeric(hTeamBasic[12]))

  # Create a dataframe for four factors
  four_factors <- tibble(
    Team = c(team1_id, team2_id),
    Poss = c(aPoss, hPoss),
    eFG_pct = c(as.numeric(aTeamAdvanced[3]), as.numeric(hTeamAdvanced[3])),
    TOV_pct = c(as.numeric(aTeamAdvanced[12]), as.numeric(hTeamAdvanced[12])),
    ORB_pct = c(as.numeric(aTeamAdvanced[6]), as.numeric(hTeamAdvanced[6])),
    FT_FGA = c(aTeamFTFGA, hTeamFTFGA),
    Ortg = c(as.numeric(aTeamAdvanced[14]), as.numeric(hTeamAdvanced[14])),
    Final = c(as.numeric(aTeamBasic[22]), as.numeric(hTeamBasic[22]))
    )

  return(four_factors)
}

