#'Edit and flag data
#'
#'The function editData can be used to edit and flag data. A subset of values
#'can be targeted and worked on.
#'
#'The function supplied (FUN) will be applied across the values defined by the
#'date range given to the Subset argument. The full data set will be returned
#'with the edits applied and values flagged.
#'
#'@param df dataframe
#'@param Subset subset	of values to apply edit
#'@param col.name name of the column to edit
#'@param flag flag to apply to edited data record
#'@param FUN the function to be applied
#'
#'@examples
#'
#'library(dplyr)
#'library(lubridate)
#'
#'# Example dataset
#'dates = as.POSIXct(seq(from = ymd("2013-01-01"),
#'  to = ymd("2014-01-01"), by = 3 * 3600))
#'Data = data.frame(dates, value = sin(decimal_date(dates)/0.01) +
#'  rnorm(length(dates)))
#'
#'# set flag
#'Data = editData(Data, col.name = "value", flag = "missing")
#'# set a constant value
#'Data = editData(Data, col.name = "value", FUN = function (x) 5)
#'# apply offset
#'Data = editData(Data, col.name = "value", FUN = function (x) x + 5)
#'# subset data
#'Data = editData(Data, col.name = "value", between(Data$dates,
#'  ymd("2013-01-01"), ymd("2013-02-02")),
#'  FUN = function (x) x + -5,
#'  flag = "offset -5")
#'
#'@export

editData <- function(df, Subset = 1:nrow(Data), col.name = "DataValue",
  flag = "", FUN = function(x) x, ...)
{
  df[Subset, col.name] <- FUN(df[Subset, col.name], ...)
  df[Subset, "QualifierID"] <- flag
  return(df)
}
