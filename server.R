
# Server (backend)

# Preparing time series examples

set.seed(1)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
y[71:85] <- y[71:85] + 10
time.points <- seq.Date(as.Date("2014-01-01"), by = 1, length.out = 100)
marketing <- zoo(cbind(y, x1), time.points)


shinyServer(
  function(input, output, session) {
    
    # Welcome button functionality
    observeEvent(input$goToSim, {
      updateNavbarPage(session = session, inputId = "nav", selected = "Simulator")
    })
    
    storage <- reactiveValues(first = "", last = "")
    
    # Dataset selection
    output$datePlace <- renderUI({
      storage$df <- switch(input$selData,
                           "example" = marketing)
      
      # Saving start and end dates of the time-series
      storage$first <- as.Date(index(storage$df)[1])
      storage$last <- as.Date(index(storage$df)[length(index(storage$df))])
      
      # Reset start date to time series interval
      dateInput(
        inputId = 'selDate',
        label = h4('Event Date'),
        value = as.Date(index(storage$df)[round(length(index(storage$df))/2)])
      )
    })
    
  
    # Causal Impact Computation
    causal <- reactive({
      # To avoid any error during render
      req(input$selDate)
      
      start_date <- as.Date(input$selDate)
      
      # Pre period of impact
      # Checking date is not earlier than series start point
      if (storage$first >= start_date) {
        showNotification(paste(strong("Invalid Start Date: "),
                               "Start date is earlier than time series end date!"),
                         type = 'error', duration=100)
        return('Error: Invalid Start Date')
        # Checking date is not later than series end point
      } else if (storage$last <= start_date) {
        showNotification(paste(strong("Invalid Start Date: "),
                               "Start date is later than time series end date!"),
                         type = 'error', duration=100)
        return('Error: Invalid Start Date')
      }

      # Pre period: Time-Series start date and event start date-1
      pre.period <- c(storage$first, start_date-1)
      post.period <- c(start_date, storage$last)
      
      
      storage$impact <- CausalImpact(storage$df, pre.period, post.period)
    })
    
    
    output$mainPlot <- renderPlot({
      causal()
      
      plot(storage$impact, c('original'))
    
    })
    
    
    output$subPlot <- renderPlot({
      causal()
      
      plot(storage$impact, c('pointwise'))
      
    })
    
  }
)
    