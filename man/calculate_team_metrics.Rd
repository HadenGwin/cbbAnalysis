% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cbbTeamFF.R
\name{calculate_team_metrics}
\alias{calculate_team_metrics}
\title{Acquire a given team's four factor statistics}
\usage{
calculate_team_metrics(season_url)
}
\arguments{
\item{season_url}{an html link to a team's webpage}
}
\value{
A tibble containing the calculated metrics for the team, including:
\itemize{
\item \code{Poss} - Estimated number of possessions.
\item \code{eFG_pct} - Effective Field Goal Percentage.
\item \code{ORB_pct} - Offensive Rebound Percentage.
\item \code{TOV_pct} - Turnover Percentage.
\item \code{FT_FGA} - Free Throws Made per Field Goal Attempted.
\item \code{ORTG} - Offensive Rating, points scored per 100 possessions.
}
}
\description{
This function retrieves and calculates the four-factor metrics for a specific team from a provided season webpage.
The metrics include Effective Field Goal Percentage (eFG\%), Offensive Rebound Percentage (ORB\%), Turnover Percentage (TOV\%), Free Throws per Field Goal Attempt (FT/FGA), and Offensive Rating (ORTG).
}
\examples{
\dontrun{
# Example usage:
season_url <- "https://www.sports-reference.com/cbb/schools/teamname/2024.html"
team_metrics <- calculate_team_metrics(season_url)
print(team_metrics)
}

}
