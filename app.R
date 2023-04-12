library(shinyWidgets)
library(DT)
library(tidyverse)
library(dplyr)
library(reshape2)
library(recommenderlab)
library(shinydashboard)
library(data.table)
library(lsa)
library(shinyjs)
library(fst)

source("global.R", local = TRUE)$value
source("load_data.R", local = TRUE)$value

ui <- fluidPage(
  sidebarPanel(
    h2("Recommender"),
    uiOutput("tab"),
    br(),
    tags$ul(
      tags$li("Select 10 movies from the dropdown"),
      tags$li("Rate them (0-5) with the sliders"),
      tags$li("Select 'ICBF' for item-based collaborative filtering"),
      tags$li("OR 'Genre' for content (genre) based recommendations"),
      tags$li("Click 'go'")
    ),
    h2("Movies"),
    pickerInput(inputId = "movie_selection",
                label = "",
                choices = movie_names,
                options = pickerOptions(
                  actionsBox = FALSE,
                  maxOptions = 10 # maximum of options
                ), 
                multiple = TRUE),
    h4(" "),
    uiOutput("movie_rating01"),
    uiOutput("movie_rating02"),
    uiOutput("movie_rating03"),
    uiOutput("movie_rating04"),
    uiOutput("movie_rating05"),
    uiOutput("movie_rating06"),
    uiOutput("movie_rating07"),
    uiOutput("movie_rating08"),
    uiOutput("movie_rating09"),
    uiOutput("movie_rating10"),
    
    prettyRadioButtons(inputId = "rec_method", 
                 label = "Recommendation type:",
                 choices = list("IBCF" = "ibcf",
                   "Genre" = "genre"),
                 selected = "ibcf"),
    
    actionButton("go", "Go")
  ),
  mainPanel(
    div(id = "anchor_box"),
    useShinyjs(),
    tableOutput("recomm"),
  )
)


server <- function(input, output, session) {
  source("ui_server.R", local = TRUE)$value
  source("data_server.R", local = TRUE)$value
  
  url <- a("repository", href="https://github.com/STATWORX/blog/tree/master/movie_recommendation")
  output$tab <- renderUI({
    tagList("The code for this app is based on this ", url, ".")
  })
}

shinyApp(ui = ui, server = server)
