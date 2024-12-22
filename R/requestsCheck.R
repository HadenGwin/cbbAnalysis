library(httr)

# Check the headers of the response
response <- GET("https://www.sports-reference.com/cbb/boxscores/2024-12-01-17-portland.html")
if (status_code(response) == 429) {
  retry_after <- headers(response)[["Retry-After"]]
  if (!is.null(retry_after)) {
    message(paste("Retry after", retry_after, "seconds."))
  } else {
    message("No Retry-After header. Retry later.")
  }
} else {
  message("Request successful!")
}