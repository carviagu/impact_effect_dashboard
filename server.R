
# Server (backend)

# Preparing time series examples

#-------------------------------------------------------------------------------
# Views
#-------------------------------------------------------------------------------
views <- read.csv("data/views.csv", sep=",")
time.points <- seq.Date(as.Date("2014-01-01"), by = 1, length.out = 100)
views <- zoo(cbind(views$y, views$x1), time.points)


#-------------------------------------------------------------------------------
# BTS
#-------------------------------------------------------------------------------
BTS <- read.csv("data/spotify_bts.csv", sep=",")
time.points_malone <- seq.Date(as.Date("2021-01-01"), by = 1, length.out = 334)
BTS <- zoo(BTS$streams, time.points_malone)

#-------------------------------------------------------------------------------
# Olivia
#-------------------------------------------------------------------------------
olivia <- read.csv("data/spotify_olivia-rodrigo.csv", sep=",")
time.points_olivia <- seq.Date(as.Date("2021-01-02"), by = 1, length.out = 334)
olivia <- zoo(olivia$streams, time.points_olivia)

#-------------------------------------------------------------------------------
# Travis Scot
#-------------------------------------------------------------------------------
travis <- read.csv("data/spotify_travis-scott.csv", sep=",")
time.points_travis <- seq.Date(as.Date("2021-09-01"), by = 1, length.out = 91)
travis <- zoo(travis$streams, time.points_travis)

