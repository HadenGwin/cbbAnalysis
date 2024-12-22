#' Predict Matchup Scores for Two Teams
#'
#' This function predicts the scores of a basketball matchup between two teams using pre-trained models and the teams' four-factor metrics.
#' It calculates each team's statistics, creates a dataset for prediction, and uses the provided models to estimate the final scores.
#'
#' @param team1_url A string containing the URL of the first team's season statistics page.
#' @param team2_url A string containing the URL of the second team's season statistics page.
#' @param model_results A list containing pre-trained models for predicting scores. The list must include:
#'   \itemize{
#'     \item \code{home_model} - A model object for predicting the home team's score.
#'     \item \code{away_model} - A model object for predicting the away team's score.
#'   }
#'
#' @return A list with the predicted results for the matchup:
#' \itemize{
#'   \item \code{away_team} - Name of the away team.
#'   \item \code{home_team} - Name of the home team.
#'   \item \code{predicted_away_points} - Predicted score for the away team.
#'   \item \code{predicted_home_points} - Predicted score for the home team.
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example URLs for the teams' season statistics pages:
#' team1_url <- "https://www.sports-reference.com/cbb/schools/team1/2024.html"
#' team2_url <- "https://www.sports-reference.com/cbb/schools/team2/2024.html"
#'
#' # Example of a model:
#' model_results <- trainModel()
#'
#' # Predict matchup scores:
#' result <- predict_matchup(team1_url, team2_url, model_results)
#' print(result)
#' }
#'
predict_matchup <- function(team1_url, team2_url, model_results) {

  #Calculate the metrics for each team
  team1_stats <- calculate_team_metrics(team1_url)
  team2_stats <- calculate_team_metrics(team2_url)

  new_data <- data.frame(
    away_team    = "Team1_Away",  # or parse from the URL if you want
    away_poss    = team1_stats$Poss,
    away_eFG_pct = team1_stats$eFG_pct,
    away_TOV_pct = team1_stats$TOV_pct,
    away_ORB_pct = team1_stats$ORB_pct,
    away_FT_FGA  = team1_stats$FT_FGA,
    away_Ortg    = team1_stats$ORTG,

    home_team    = "Team2_Home",  # or parse from the URL
    home_poss    = team2_stats$Poss,
    home_eFG_pct = team2_stats$eFG_pct,
    home_TOV_pct = team2_stats$TOV_pct,
    home_ORB_pct = team2_stats$ORB_pct,
    home_FT_FGA  = team2_stats$FT_FGA,
    home_Ortg    = team2_stats$ORTG
  )

  #additional columns
  new_data$delta_Ortg = new_data$home_Ortg - new_data$away_Ortg # or any integer
  new_data$combined_Ortg <- new_data$home_Ortg + new_data$away_Ortg # or any integer
  new_data$delta_eFG_pct <- new_data$home_eFG_pct - new_data$away_eFG_pct
  new_data$combined_eFG_pct <- new_data$home_eFG_pct + new_data$away_eFG_pct
  new_data$game_id <- 1

  #Predict the final scores using the stored models
  home_pred <- predict(model_results$home_model, new_data)
  away_pred <- predict(model_results$away_model, new_data)

  #a list with the predicted scores:
  return(list(
    away_team = new_data$away_team,
    home_team = new_data$home_team,
    predicted_away_points = away_pred,
    predicted_home_points = home_pred
  ))
}
