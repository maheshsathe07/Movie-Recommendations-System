generate_slider = function(selected_index) {
    if(length(input$movie_selection[selected_index]) > 0){
        fluidRow(
            column(
                shinyBS::popify(
                    el = sliderInput(inputId = input$movie_selection[selected_index],
                                     label = dropdown_movies %>% filter(movieId == input$movie_selection[selected_index]) %>% select(title),
                                     max = 5,
                                     min = 0,
                                     step = .5,
                                     value = 3),
                    title = "",
                    placement = "right"
                ),
                width = 10
            )
        )
    }
}

output$movie_rating01 <- renderUI({
    generate_slider(1)
})

output$movie_rating02 <- renderUI({
    generate_slider(2)
})

output$movie_rating03 <- renderUI({
    generate_slider(3)
})

output$movie_rating04 <- renderUI({
    generate_slider(4)
})

output$movie_rating05 <- renderUI({
    generate_slider(5)
})

output$movie_rating06 <- renderUI({
    generate_slider(6)
})

output$movie_rating07 <- renderUI({
    generate_slider(7)
})

output$movie_rating08 <- renderUI({
    generate_slider(8)
})

output$movie_rating09 <- renderUI({
    generate_slider(9)
})

output$movie_rating10 <- renderUI({
    generate_slider(10)
})