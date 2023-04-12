genre <- reactive({
    selected_movies = get_selected_movies(input)
    
    #attach each selected movie to the rating it was given by app-user
    for(i in 1:nrow(selected_movies)){
        selected_movies$ratingvec[i] <- input[[as.character(selected_movies$movieId[i])]]
    }
    
    #only needs to be an inner join 
    rating_vec_with_id <- dropdown_movies %>% 
        inner_join(., selected_movies, by = "movieId") %>% 
        select(movieId, ratingvec)
    
    rating_vec = rating_vec_with_id %>%
        pull(ratingvec)
    
    #which movies were rated by current user
    user.rated.ids = selected_movies %>% pull(movieId)
    
    #create user profile
    up.vector = get_user_profile(user.rated.ids, rating_vec_with_id)
    
    #similarity matrix
    #exclude already rated movies from movies we will recommend
    new.movie.profile = movie.profile %>% filter(!movieId %in% user.rated.ids)

    #remove movieId column for computing similarity matrix
    movie.matrix = as.matrix(new.movie.profile)[,-19]
    
    #measure cosine similarity between user profile and each row of the new movie profile
    sim.matrix = apply(movie.matrix, 1, cosine, up.vector)
    
    #convert to dataframe and re-attach movieIds
    sim.df = as.data.frame(sim.matrix)
    sim.df$movieId = new.movie.profile$movieId
    colnames(sim.df) = c("similarity", "movieId")
    
    #get top 5 closest movies
    top.5 = sim.df %>% arrange(desc(similarity)) %>% pull(movieId) %>% head(5)
    
    #get title, number of ratings and average rating
    ratings_stats = get_ratings_stats(top.5)

    results <- movie_data %>% filter(movieId %in% ratings_stats$movieId)
    results <- left_join(results, ratings_stats, by="movieId")
    results <- as.data.frame(results)
    
    results
})


ibcf <- reactive({
    selected_movies = get_selected_movies(input)
    
    #attach each selected movie to the rating it was given by app-user
    for(i in 1:nrow(selected_movies)){
        selected_movies$ratingvec[i] <- input[[as.character(selected_movies$movieId[i])]]
    }
    
    #needs to be a left join to have the same dimensions as the model
    rating_vec <- dropdown_movies %>% 
        left_join(., selected_movies, by = "movieId") %>% 
        pull(ratingvec)
    
    #transform the rating vector into  realRatingMatrix
    rating_vec <- as.matrix(t(rating_vec))
    rating_vec <- as(rating_vec, "realRatingMatrix")

    #predict on the new rating vector with the model we created previously (see load_data.R)
    #we want to pull the top 5 recommendations from the recommender
    top_5_prediction <- predict(rec_mod, rating_vec, n = 5)
    top_5_list <- as(top_5_prediction, "list")
    
    top_5_df <- data.frame(top_5_list)
    colnames(top_5_df) <- "movieId"
    
    top_5_df$movieId <- as.numeric(top_5_df$movieId)
    
    #get title, number of ratings and average rating
    ratings_stats = get_ratings_stats(top_5_df$movieId)
    
    results <- left_join(top_5_df, movie_data, by="movieId")
    results <- left_join(results, ratings_stats, by="movieId")
    results <- as.data.frame(results)
    
    results
})


observeEvent(input$go, {
    if(length(input$movie_selection) < 10){
        sendSweetAlert(
            session = session,
            title = "Please select more movies.",
            text = "You need to rate 10 movies.",
            type = "info")
    } else {
        if (input$rec_method == 'ibcf') {
            recomdata <- ibcf()
        } else {
            recomdata <- genre()
        }
        
        if(nrow(recomdata) < 1) {
            sendSweetAlert(
                session = session,
                title = "Please vary in your ratings.",
                text = "Do not give the same rating for all movies.",
                type = "info")
        } else{
            output$recomm <- renderUI({
                lapply(1:5, function(i) {
                    fluidRow(style = "height:200px;",
                        #movie image
                        column(3, img(width = 100, 
                                      title = recomdata[i,'title'], 
                                      src = paste0(small_image_url, recomdata[i,'movieId'], '.jpg?raw=true'))),
                        #movie information: title, genres, number of ratings, average rating
                        column(9, 
                               fluidRow(column(12, strong(recomdata[i,'title']))),
                               fluidRow(column(12, recomdata[i,'genres'])),
                               fluidRow(column(12, paste(recomdata[i,'count'], "total reviews"))),
                               fluidRow(column(12, paste("Average rating:", recomdata[i,'avg_rating'])))
                        )#text column
                    )#movie row               
                })
            })#renderUI
        }#there are varied ratings
        
        runjs('document.getElementById("anchor_box").scrollIntoView();')
    }#there are results
})