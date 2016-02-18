#'Returns a data frame with points marked which are under a brush
#'
#'This function returns all rows from the input data frame with an additional
#'column selected_, which indicates which rows of the input data frame are
#'selected by the brush (TRUE for selected, FALSE for not-selected).The xvar,
#'yvar arguments specify which columns in the data correspond to the x
#'variable, y variable of the plot. Based on ggbrush by Joe Cheng.
#'
#'@param df	A data frame from which to select rows.
#'@param xvar, yvar	A string with the name of the variable on the x or y axis.
#'
#'@return A data frame
#'
#'@examples
#'library(lubridate)
#'
#'# Example dataset
#'dates = as.POSIXct(seq(from = ymd("2013-01-01"),
#'  to = ymd("2014-01-01"), by = 3 * 3600))
#'Data = data.frame(dates, value = sin(decimal_date(dates)/0.01) +
#'  rnorm(length(dates)))
#'
#'# Select points
#'brushed(Data, "dates", "value")
#'
#'@export

brushed <- function(df, xvar, yvar) {
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Drag to select points"),
    miniUI::miniContentPanel(
      shiny::plotOutput(
        "plot",
        height = "100%",
        brush = "plot_brush",
        dblclick = "plot_dblclick"
      )
    )
  )

  server <- function(input, output, session) {
    ranges <- shiny::reactiveValues(x = NULL, y = NULL)
    output$plot <- renderPlot({
      ggplot2::ggplot(df, ggplot2::aes_string(xvar, yvar)) +
        ggplot2::geom_point() +
        ggplot2::coord_cartesian(xlim = ranges$xvar, ylim = ranges$yvar) +
        ggplot2::theme_minimal()
    })

    observeEvent(input$plot_dblclick, {
      brushed <- input$plot_brush
      if (!is.null(brushed)) {
        if (TRUE %in%  sapply(df , lubridate::is.POSIXct)) {
          ranges$xvar <-
            as.POSIXct(c(brushed$xmin, brushed$xmax), origin = "1970-01-01")
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

    observeEvent(input$done, {
      stopApp(brushedPoints(df, input$plot_brush, allRows = TRUE))
    })
  }

  shiny::runGadget(ui, server)
}
