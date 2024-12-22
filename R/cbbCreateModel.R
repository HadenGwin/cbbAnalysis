#' Train Random Forest Models for Predicting Basketball Matchup Outcomes
#'
#' This function trains Random Forest models to predict basketball matchup scores using historical data
#' scraped from Sports Reference. The models are trained separately for home and away teams, using
#' calculated four-factor metrics and additional derived features.
#'
#' @param start_date A string representing the start date for scraping matchups in \code{YYYY-MM-DD} format.
#' @param end_date A string representing the end date for scraping matchups in \code{YYYY-MM-DD} format.
#' @param num_games_per_day An integer specifying the number of games to scrape per day (default: 10).
#' @param ntree An integer specifying the number of trees to use in the Random Forest models (default: 500).
#'
#' @return A list containing the following components:
#' \itemize{
#'   \item \code{home_model} - The trained Random Forest model for predicting home team scores.
#'   \item \code{away_model} - The trained Random Forest model for predicting away team scores.
#'   \item \code{home_rmse} - The root mean square error (RMSE) of the home model on the test set.
#'   \item \code{away_rmse} - The root mean square error (RMSE) of the away model on the test set.
#'   \item \code{predictions} - A data frame containing predictions and actual scores for the test set, including:
#'     \itemize{
#'       \item \code{game_id} - The unique game identifier.
#'       \item \code{home_team} - The name of the home team.
#'       \item \code{away_team} - The name of the away team.
#'       \item \code{actual_home} - The actual score of the home team.
#'       \item \code{predicted_home} - The predicted score of the home team.
#'       \item \code{actual_away} - The actual score of the away team.
#'       \item \code{predicted_away} - The predicted score of the away team.
#'     }
#' }
#'
#' @details
#' This function performs the following steps:
#' \enumerate{
#'   \item Scrapes matchup data for the specified date range.
#'   \item Extracts four-factor metrics for each matchup.
#'   \item Prepares the data for training, including feature engineering.
#'   \item Splits the data into training and testing sets.
#'   \item Trains separate Random Forest models for home and away team score predictions.
#'   \item Evaluates the models using RMSE on the test set.
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Train models using data from a specific date range
#' results <- trainModel(
#'   start_date = "2024-11-01",
#'   end_date = "2024-11-15",
#'   num_games_per_day = 5,
#'   ntree = 300
#' )
#' #' # Print RMSE for the models
#' cat("Home RMSE:", results$home_rmse, "\n")
#' cat("Away RMSE:", results$away_rmse, "\n")
#'
#' # View predictions
#' print(results$predictions)
#' }
#'
#' @importFrom randomForest randomForest
#' @importFrom stats predict
trainModel <- function(start_date, end_date, num_games_per_day = 10, ntree = 500) {

  #Scrape matchups for the given date range
  dates <- seq.Date(from = as.Date(start_date), to = as.Date(end_date), by = "day")
  matchups <- lapply(dates, function(date) {
    Sys.sleep(3)  # Pause for 3 seconds
    data <- matchupsDate(date)
    data[1:min(num_games_per_day, nrow(data)), ]
  })
  matchups_df <- do.call(rbind, matchups)

  #Scrape four factors for each matchup
  fourFactorList <- list()
  for (i in seq_len(nrow(matchups_df))) {
    Sys.sleep(3)
    boxscoreURL <- matchups_df$boxscore_url[i]
    cat("Processing game", i, "of", nrow(matchups_df), "\n")
    gameFactors <- create_four_factors(boxscoreURL)
    gameFactors$date <- matchups_df$date[i]
    gameFactors$home_team <- matchups_df$home_team[i]
    gameFactors$away_team <- matchups_df$away_team[i]
    fourFactorList[[i]] <- gameFactors
  }
  fourFactorDF <- do.call(rbind, fourFactorList)

  #Prepare the training data
  fourFactorDF <- fourFactorDF %>%
    mutate(game_id = rep(1:(nrow(fourFactorDF) / 2), each = 2))

  away_df <- fourFactorDF %>% filter(row_number() %% 2 == 1)  # Odd rows: Away teams
  home_df <- fourFactorDF %>% filter(row_number() %% 2 == 0)  # Even rows: Home teams

  training_df <- away_df %>%
    select(game_id, away_team = Team, away_poss = Poss, away_eFG_pct = eFG_pct,
           away_TOV_pct = TOV_pct, away_ORB_pct = ORB_pct, away_FT_FGA = FT_FGA,
           away_Ortg = Ortg, away_final = Final) %>%
    inner_join(
      home_df %>%
        select(game_id, home_team = Team, home_poss = Poss, home_eFG_pct = eFG_pct,
               home_TOV_pct = TOV_pct, home_ORB_pct = ORB_pct, home_FT_FGA = FT_FGA,
               home_Ortg = Ortg, home_final = Final),
      by = "game_id"
    ) %>%
    mutate(
      delta_Ortg = home_Ortg - away_Ortg,
      combined_Ortg = home_Ortg + away_Ortg,
      delta_eFG_pct = home_eFG_pct - away_eFG_pct,
      combined_eFG_pct = home_eFG_pct + away_eFG_pct
    )

  #Split data into training and testing sets
  set.seed(42)  # For reproducibility
  train_indices <- sample(1:nrow(training_df), 0.8 * nrow(training_df))
  train_data <- training_df[train_indices, ]
  test_data <- training_df[-train_indices, ]

  #Train Random Forest models
  rf_model_home <- randomForest(
    home_final ~ away_poss + away_eFG_pct + away_TOV_pct + away_ORB_pct + away_FT_FGA +
      home_poss + home_eFG_pct + home_TOV_pct + home_ORB_pct + home_FT_FGA +
      delta_Ortg + combined_Ortg + delta_eFG_pct + combined_eFG_pct,
    data = train_data,
    ntree = ntree,
    importance = TRUE
  )

  rf_model_away <- randomForest(
    away_final ~ away_poss + away_eFG_pct + away_TOV_pct + away_ORB_pct + away_FT_FGA +
      home_poss + home_eFG_pct + home_TOV_pct + home_ORB_pct + home_FT_FGA +
      delta_Ortg + combined_Ortg + delta_eFG_pct + combined_eFG_pct,
    data = train_data,
    ntree = ntree,
    importance = TRUE
  )

  #Make predictions on the test set
  home_predictions <- predict(rf_model_home, test_data)
  away_predictions <- predict(rf_model_away, test_data)

  #Evaluate the models
  home_rmse <- sqrt(mean((home_predictions - test_data$home_final)^2))
  away_rmse <- sqrt(mean((away_predictions - test_data$away_final)^2))

  cat("Home RMSE:", home_rmse, "\n")
  cat("Away RMSE:", away_rmse, "\n")

  #Return results
  return(list(
    home_model = rf_model_home,
    away_model = rf_model_away,
    home_rmse = home_rmse,
    away_rmse = away_rmse,
    predictions = data.frame(
      game_id = test_data$game_id,
      home_team = test_data$home_team,
      away_team = test_data$away_team,
      actual_home = test_data$home_final,
      predicted_home = home_predictions,
      actual_away = test_data$away_final,
      predicted_away = away_predictions
    )
  ))
}
