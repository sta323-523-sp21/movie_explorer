search_movies <- function(term, api_key = "8ee9ba8e") {
  
  base_url <- "http://www.omdbapi.com/?apikey="
  url <- str_c(base_url, api_key, "&s=", term)
  
  total_results <- as.numeric(read_json(url)$totalResults)
  
  search_movies_by_page <- function(t, p) {
    url_page <- str_c(base_url, api_key, "&s=", t, "&page=", p)
    fromJSON(url_page)$Search %>% 
      as_tibble()
  }
  
  map_df(seq(ceiling(total_results / 10)), search_movies_by_page, t = term)
}
