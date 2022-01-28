
# Carga de datos
library(tseries)
cotizaciones <- get.hist.quote(instrument="san.mc", start= as.Date("2015-09-01"),
                               end= as.Date("2017-03-01"), quote="AdjClose",
                               provider="yahoo",
                               compression="d", retclass="zoo")


# Servidor (backend)
shinyServer(
  function(input, output, session) {
    
    # Welcome button functionality
    observeEvent(input$goToSim, {
      updateNavbarPage(session = session, inputId = "nav", selected = "Simulator")
    })
    
    # Output
    
    output$mainPlot <- renderPlot({
      #pre.period <- input$selDate
      #post.val <- input$num
    
    })
    
  }
)
    