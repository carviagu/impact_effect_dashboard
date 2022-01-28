library(shiny) # librería de shiny
library(CausalImpact) # librería Cuasal Impact
library(ggplot2)
library(dplyr)

# interfaz grafica (frontend)
shinyUI(
  
  # Navigation bar for the app
  navbarPage("Impact Effect Dashboard",
             id = "nav",
             
             # Welcome pane 
             tabPanel("Welcome", fluid = TRUE,
                      br(),
                      h1(strong("Welcome to the Impact Effect Dashboard!"), 
                         style = "font-size:50px;", align = "center"),
                      p("Discover more about Causal Impact and see how it works", 
                        style="font-size:25px;", align = "center"),
                      div(style="display:inline-block",
                          actionButton(inputId = "goToSim", label = "Start simulating", 
                                       style="color: #fff; background-color: #337ab7; border-color: #2e6da4, float:center"), 
                          style="float:center")
                      ),
             
             # Simulation pane
             tabPanel("Simulator", fluid = TRUE,
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
                   plotOutput(
                     outputId = 'mainPlot'
                   ),
                   
                   h4('More details:'),
                   
                   checkboxGroupInput(
                     inputId = 'inpuCheck',
                     labe = "",
                     choices = list(
                       "Accumulated impact" = 1,
                       "Punctual impact" = 2,
                       "Relative impact" = 3
                     ),
                     selected = 1
                   ),
                   
                   plotOutput(
                     outputId = 'subPlot'
                   )
                 )
                 
               )
        
      ),
      
      tabPanel("About"
        
      )
      
    )
   
    
) # UI

