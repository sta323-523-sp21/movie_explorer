library(shiny)
library(tidyverse)
library(jsonlite)
library(httr)
library(shinythemes)
library(shinyalert)

source("R/search_movies.R")

ui <- fluidPage(theme = shinytheme("yeti"),
                
  useShinyalert(),
  
  navbarPage(title = "Movie explorer",
             
             tabPanel(title = "Trends",
                      
                      sidebarLayout(
                        sidebarPanel(width = 2,
                          
                          textInput(
                            inputId = "term",
                            label   = h4("Search for movies with")
                            ),
                          
                          textInput(
                            inputId     = "key",
                            label       = h4("Enter your API key:"),
                            placeholder = "********"
                            ),
                          
                          div(align = "right",
                            actionButton(inputId = "search",
                                         label   = strong("Search!"))
                            ),
                          
                          hr(),
                          br(),
                          
                          sliderInput(inputId = "year",
                                      label   = "Filter for a range of years:",
                                      min     = 1850, 
                                      max     = 2022,
                                      ticks   = FALSE,
                                      sep     = "",
                                      value   = c(1980, 2022)
                          )
                          
                          ),
                        
                        mainPanel(
                          plotOutput(outputId = "ts_plot"),
                          plotOutput(outputId = "bar_plot")
                          )
                        )
                      ), # trends panel
             tabPanel(title = "Data",
                      
                      column(width = 3,
                             h3("Data is from OMDb API"),
                             br(),
                             p(style="text-align:justify",
                             "The OMDb API is a RESTful web service to obtain 
                               movie information, all content and images on the 
                               site are contributed and maintained by our 
                               users."),
                             br(),
                             downloadButton(outputId = "download",
                                            label    = strong("Download data"))
                             ),
                      
                      column(width = 9,
                             dataTableOutput(outputId = "recent")
                      )
                      )
  )
)


server <- function(input, output) {
  
  movies <- eventReactive(input$search, {
    
    url <- str_c("http://www.omdbapi.com/?apikey=", input$key, "&s=", input$term)
    
    if (GET(url)$status_code != 200 || input$term == "") {
      shinyalert(title = "Oh NO!",
                 text = "That was a bad request. Check your API key and
                         make sure you provided a search term.",
                 type = "error")
      NULL
    } else {
      search_movies(term = input$term, api_key = input$key) 
    }
  })

  output$ts_plot <- renderPlot({
    
    shiny::validate(need(!is.null(movies()), message = FALSE))
    
    movies() %>% 
      mutate(Year = str_remove_all(Year, pattern = "–$|–\\d{4}$")) %>%
      count(Year) %>%
      filter(Year %in% input$year[1]:input$year[2]) %>% 
      ggplot(aes(x = as.numeric(Year), y = n, group = 1)) +
      geom_line() +
      geom_point() +
      labs(x = "Year", y = "Count",
           title = paste0("Movies with '", isolate(input$term), 
                          "' in the title")) +
      theme_minimal(base_size = 14)
  })
  
  output$bar_plot <- renderPlot({
    
    shiny::validate(need(!is.null(movies()), message = FALSE))
    
    movies() %>% 
      filter(Year %in% input$year[1]:input$year[2]) %>% 
      ggplot(aes(x = Type)) +
      geom_bar() +
      theme_minimal(base_size = 14) +
      labs(x = "Type", y = "Count")
  })
  
  
  output$recent <- renderDataTable({
    
    shiny::validate(need(!is.null(movies()), message = FALSE))
    
    movies() %>% 
      mutate(Poster = str_c("<img src='", Poster, "' height=150 width=100>"))
    
  }, escape = FALSE)
  
  output$download <- downloadHandler(
    filename = paste0(input$term, "_movies.csv"),
    content = function(file) write_csv(movies(), path = file)
  )

}

# Run the application 
shinyApp(ui = ui, server = server)
