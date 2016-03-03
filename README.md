# dataQC

```R
# install.packages("devtools")
devtools::install_github("D-ESC/dataQC")
```

Some simple and hopefully robust ways to deal with detecting and possibly removing errors and inconsistencies from data.

```R
library(lubridate)
library(dplyr)

dates = as.POSIXct(seq(from = ymd("2013-01-01"), to = ymd("2014-01-01"), by = 3 * 3600))
Data = data.frame(dates, value = sin(decimal_date(dates)/0.01) + rnorm(length(dates)))
```

Interact with data by zooming in on certain regions of a scatterplot and highlighting values to be returned to the console. 

```R
library(dataQC)
Data = brushed(Data, "dates", "value")
```

This returns the original object with an additional column 'selected_' that can be used to flag or update values.

```R
Data = Data %>% 
  mutate(value = ifelse(selected_ == TRUE, NA, .)) %>%
  mutate(flag = ifelse(selected_ == TRUE, 'missing', .))
```
## impossible values

Errors from a malfunctioning instrument can be filtered out.

```R
Data %>% 
  filter(value < 3 & value > -3)
```

## “potential outliers”

boxplot.stats can list the 'outliers'.

```R
Data %>% 
  filter(value %in% boxplot.stats(value)$out)
```

Factor that defines whisker can be changed.

```{r}
Data %>% 
  filter(value %in% boxplot.stats(value, coef = 1)$out)
```

adjboxStats computes the “statistics” for producing boxplots adjusted for skewed distributions.

```{r}
library(robustbase)
Data %>% 
  filter(value %in% adjboxStats(value)$out)
```

Scaling factors can be set to change outlier boundaries.

```R
Data %>% 
  filter(value %in% adjboxStats(value, a=-1,b=5)$out)
```

Any of the above can be calculated in groups such as year or month.

```R
Data %>% 
  group_by(month(dates)) %>% 
  filter(value %in% boxplot.stats(value)$out)
```

And we can set these values to NA.

```R
Data %>% 
  group_by(month(dates)) %>% 
  mutate(value = ifelse(value %in% boxplot.stats(value)$out, NA, .))
```


