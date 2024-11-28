library(shiny)
library(leaflet)
library(sf)
library(dplyr)

getwd()

points_data <- st_read('C:\\Users\\miiin\\Downloads\\Week07_shiny\\Week07_shiny\\cbsa_points.shp')
tf_data <- st_transform(points_data, crs = '+proj=longlat +datum=WGS84')

ui <- fluidPage(
  titlePanel('Housing Mortgage Map'),
  sidebarLayout(
    sidebarPanel(
      sliderInput(inputId = 'mortgagerange',
                  label = 'Mortgage Range',
                  min = 0,
                  max = max(tf_data$Mortgage, na.rm = TRUE),
                  value = c(0, max(tf_data$Mortgage, na.rm = TRUE))),
      selectizeInput(inputId = 'stateFilter',
                     label = 'Select State',
                     choices = unique(tf_data$State),
                     selected = unique(tf_data$State)[1],
                     multiple = TRUE),
      radioButtons(inputId = 'displayOption',
                   label = 'Display Options',
                   choices = list('All' = 'all', 'Filter' = 'filter'),
                   selected = 'filter')
    ),
    mainPanel(
      leafletOutput(outputId = 'map', width = '100%', height = '500px')
    )
  )
)

server <- function(input, output) {
  filtered_data <- reactive({
    if (input$displayOption == 'all') {
      tf_data
    } else {
      tf_data %>%
        filter(
          Mortgage >= input$mortgagerange[1],
          Mortgage <= input$mortgagerange[2],
          State %in% input$stateFilter
        )
    }
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = mean(st_coordinates(tf_data)[, 1]),
              lat = mean(st_coordinates(tf_data)[, 2]),
              zoom = 6)
  })
  
  observe({
    leafletProxy("map", data = filtered_data()) %>%
      clearMarkers() %>%
      addCircleMarkers(
        radius = 5,
        color = "blue",
        label = ~paste("Mortgage:", Mortgage, "State:", State)
      )
  })
}

shinyApp(ui, server)


install.packages('rsconnect')
rsconnect::setAccountInfo(name='miinakova',
                          token='9E399591AAB21620ACA0CB73A1AE040A',
                          secret='6rlAs7bnFmFIlT69dBcts/VSuwR2SOPW0xGS5EDn')
library(rsconnect)
rsconnect::deployApp('C:/Users/miiin/Downloads/Week07_shiny/Week07_shiny')
