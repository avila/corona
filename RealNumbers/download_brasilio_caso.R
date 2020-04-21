download_from_brasilio_data <- function(url_base="https://brasil.io/api/dataset/covid19/caso/data?page_size=",
                                        page_size,
                                        pages_max) {
  
  l <- list()
  url <- paste0("https://brasil.io/api/dataset/covid19/caso/data?page_size=", page_size)
  for (i in 1:pages_max) {
    br_io_json <- jsonlite::fromJSON(url)
    l[[i]] <- br_io_json$results
    message("page: ", i, ": ", url)
    #message(url)
    url <- br_io_json$`next`
    if(is.null(url)) break
  }
  
  df <- l %>% purrr::reduce(rbind) %>% unique()
  if (nrow(df)==(page_size * pages_max)) {
    stop("Raise number of pages because the data probably got a bit bigger")
  } else {
    message("data downloaded successfully")
  }
  return(df)
}

df <- download_from_brasilio_data(page_size = 10000, pages_max = 30) %>% tibble::as_tibble()

df %>% 
  filter(place_type=="state", is_last==TRUE) %>% 
  #group_by(date) %>% 
  summarise(sum=sum(confirmed))

df %>% 
  