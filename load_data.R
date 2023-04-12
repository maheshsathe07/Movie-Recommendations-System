# You can find the dataset for this movie recommendation here: 
# https://grouplens.org/datasets/movielens/latest/ 
# Download the ml-latest-small.zip file and save the files locally

small_image_url = "https://liangfgithub.github.io/MovieImages/"

ratings_data = get_ratings_data()
movie_data = get_movie_data()

#for the drop-down, just offer movies with more than 50 ratings
dropdown_movieId <- ratings_data %>% group_by(movieId) %>% 
  summarise(count = n()) %>% 
  filter(count > 50) %>%
  pull(movieId)

dropdown_movies <- movie_data %>% filter(movieId %in% dropdown_movieId)

#create choices for the dropdown:
#option value will be movieId
movie_names <- dropdown_movies %>% 
  arrange(title) %>%
  pull(movieId)

#option label will be title
#choices ordered alphabetically by title
names(movie_names) = movie_data %>% 
  filter(movieId %in% dropdown_movieId) %>% 
  arrange(title) %>%
  pull(title) %>%
  as.character()

#limit the rating matrix to just the titles in the dropdown (movies with more than 50 reviews)
ratings_data <- ratings_data %>% filter(movieId %in% dropdown_movieId)

#ibcf model
rec_mod = get_cf_recommender_model()

#item profile for genred-based recommendation
movie.profile = get_item_profile()



