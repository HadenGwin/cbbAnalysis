
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cbbAnalysis

<!-- badges: start -->
<!-- badges: end -->

The goal of cbbAnalysis is to scrape Sports Reference webpages to
extract NCAA basketball statistics and stores them as tables. It enables
analysis using tools such as random forest regression, allowing users to
build samples of any size, dynamically predict matchups, and evaluate
performance metrics.

## Installation

You can install the development version of cbbAnalysis like so:

``` r

install.packages("devtools")
devtools::install_github("HadenGwin/cbbAnalysis")
```

# Examples

Here is a basic example that demonstrates some of the functionality of
the cbbAnalysis package:

## Scraping Matchups

``` r
library(cbbAnalysis)
# Get matchups for December 1, 2024
matchups <- matchupsDate("2024-12-01")
print(matchups)
#> # A tibble: 34 × 6
#>    date       away_team            home_team  away_score home_score boxscore_url
#>    <chr>      <chr>                <chr>           <int>      <int> <chr>       
#>  1 2024-12-01 South Carolina State Xavier             68         71 https://www…
#>  2 2024-12-01 Sacred Heart         Boston Un…         73         65 https://www…
#>  3 2024-12-01 Alcorn State         Maryland           58         96 https://www…
#>  4 2024-12-01 NJIT                 UMass              68         80 https://www…
#>  5 2024-12-01 LIU                  Niagara            52         60 https://www…
#>  6 2024-12-01 Middle Tennessee     UAB                76         69 https://www…
#>  7 2024-12-01 Arkansas-Pine Bluff  Kansas St…         73        120 https://www…
#>  8 2024-12-01 North Florida        Nebraska           72        103 https://www…
#>  9 2024-12-01 Texas State          Texas Sou…         72         59 https://www…
#> 10 2024-12-01 Mercyhurst           San Franc…         59         87 https://www…
#> # ℹ 24 more rows
```

## Calculating Four Factors Statistics

``` r
boxscore_url <- "https://www.sports-reference.com/cbb/boxscores/2024-12-02-03-nevada.html"

four_factors <- create_four_factors(boxscore_url)
print(four_factors)
#> # A tibble: 2 × 8
#>   Team              Poss eFG_pct TOV_pct ORB_pct FT_FGA  Ortg Final
#>   <chr>            <dbl>   <dbl>   <dbl>   <dbl>  <dbl> <dbl> <dbl>
#> 1 washington-state  69.3   0.517    17.9    30    0.1    97.1    68
#> 2 nevada            70.2   0.421    19.2    24.2  0.158  81.4    57
```

## Individual Team Statistics

``` r

team = "https://www.sports-reference.com/cbb/schools/indiana/2024.html"

teamStats <- calculate_team_metrics(team)
print(teamStats)
#> # A tibble: 1 × 7
#>   Team         Poss eFG_pct ORB_pct TOV_pct FT_FGA  ORTG
#>   <chr>       <dbl>   <dbl>   <dbl>   <dbl>  <dbl> <dbl>
#> 1 Team Totals  69.2   0.521   0.271    15.5   0.25  104.
```

## train a model on a dynamic sample size

