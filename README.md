# dataQC

```R
# install.packages("devtools")
devtools::install_github("D-ESC/dataQC")
```

Some simple and hopefully robust ways to deal with detecting and possibly removing errors and inconsistencies from data.

```R
library(lubridate)
library(dplyr)

dates = as.POSIXct(seq(from = ymd("2013-01-01"), to = ymd("2014-01-01"), 
  by = 3 * 3600))
Data = data.frame(dates, value = sin(decimal_date(dates)/0.01) +
  rnorm(length(dates)))
```

Interact ggplot objects and data by zooming in on certain regions of a scatterplot and highlighting values to be returned to the console. 

```R
library(ggplot2)
library(dataQC)
p = ggplot(data = Data, aes(dates, value)) + geom_point()
Data = brushed(p, allRows = TRUE)
```

This returns the original object with an additional column 'selected_' that can be used to flag or update values.

```R
Data = Data %>% 
  mutate(value = ifelse(selected_ == TRUE, NA, value)) %>%
  mutate(flag = ifelse(selected_ == TRUE, 'missing', flag))
```
## data corrections

Errors from a malfunctioning instrument can be filtered out.

```R
Data %>% 
  filter(value < 3 & value > -3)
```

Adding a constant value useful for adjusting all or portions of a data series where an incorrect offset was used.

```R
Data %>% 
  mutate(value = ifelse(
    between(dates, ymd("2013-12-01"), ymd("2013-12-31")),  
    value + 4,
    value
    ))
```

You can also write it as:

```R
Data %>% 
  mutate(value = value +
    between(dates, ymd("2013-12-01"), ymd("2013-12-31")) * 4)
```

Or:

```R
Data %>% 
  mutate(value = replace(value,
    between(dates, ymd("2013-12-01"), ymd("2013-12-31")), 
    value + 4))
```

Applying a linear drift correction useful in adjusting a data series that were measured using a sensor that may drift over time.

```R
Data %>% 
  mutate(x = between(dates, ymd("2013-12-01"), ymd("2013-12-31"))) %>%
  mutate(value = 5 / sum(x) * cumsum(x) * x + value) %>%
  select(-x)
```

## “potential outliers”

from Ron Pearson (http://www.r-bloggers.com/finding-outliers-in-numerical-data/)

Detection of outliers in a sequence of numbers can be approached as a mathematical problem, but the interpretation of these data observations cannot. The terms “outlier” and “bad data” are not synonymous. In a single sequence of numbers, the typical approach to outlier detection is to first determine upper and lower limits on the nominal range of data variation, and then declare any point falling outside this range to be an outlier.

The “three-sigma edit rule,” well known but unreliable.

```{r}
Data %>% 
  filter(value > 3 * sd(value) + mean(value) | 
         value < 3 * -sd(value) + mean(value))
```

The Hampel identifier, a more reliable procedure based on the median and the MAD scale estimate.

```
Data %>% 
  filter(value > 3 * mad(value) + median(value) | 
         value < 3 * -mad(value) + median(value))
```

The standard boxplot rule, based on the upper and lower quartiles of the data distribution. boxplot.stats can list the 'outliers' (points outside +/-1.58 IQR/sqrt(n)). The coefficient that defines the outliers can be changed.

```{r}
Data %>% 
  filter(value %in% boxplot.stats(value, coef = 1)$out)
```

An adjusted boxplot rule, based on the upper and lower quartiles, along with a robust skewness estimator called the medcouple. adjboxStats computes the “statistics” for producing boxplots adjusted for skewed distributions. Scaling factors can be set to change outlier boundaries.

```R
library(robustbase)
Data %>% 
  filter(value %in% adjboxStats(value, a = -1, b = 5)$out)
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
  mutate(value = ifelse(value %in% boxplot.stats(value)$out, NA, value))
```

## NA Handling

Four methods for dealing with NAs (missing observations) can be found in the zoo package: na.contiguous, na.approx and na.locf. Also, na.omit returns an object with incomplete observations removed; na.contiguous extracts the longest consecutive stretch of non-missing values.

Missing values (NAs) can be replaced by linear interpolation via na.approx or cubic spline interpolation via na.spline, respectively. “maxgap” can be used to set the maximum number of consecutive NAs to fill for na.approx. Any longer gaps will be left unchanged.

Generic function for replacing each NA with the most recent non-NA prior to it.

```R
library(zoo)
Data %>% 
  mutate(value = na.locf(value, maxgap = 6))
```
Generic function for replacing each NA with aggregated values. This allows imputing by the overall mean, by monthly means, etc.

```R
Data %>% 
  mutate(value = na.aggregate(value, by = month(dates), 
    FUN = mean, maxgap = 6))
```

Missing values (NAs) are replaced by linear interpolation via approx.

```R
Data %>% mutate(value = na.approx(value, maxgap = 6))
```
