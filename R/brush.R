#'Returns a data frame with points marked which are under a brush
#'
#'This function returns all rows from the input data frame with an additional
#'column selected_, which indicates which rows of the input data frame are
#'selected by the brush (TRUE for selected, FALSE for not-selected).The xvar,
#'yvar arguments specify which columns in the data correspond to the x
#'variable, y variable of the plot. Based on ggbrush by Joe Cheng.
#'
#'@param plotExpr	A ggplot object.
#'@param allRows	If FALSE (the default) return a data frame containing the
#'  selected rows. If TRUE, the input data frame will have a new column,
#'  selected_, which indicates whether the row was inside the brush (TRUE) or
#'  outside the brush (FALSE).
#'
#'@return A data frame
#'
#'@examples
#'library(lubridate)
#'library(ggplot2)
#'
#'# Example dataset
#'dates = as.POSIXct(seq(from = ymd("2013-01-01"),
#'  to = ymd("2014-01-01"), by = 3 * 3600))
#'Data = data.frame(dates, value = sin(decimal_date(dates)/0.01) +
#'  rnorm(length(dates)))
#'
#'# Select points
#'p = qplot(data = Data, dates, value)
#'brushed(p)
#'
#'@export

brushed <- function(plotExpr, allRows = FALSE) {
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
    # Show the plot... that's important.
    output$plot <- renderPlot(plotExpr + coord_cartesian(xlim = ranges$xvar, ylim = ranges$yvar))

    observeEvent(input$plot_dblclick, {
      brushed <- input$plot_brush
      if (!is.null(brushed)) {
        Points <- brushedPoints(plotExpr$data, input$plot_brush)
        mapX <- as.character(plotExpr$mapping$x)
        mapY <- as.character(plotExpr$mapping$y)
        ranges$xvar <- range(Points[[mapX]])
        ranges$yvar <- range(Points[[mapY]])
          }
      else {
        ranges$xvar <- NULL
        ranges$yvar <- NULL
      }
    })

    observeEvent(input$done, {
      stopApp(brushedPoints(plotExpr$data, input$plot_brush, allRows = allRows))
    })
  }

  shiny::runGadget(ui, server)
}