``` r
start_date <- "2024-11-28"
end_date <- "2024-12-12"
num_games_per_day = 3
ntree = 699

newModel <- trainModel(start_date, end_date, num_games_per_day, ntree)
#> Processing game 1 of 45 
#> Processing game 2 of 45 
#> Processing game 3 of 45 
#> Processing game 4 of 45 
#> Processing game 5 of 45 
#> Processing game 6 of 45 
#> Processing game 7 of 45 
#> Processing game 8 of 45 
#> Processing game 9 of 45 
#> Processing game 10 of 45 
#> Processing game 11 of 45 
#> Processing game 12 of 45 
#> Processing game 13 of 45 
#> Processing game 14 of 45 
#> Processing game 15 of 45 
#> Processing game 16 of 45 
#> Processing game 17 of 45 
#> Processing game 18 of 45 
#> Processing game 19 of 45 
#> Processing game 20 of 45 
#> Processing game 21 of 45 
#> Processing game 22 of 45 
#> Processing game 23 of 45 
#> Processing game 24 of 45 
#> Processing game 25 of 45 
#> Processing game 26 of 45 
#> Processing game 27 of 45 
#> Processing game 28 of 45 
#> Processing game 29 of 45 
#> Processing game 30 of 45 
#> Processing game 31 of 45 
#> Processing game 32 of 45 
#> Processing game 33 of 45 
#> Processing game 34 of 45 
#> Processing game 35 of 45 
#> Processing game 36 of 45 
#> Processing game 37 of 45 
#> Processing game 38 of 45 
#> Processing game 39 of 45 
#> Processing game 40 of 45 
#> Processing game 41 of 45 
#> Processing game 42 of 45 
#> Processing game 43 of 45 
#> Processing game 44 of 45 
#> Processing game 45 of 45 
#> Home RMSE: 6.322775 
#> Away RMSE: 4.571331
```

## predict matchups

``` r
team1_url <- "https://www.sports-reference.com/cbb/schools/indiana/2024.html"
team2_url <- "https://www.sports-reference.com/cbb/schools/connecticut/2024.html"

results <- trainModel(start_date = "2024-11-01", end_date = "2024-11-15", num_games_per_day = 5, ntree = 300)
#> No games found for this date.
#> No games found for this date.
#> No games found for this date.
#> Processing game 1 of 60 
#> Processing game 2 of 60 
#> Processing game 3 of 60 
#> Processing game 4 of 60 
#> Processing game 5 of 60 
#> Processing game 6 of 60 
#> Processing game 7 of 60 
#> Processing game 8 of 60 
#> Processing game 9 of 60 
#> Processing game 10 of 60 
#> Processing game 11 of 60 
#> Processing game 12 of 60 
#> Processing game 13 of 60 
#> Processing game 14 of 60 
#> Processing game 15 of 60 
#> Processing game 16 of 60 
#> Processing game 17 of 60 
#> Processing game 18 of 60 
#> Processing game 19 of 60 
#> Processing game 20 of 60 
#> Processing game 21 of 60 
#> Processing game 22 of 60 
#> Processing game 23 of 60 
#> Processing game 24 of 60 
#> Processing game 25 of 60 
#> Processing game 26 of 60 
#> Processing game 27 of 60 
#> Processing game 28 of 60 
#> Processing game 29 of 60 
#> Processing game 30 of 60 
#> Processing game 31 of 60 
#> Processing game 32 of 60 
#> Processing game 33 of 60 
#> Processing game 34 of 60 
#> Processing game 35 of 60 
#> Processing game 36 of 60 
#> Processing game 37 of 60 
#> Processing game 38 of 60 
#> Processing game 39 of 60 
#> Processing game 40 of 60 
#> Processing game 41 of 60 
#> Processing game 42 of 60 
#> Processing game 43 of 60 
#> Processing game 44 of 60 
#> Processing game 45 of 60 
#> Processing game 46 of 60 
#> Processing game 47 of 60 
#> Processing game 48 of 60 
#> Processing game 49 of 60 
#> Processing game 50 of 60 
#> Processing game 51 of 60 
#> Processing game 52 of 60 
#> Processing game 53 of 60 
#> Processing game 54 of 60 
#> Processing game 55 of 60 
#> Processing game 56 of 60 
#> Processing game 57 of 60 
#> Processing game 58 of 60 
#> Processing game 59 of 60 
#> Processing game 60 of 60 
#> Home RMSE: 8.242864 
#> Away RMSE: 6.360252

predictions <- predict_matchup(team1_url, team2_url, results)
print(predictions)
#> $away_team
#> [1] "Team1_Away"
#> 
#> $home_team
#> [1] "Team2_Home"
#> 
#> $predicted_away_points
#>        1 
#> 69.75278 
#> 
#> $predicted_home_points
#>       1 
#> 81.4155
```
