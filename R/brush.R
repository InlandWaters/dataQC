

brush <- function(data, xvar, yvar) {

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Drag to select points"),
    miniUI::miniContentPanel(
      # The brush="brush" argument means we can listen for
      # brush events on the plot using input$brush.
      shiny::plotOutput("plot", height = "100%", brush = "plot_brush", dblclick = "plot_dblclick")
    )
  )

  server <- function(input, output, session) {

    ranges <- shiny::reactiveValues(x = NULL, y = NULL)

    # Render the plot
    output$plot <- renderPlot({
      # Plot the data with x/y vars indicated by the caller.
      ggplot2::ggplot(data, aes_string(xvar, yvar)) + geom_point() +
        coord_cartesian(xlim = ranges$xvar, ylim = ranges$yvar) + theme_minimal()
    })

    observeEvent(input$plot_dblclick, {
      brushed <- input$plot_brush
      if (!is.null(brushed)) {
        if (TRUE %in%  sapply(data , is.POSIXct)) {
          ranges$xvar <- as.POSIXct(c(brushed$xmin, brushed$xmax), origin = "1970-01-01")
        }
        else {
          ranges$xvar <- c(brushed$xmin, brushed$xmax)
        }
        ranges$yvar <- c(brushed$ymin, brushed$ymax)
      }
      else {
        ranges$xvar <- NULL
        ranges$yvar <- NULL
      }
    })

    # Handle the Done button being pressed.
    observeEvent(input$done, {
      # Return the brushed points. See ?shiny::brushedPoints.
      stopApp(brushedPoints(data, input$plot_brush, allRows = TRUE))
    })
  }

  shiny::runGadget(ui, server)
}