#-------------------------------------------------------------------------------
# Disney
#-------------------------------------------------------------------------------
Disney <- read.csv("data/disney.csv", sep=";")
time.points_disney <- seq.Date(as.Date("2018-10-01"), by = 1, length.out = 167)
Disney <- zoo(Disney$price, time.points_disney)



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
    observeEvent(input$selData, {
      storage$df <- switch(input$selData,
                           "views" = views, 
                           "BTS" = BTS,
                           "olivia rodriguez" = olivia, 
                           "Travis Scott" = travis,
                           "disney" = Disney)
      
      # Saving start and end dates of the time-series
      storage$first <- as.Date(index(storage$df)[1])
      storage$last <- as.Date(index(storage$df)[length(index(storage$df))])
      
      # Reset start date to time series interval
      storage$temp <- as.Date(index(storage$df)[round(length(index(storage$df))/2)])
    })
    
    # Event start date selection (onclick)
    observeEvent(input$onClick, {
      # Save the date selected
      storage$temp <- as.Date(round(input$onClick$x))
    })
    
    # Re render the date picker with the selected date
    # This will launch reactive process to update charts
    output$datePlace <- renderUI({
      req(storage$temp)
      dateInput(
        inputId = 'selDate',
        label = h4('Event Date'),
        value = storage$temp
      )
    })
    
    # Causal Impact Computation
    causal <- reactive({
      # To avoid any error during render
      req(input$selDate, input$numDays, input$maxNum, input$minNum)
      
      # In this code we use isolate with all the values that are calculated 
      # at the beginning of the data set change process: storage values. 
      # This is to avoid premature execution and return false errors. 
      
      start_date <- as.Date(input$selDate)
      
      # Pre period of impact
      # Checking date is not earlier than series start point
      if (isolate(storage$first) >= start_date) {
        showNotification("Invalid Start Date: Start date is earlier than time series end date!",
                         type = 'error', duration=100)
        return('Error: Invalid Start Date')
        # Checking date is not later than series end point
      } else if (isolate(storage$last) <= start_date) {
        showNotification("Invalid Start Date: Start date is later than time series end date!",
                         type = 'error', duration=100)
        return('Error: Invalid Start Date')
      }

      # Pre period: Time-Series start date and event start date-1
      storage$eventStart <- start_date 
      pre.period <- c(isolate(storage$first), start_date-1)
      
      # Post period of impact
      if (input$selEnd == 0) {
        end_date <- start_date+input$numDays
      } else {
        # When the end condition is series value
        # Find the date (index) where the limit is found
        ind <- match(start_date,index(isolate(storage$df)))
        if (input$selEnd == 1) {
          end_date <- index(isolate(storage$df)[ind:length(index(isolate(storage$df)))])[isolate(storage$df)[ind:length(index(isolate(storage$df)))] >= input$maxNum][1]
        } else {
          end_date <- index(isolate(storage$df)[ind:length(index(isolate(storage$df)))])[isolate(storage$df)[ind:length(index(isolate(storage$df)))] <= input$minNum][1]
        }
        
        # If date limit not found, we evaluate the whole series
        if (is.na(end_date)) {
          end_date <- isolate(storage$last)
          showNotification("Limit not found, impact will be analized until series end",
                           type = 'warning', duration=5)
        } 
      }
      
      # Checking End date is not later than time series end date
      if (isolate(storage$last) < end_date) {
        showNotification("Invalid End Date: End date is later than time series end date!",
                         type = 'error', duration=100)
        return('Error: Invalid End Date')
      }
      
      # Post period: Start date and 
      storage$eventEnd <- end_date
      post.period <- c(start_date, end_date)
      
      # Calculation of impact
      storage$impact <- CausalImpact(isolate(storage$df), pre.period, post.period)
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
        geom_label(aes(x=(storage$eventStart-2), y=(max(response)-2), label='Event Start'), 
                   fill='lightgrey', label.size=0, angle=90) +
        geom_label(aes(x=(storage$eventEnd-2), y=(max(response)-2), label='Event End', angle=90), 
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
      paste("Total impact: ", round(storage$impact$series$cum.effect[storage$eventEnd],2))
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
      
      
        
      recovery <- "no recovery"
      final_value <- storage$impact$series$response[storage$eventEnd]
      
      if(final_value < storage$impact$series$point.pred.upper[storage$eventEnd] 
         & final_value > storage$impact$series$point.pred.lower[storage$eventEnd]){
        
        recoverday <- as.data.frame(storage$impact$series) %>%
          select(response, point.pred.lower, point.pred.upper) %>% 
          slice(which(index(storage$impact$series) == as.character.Date(storage$eventStart)) : which(index(storage$impact$series) == as.character.Date(storage$eventEnd))) %>% 
          mutate(out = if_else((response < point.pred.lower | response > point.pred.upper),1,0)) %>% 
          select(out) %>% 
          arrange(-row_number()) 
      
        recovery <-   if_else(max(recoverday) == 0, 
                              "no recover", 
                              as.character(-1* as.numeric(
                                storage$eventStart - as.Date(rownames(recoverday)[which(recoverday == 1)[1]]), units = "days")))
        
        print(recoverday)
     
      }
      
      paste("Days until recovery: ", recovery)
    })
    
    output$subPlot <- renderPlot({
      # Evaluating impact
      causal()
      
      plt <- ggplot(storage$impact$series, aes(x=Index))
      
      lgnd <- c()
      
      if (input$showAcum) {
        plt <- plt + 
          geom_ribbon(aes(ymin=cum.effect.lower, ymax=cum.effect.upper), alpha=0.05, fill='purple', colour='purple') +
          geom_line(aes(y=cum.effect,  color='Acumulated'), linetype='longdash', 
                        show.legend = TRUE)
        lgnd <- c(lgnd, "Acumulated" = "purple")
      }
      
      if (input$showPunc) {
        plt <- plt + 
          geom_ribbon(aes(ymin=point.effect.lower, ymax=point.effect.upper), alpha=0.05, fill='darkgreen', colour='darkgreen') +
          geom_line(aes(y=point.effect, color='Pointwise'), linetype='dotted', 
                        show.legend = TRUE)
        lgnd <- c(lgnd, "Pointwise" = "darkgreen")
      }
      
      if (length(lgnd) == 0) {
        plt <- plt + geom_text(aes(x=as.Date(index(storage$df)[round(length(index(storage$df))/2)]), 
                            y=0, label="Select the chart(s) to be desplayed"), size=6)
      } else {
         plt <- plt +
          geom_vline(xintercept = as.numeric(c(storage$eventStart, 
                                             storage$eventEnd)),
                   color='blue', linetype='twodash') +
          geom_label(aes(x=(storage$eventStart-2), y=max(storage$impact$series$cum.effect.upper), label='Event Start'), 
                     fill='lightgrey', label.size=0, angle=90) +
          geom_label(aes(x=(storage$eventEnd-2), y=max(storage$impact$series$cum.effect.upper), label='Event End', angle=90), 
                     fill='lightgrey', label.size = 0, angle=90)
      }
      
      plt +
        labs(x = "Days", y = "Impact Effect") +
        ggtitle('Impact effect analysis') +
        scale_color_manual(name = 'Legend', values = lgnd) +
        theme_light() +
        theme(plot.title=element_text(family='', face='bold', size='20'))
    })
    
  }
)
    