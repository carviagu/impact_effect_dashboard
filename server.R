
# Server (backend)

# Preparing time series examples

set.seed(1)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
y[71:85] <- y[71:85] + 10
time.points <- seq.Date(as.Date("2014-01-01"), by = 1, length.out = 100)
marketing <- zoo(cbind(y, x1), time.points)

# Server functionality

shinyServer(
  function(input, output, session) {
    
    # Welcome button functionality
    observeEvent(input$goToSim, {
      updateNavbarPage(session = session, inputId = "nav", selected = "Simulator")
    })
    observeEvent(input$goToAb, {
      updateNavbarPage(session = session, inputId = "nav", selected = "About")
    })
    
    storage <- reactiveValues()
    
    # Event start date selection
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
    
    # Event start date selection (onclick)
    observeEvent(input$onClick, {
      # Save the date selected
      to_date <- as.Date(round(input$onClick$x))
      
      # Re render the date picker with the selected date
      # This will launch reactive process to update charts
      output$datePlace <- renderUI({
        dateInput(
          inputId = 'selDate',
          label = h4('Event Date'),
          value = to_date
        )
      })
    })
  
    # Causal Impact Computation
    causal <- reactive({
      # To avoid any error during render
      req(input$selDate, input$numDays, input$maxNum, input$minNum)
      
      start_date <- as.Date(input$selDate)
      
      # Pre period of impact
      # Checking date is not earlier than series start point
      if (storage$first >= start_date) {
        showNotification("Invalid Start Date: Start date is earlier than time series end date!",
                         type = 'error', duration=100)
        return('Error: Invalid Start Date')
        # Checking date is not later than series end point
      } else if (storage$last <= start_date) {
        showNotification("Invalid Start Date: Start date is later than time series end date!",
                         type = 'error', duration=100)
        return('Error: Invalid Start Date')
      }

      # Pre period: Time-Series start date and event start date-1
      storage$eventStart <- start_date 
      pre.period <- c(storage$first, start_date-1)
      
      # Post period of impact
      if (input$selEnd == 0) {
        end_date <- start_date+input$numDays
      } else {
        # When the end condition is series value
        # Find the date (index) where the limit is found
        ind <- match(start_date,index(storage$df))
        if (input$selEnd == 1) {
          end_date <- index(storage$df[ind:length(index(storage$df))])[storage$df[ind:length(index(storage$df))] >= input$maxNum][1]
        } else {
          end_date <- index(storage$df[ind:length(index(storage$df))])[storage$df[ind:length(index(storage$df))] <= input$minNum][1]
        }
        
        # If date limit not found, we evaluate the whole series
        if (is.na(end_date)) {
          end_date <- storage$last
          showNotification("Limit not found, impact will be analized until series end",
                           type = 'warning', duration=5)
        } 
      }
      
      # Checking End date is not later than time series end date
      if (storage$last < end_date) {
        showNotification("Invalid End Date: End date is later than time series end date!",
                         type = 'error', duration=100)
        return('Error: Invalid End Date')
      }
      
      # Post period: Start date and 
      storage$eventEnd <- end_date
      post.period <- c(start_date, end_date)
      
      # Calculation of impact
      storage$impact <- CausalImpact(storage$df, pre.period, post.period)
    })
    
    
    output$mainPlot <- renderPlot({
      # Evaluating impact
      causal()

      # Plotting impact results
      ggplot(storage$impact$series, aes(x=Index)) +
        geom_ribbon(aes(ymin=point.pred.lower, ymax=point.pred.upper), alpha=0.05, fill='red', colour='red') +
        geom_line(aes(y=response, color='Real'), show.legend = TRUE) +
        geom_line(aes(y=point.pred, color='Expected'), linetype='longdash', 
                  show.legend = TRUE) +
        geom_vline(xintercept = as.numeric(c(storage$eventStart, 
                                             storage$eventEnd)),
                   color='blue', linetype='twodash') +
        geom_label(aes(x=(storage$eventStart-2), y=min(response-2), label='Event Start'), 
                   fill='lightgrey', label.size=0, angle=90) +
        geom_label(aes(x=(storage$eventEnd-2), y=min(response-2), label='Event End', angle=90), 
                   fill='lightgrey', label.size = 0, angle=90) +
        labs(x = "Days", y = "Real / Expected Values") +
        ggtitle('Causal impact event analysis') +
        scale_color_manual(name = 'Legend', values = c("Real" = "black", "Expected" = "red")) +
        theme_light() +
        theme(plot.title=element_text(family='', face='bold', size='20'))
    
    })
    
    # TO DO
    output$totalImp <- renderText({
      causal()
      paste("Total impact: ", "PENDING")
    })
  
    output$startDay <- renderText({
      causal()
      paste("From: ", storage$eventStart)
    })
    
    output$endDay <- renderText({
      causal()
      paste("To: ", storage$eventEnd)
    })
    
    # TO DO
    output$daysRec <- renderText({
      causal()
      paste("Days until recovery: ", "PENDING")
    })
    
    output$subPlot <- renderPlot({
      # Evaluating impact
      causal()
      
      # TO DO
      ggplot(storage$impact$series, aes(x=Index)) +
        geom_line(aes(y=cum.effect), color='red', linetype='longdash', 
                  show.legend = TRUE) +
        geom_vline(xintercept = as.numeric(c(storage$eventStart, 
                                             storage$eventEnd)),
                   color='blue', linetype='twodash') +
        theme_light()
      
    })
    
  }
)
    