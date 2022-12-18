################################################################################
###                Setup                                                     ###
################################################################################
## Clear everything
rm(list = ls())


###  Pachete si librarii
#install.packages('tidyverse')
#install.packages('lubridate')
#install.packages('htmlwidgets')
library(tidyverse)
library(lubridate)
library(htmlwidgets)


setwd('e:/###FEAA/2023')
getwd()
library(help = "datasets")
##https://github.com/lgellis/STEM/blob/master/DATA-ART-1/Data/FinalData.csv
##https://www.littlemissdata.com/blog/steam-data-art2

#data <- read_csv('https://raw.githubusercontent.com/lgellis/STEM/master/DATA-ART-1/Data/FinalData.csv', col_names = TRUE)

load("covid_2022-09-25.RData")


data <- country__other_data
################################################################################
###               EDA                                                        ###
################################################################################




#######################################################################
###	              EDA with `DataExplorer` package                      ###	
#######################################################################
#install.packages("DataExplorer")
library(DataExplorer)



## Basic information about data types and missing values

# ...as text...
temp <- DataExplorer::introduce(data)
View(temp)

# ... and as plot
plot_intro(temp)


## Missing values 
plot_missing(temp)




# Plot histogram for all numeric variables
DataExplorer::plot_histogram(data)


# Plot density curves for all numeric variables
DataExplorer::plot_density(data)

## Plot correlations among numeric variables
glimpse(data)
data %>%
  DataExplorer::plot_correlation()




#######################################################################
###	              EDA with `inspectdf` package                      ###	
#######################################################################
#install.packages("inspectdf")
library(inspectdf)


##  Display the data types as text...
temp <- inspectdf::inspect_types(data)
temp

#... and as chart
inspect_types(data) %>%
  show_plot ()


## Display the size of each column
inspect_mem(data) %>%
  show_plot ()


## Missing values 
inspect_na(data) %>%
  show_plot ()

glimpse(airquality)

inspect_na(airquality) %>%
  show_plot ()


#######################################################################
###	              EDA with `skimr/corrr` package                    ###	
#######################################################################

#install.packages("skimr")
#install.packages("corrr")
library(skimr)
library(corrr)

data %>%
  skimr::skim()





# the correlation plot
data %>%
  select_if(is.numeric) %>%
  corrr::correlate() %>%
  corrr::rplot()

help(mtcars)
mtcars %>%
  select_if(is.numeric) %>%
  corrr::correlate() %>%
  corrr::rplot()


#######################################################################
###	              EDA with `corrplot` package                       ###	
#######################################################################
#install.packages("corrplot")
library(corrplot)
#install.packages("corrgram")
library(corrgram)
# another series of correlation plot

corrplot::corrplot(cor(data %>% dplyr::  select_if(is.numeric) , 
                       method = "spearman"), method = "number", type = "upper")


corrplot::corrplot(cor(mtcars %>% dplyr::  select_if(is.numeric) , 
                       method = "spearman"), method = "number", type = "upper")


# the network plot
data %>%
  select_if(is.numeric) %>%
  corrr::correlate() %>%
  network_plot(min_cor = .2)
mtcars%>%
  select_if(is.numeric) %>%
  corrr::correlate() %>%
  network_plot(min_cor = .2)

#######################################################################
###	              EDA with `Corrrmorant` package                    ###	
#######################################################################

#### 
#install.packages("remotes")
#remotes::install_github("r-link/corrmorant")
library(corrmorant)
data %>% select_if(is.numeric) %>%
corrmorant( style = "binned") +
  theme_dark() +
  labs(title = "Correlations")


ggcorrm(data = data) +
  lotri(geom_point(alpha = 0.5)) +
  lotri(geom_smooth()) +
  utri_heatmap() +
  utri_corrtext() +
  dia_names(y_pos = 0.15, size = 3) +
  dia_histogram(lower = 0.3, fill = "grey80", color = 1) +
  scale_fill_corr() +
  labs(title = "Correlation Plot")

#######################################################################
###	              EDA with `PerformanceAnalytics` package           ###	
#######################################################################
#
#install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)
chart.Correlation(data %>% select_if(is.numeric), histogram=TRUE, pch="+")
chart.Correlation(mtcars %>% select_if(is.numeric), histogram=TRUE, pch="+")


#######################################################################
###	              EDA using ggpplot                                 ###	
#######################################################################
#

# prezicem numarul de morti pe baza celorlalti predictori
covid_data %>%
  filter(country_code == 'ROU') %>%
  select_if(is.numeric) %>%
  pivot_longer(-deaths, names_to = 'Predictor', values_to = "Value") %>%
  ggplot(., aes(x = Value, y = deaths)) +
  facet_wrap(~ Predictor, scale = "free_x") +
  geom_point() +
  geom_smooth(col = "darkgreen") +
  geom_smooth(method = "lm", col = "red") +
  theme_bw() +
  theme(strip.text.x = element_text(size = 12)) +
  xlab("")  


### Alegerea proiectelor
