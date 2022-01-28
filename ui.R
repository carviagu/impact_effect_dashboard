library(shiny) # librería de shiny
library(CausalImpact) # librería Cuasal Impact
library(ggplot2)
library(dplyr)

# interfaz grafica (frontend)
shinyUI(
  fluidPage(
    
    # Title of the app
    titlePanel("Impact Effect Dashboard"),
    
    # Main panel
    sidebarLayout(
    
      # Options section
      sidebarPanel(
        p("Select an example dataset and stablish the start and end conditions of the impact, to
          see Causal Impact in action:"),
        
        selectInput(
          inputId = "selData",
          label = h4('Dataset'),
          choices = list(
            "weather" = "weather",
            "storms" = "storms",
            "delay" = "delay"
          ),
          selected = "weather"
        ),
        
        dateInput(
          inputId = "selDate",
          label = h4('Start Date'),
          value = "2022-01-28"
        ),
        
        br(),
        h4("End condition"),
        
        selectInput(
          inputId = "selEnd",
          label = 'Criteria',
          choices = list(
            "Fixed Interval" = 0,
            "Maximum" = 1,
            "Minimum" = 2
          ),
          selected = "Fixed Interval"
        ),
        
        conditionalPanel(
          condition = "input.selEnd == 0",
          numericInput(
            inputId = "num",
            label = 'Days',
            value = 1
          )
        ),
        
        conditionalPanel(
          condition = "input.selEnd == 1",
          numericInput(
            inputId = "num",
            label = 'Upper limit',
            value = 100
          )
        ),
        
        conditionalPanel(
          condition = "input.selEnd == 2",
          numericInput(
            inputId = "num",
            label = 'Lower limit',
            value = -100
          )
        )
        
      ),
      
      # Plots area
      mainPanel(
        
      )
      
    )
    
  )
) # UI

