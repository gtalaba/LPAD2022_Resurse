################################################################################
###                Setup                                                     ###
################################################################################
## Clear everything
rm(list = ls())


###  Pachete si librarii
#install.packages('tidyverse')
#install.packages('lubridate')

library(tidyverse)
library(lubridate)



setwd('e:/###FEAA/2023')
getwd()


load('covid_2022-09-25.RData')

glimpse(covid_data)
glimpse(country__other_data)
glimpse(country__pop_coord)
glimpse(country_gen_info)

################################################################################
###               Functii ranking                                            ###
################################################################################


x <- c(1, 1, 2, 2, 2, 7, 134, 134)

x
row_number(x)

x
min_rank(x)

x
dense_rank(x)

x
lag(x)

x
lead(x)

### Cele mai puternice 5 masini
glimpse(mtcars)
mtcars

mtcars %>% 
  filter(between(row_number(desc(hp)), 1, 5)) %>%
  transmute(hp, rank=row_number(desc(hp))) %>%
  arrange(desc(hp))


mtcars %>% 
  filter(between(dense_rank(desc(hp)), 1, 5)) %>%
  transmute(hp, rank=row_number(desc(hp)), dense_r=dense_rank(desc(hp))) %>%
  arrange(desc(hp))

################################################################################
###               Interogarii medii dplyr                                    ###
################################################################################


covid_new <- covid_data %>%
  arrange(country_code, report_date) %>%
  group_by(country_code) %>%
  mutate (
    tests_new = coalesce(tests,0) - coalesce(lag(tests, 1), 0),
    confirmed_new = coalesce(confirmed,0) - coalesce(lag(confirmed, 1), 0),
    recovered_new = coalesce(recovered,0) - coalesce(lag(recovered, 1), 0),
    deaths_new = coalesce(deaths,0) - coalesce(lag(deaths, 1), 0)
  ) %>%
  ungroup()

covid_new %>%
 arrange(desc(report_date)) %>%
 filter(country_code == 'ROU') %>%
 select(country_code,report_date:deaths,tests_new:deaths_new)  

#I1. populatia fiecare regiuni geografice

#select region,
#sum(population)
#from country_gen_info 
#inner join country__pop_coord on country_code=country_code3
#group by region;

### De facut ca exemplu

#I2 tara cu cea mai mare populatie

#select country_name,
#population
#from country_gen_info 
#inner join country__pop_coord on country_code=country_code3
#order by 2 desc
#limit 1;

### De facut ca exemplu

#I3. tara cu cel mai mare procent de varstnici
### individual
#I4. tara cu cel mai mare procent de barbati fumatori
### individual


#I8. Top 3 tari cu cea mai mare populatie

#select  country_name,
#population
#from country__pop_coord
#inner join country_gen_info on country_code=country_code3
#order by 2 desc
#limit 3;


### De facut ca exemplu



#I9. Nr de tari din regiunea East Asia and Pacific cu "Low Income"

#https://dplyr.tidyverse.org/reference/count.html
glimpse(country_gen_info)

### De facut ca exemplu

#I10. Top 3 regiuni cu cea mai mare populatie batrana
### individual



# III.2 TOP 3 zile cu cele mai multe noi cazuri in Romania
### individual

# III.3 Ziua cu cele mai multe noi decese in Romania

### De facut ca exemplu


# III.4 TOP 3 zile cu cele mai multe noi decese in Romania
### individual

# III.5 Ziua cu cele mai multe noi confirmati in Romania
### individual
# III.6 TOP 3 zile cu cele mai multe cazuri in Romania
### individual




# III.7 Tara cu cea mai mare rata zilnica de imbolnaviri (raportat la total populatie)

# solutia 1:

### De facut ca exemplu

# solutia 2:


### De facut ca exemplu


# III.8 TOP 3 tari cu cea mai mare rata de imbolnaviri (raportat la total populatie)

#https://dplyr.tidyverse.org/reference/slice.html?q=slice%20_%20max#methods
#https://www.datasciencemadesimple.com/get-first-n-rows-last-n-rows-head-and-tail-function-in-r/
# solutia 1:

### De facut ca exemplu

# solutia 2:
### De facut ca exemplu

# III.13 Tara si data cu cele mai multe noi cazuri
### individual

################################################################################
###               Tehnici de join                                            ###
################################################################################



#### Tara cu cei mai multi confirmati

# Varianta cunoscuta

covid_new %>%
  inner_join(country_gen_info) %>%
  select(country_name, confirmed,report_date) %>%
  slice_max(confirmed)

# Join cu subquery

country_gen_info %>%
  inner_join(
    covid_new %>%
      slice_max(confirmed)
  ) %>%
  select(country_name, confirmed,report_date)

# Join cu rezultatul unui subquery
country_gen_info %>%
  inner_join(covid_new) %>%
  filter(confirmed == (
    covid_new %>%
      slice_max(confirmed) %>%
      pull(confirmed)
  )
  )%>%
  select(country_name, confirmed,report_date)


##################################################################
# I.7 zona geografica cea mai populata


# solutie 1 - folosind functia `max`

### De facut ca exemplu

# solutie 2 - folosind jonctiunea cu un soi de subconsultare

### De facut ca exemplu

# solutie 3 - folosind un soi de subconsultare
### De facut ca exemplu
