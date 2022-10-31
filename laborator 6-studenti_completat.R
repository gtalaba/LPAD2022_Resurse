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

###############################################################################
##              Joins                                                        ##
###############################################################################

#https://statisticsglobe.com/r-dplyr-join-inner-left-right-full-semi-anti

glimpse(country_gen_info)
glimpse(covid_new)

covid_new  %>%
  inner_join(country_gen_info)  %>%
  count()

covid_new  %>%
  inner_join(country_gen_info, by = "country_code" )%>%
  count()

covid_new  %>%
  inner_join(country_gen_info, by = c("country_code"="country_code" ))%>%
  count()

country_gen_info  %>%
  inner_join(country_gen_info, by = c("country_code","region" ))%>%
  count()

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
#inner join country__pop_coord on country_code=country_code3 --- 
#group by region;
country__pop_coord  %>%
  inner_join(country_gen_info, by = c("country_code3"="country_code" )) %>%
  group_by(region) %>%
  summarise(total=sum(population)) %>%
  arrange(desc(total))



### De facut ca exemplu

#I2 tara cu cea mai mare populatie

#select country_name,
#population
#from country_gen_info 
#inner join country__pop_coord on country_code=country_code3
#order by 2 desc
#limit 1;
country__pop_coord  %>%
  inner_join(country_gen_info, by = c("country_code3"="country_code" )) %>%
  select(country_name,population) %>%
  arrange(desc(population)) %>%
  top_n(1)


### De facut ca exemplu

#I3. tara cu cel mai mare procent de varstnici
### individual
#I4. tara cu cel mai mare procent de barbati fumatori
### individual

country__other_data%>%
  inner_join(country_gen_info, by=c("country_code_iso3"="country_code"))%>%
  select(country_name, smoking_males)%>%
  arrange(desc(smoking_males))%>%
  top_n(1)



country__other_data%>%
  inner_join(country_gen_info, by=c("country_code_iso3"="country_code"))%>%
  select(country_name, pop_65)%>%
  arrange(desc(pop_65))%>%
  top_n(1)



#I8. Top 3 tari cu cea mai mare populatie

#select  country_name,
#population
#from country__pop_coord
#inner join country_gen_info on country_code=country_code3
#order by 2 desc
#limit 3;
country__pop_coord  %>%
  inner_join(country_gen_info, by = c("country_code3"="country_code" )) %>%
  select(country_name,population) %>%
  arrange(desc(population)) %>%
  top_n(3)



### De facut ca exemplu



#I9. Nr de tari din regiunea East Asia and Pacific cu "Low Income"

#https://dplyr.tidyverse.org/reference/count.html
glimpse(country_gen_info)


country_gen_info%>%
  filter(country_income_group=='Low income' & region == 'East Asia and  Pacific') %>%
  group_by(region) %>%
  count()

country_gen_info%>%
  filter(country_income_group=='Low income' & region == 'East Asia and  Pacific') %>%
  count(region)

country_gen_info%>%
  filter(country_income_group=='Low income') %>%
  group_by(region) %>%
  summarise(nr=n())

country_gen_info%>%
  filter(country_income_group=='Low income') %>%
  group_by(region) %>%
  tally()


covid_new %>%
  filter(country_code == 'ROU') %>%
  tally()

covid_new %>%
  filter(country_code == 'ROU') %>%
  tally(confirmed_new)

covid_new %>%
  filter(country_code == 'ROU' ) %>%
  summarise(max = max(confirmed, na.rm=T))


### De facut ca exemplu

#I10. Top 3 regiuni cu cea mai mare populatie batrana
### individual
rezultat <- country_gen_info %>%
  inner_join(country__other_data, by = c('country_code' = 'country_code_iso3')) %>%
  group_by(region) %>%
  summarise(region_population = sum(pop_65)) %>%
  arrange(desc(region_population)) %>%
  top_n(3)


# III.2 TOP 3 zile cu cele mai multe noi cazuri in Romania
### individual
covid_new%>%
  filter(country_code=='ROU')%>%
  arrange(confirmed_new)%>%
  top_n(3, confirmed_new) %>%
  select(report_date)

# III.3 Ziua cu cele mai multe noi decese in Romania

### De facut ca exemplu
covid_new %>%
  filter(country_code == 'ROU') %>%
  arrange(desc(deaths_new)) %>%
  top_n(1,deaths_new)

# III.4 TOP 3 zile cu cele mai multe noi decese in Romania
### individual

# III.5 Ziua cu cele mai multe noi confirmati in Romania
### individual
# III.6 TOP 3 zile cu cele mai multe cazuri in Romania
### individual




# III.7 Tara cu cea mai mare rata zilnica de imbolnaviri (raportat la total populatie)
# solutia 1:
covid_new %>%
  inner_join(country_gen_info) %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  select(country_name, confirmed_new, population) %>%
  mutate(rata_confirmari = round(confirmed_new/population,6)) %>%
  top_n(3, rata_confirmari)
  



### De facut ca exemplu

# solutia 2:
covid_new %>%
  inner_join(country_gen_info) %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  select(country_name, confirmed_new, population) %>%
  mutate(rata_confirmari = round(confirmed_new/population,6)) %>%
  filter(rata_confirmari == max(rata_confirmari, na.rm = T))

### De facut ca exemplu


# III.8 TOP 3 tari cu cea mai mare rata de imbolnaviri (raportat la total populatie)

#https://dplyr.tidyverse.org/reference/slice.html?q=slice%20_%20max#methods
#https://www.datasciencemadesimple.com/get-first-n-rows-last-n-rows-head-and-tail-function-in-r/
# solutia 1:
covid_new %>%
  inner_join(country_gen_info, by="country_code") %>%
  inner_join(country__pop_coord, by=c("country_code"="country_code3"))  %>%
  select (country_name, report_date, confirmed_new, population) %>%
  mutate (new_cases_rate = round(confirmed_new / population, 6)) %>%
  group_by(country_name) %>%
  mutate(poz=dense_rank(desc(new_cases_rate))) %>%
  filter(poz==1) %>%
  ungroup %>%
  mutate(poz_glob=dense_rank(desc(new_cases_rate))) %>%
  top_n(3,-poz_glob)

# solutia 2:
covid_new %>%
  inner_join(country_gen_info, by="country_code") %>%
  inner_join(country__pop_coord, by=c("country_code"="country_code3"))  %>%
  select (country_name, report_date, confirmed_new, population) %>%
  mutate (new_cases_rate = coalesce(round(confirmed_new / population, 6),0)) %>%
  group_by(country_name) %>%
  summarise (max_cases_rate_country = max(new_cases_rate)) %>%
  slice_max(n=3,max_cases_rate_country)

# solutia 3:
covid_new %>%
  inner_join(country_gen_info, by="country_code") %>%
  inner_join(country__pop_coord, by=c("country_code"="country_code3"))  %>%
  select (country_name, report_date, confirmed_new, population) %>%
  mutate (new_cases_rate = coalesce(round(confirmed_new / population, 6),0)) %>%
  arrange(desc(new_cases_rate))%>%
  group_by(country_name)%>%
  slice_head(n=1) %>%
  ungroup() %>%
  slice_max(n=3,new_cases_rate)

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
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by=c("country_code"="country_code3")) %>%
  group_by(region) %>%
  summarise(region_population = sum(population)) %>%
  ungroup() %>%
  filter (region_population == max(region_population))


# solutie 2 - folosind jonctiunea cu un soi de subconsultare
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by=c("country_code"="country_code3")) %>%
  group_by(region) %>%
  summarise(region_population = sum(population)) %>%
  ungroup() %>%
  inner_join (country_gen_info %>%
                inner_join(country__pop_coord, by=c("country_code"="country_code3")) %>%
                group_by(region) %>%
                summarise(region_population = sum(population)) %>%
                ungroup() %>%
                select (region_population) %>%
                arrange (desc(region_population)) %>%
                head(1)
  )


# solutie 3 - folosind un soi de subconsultare
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by=c("country_code"="country_code3")) %>%
  group_by(region) %>%
  summarise(region_population = sum(population)) %>%
  ungroup() %>%
  filter ( region_population ==
             (country_gen_info %>%
                inner_join(country__pop_coord, by=c("country_code"="country_code3")) %>%
                group_by(region) %>%
                summarise(region_population = sum(population)) %>%
                ungroup() %>%
                select (region_population) %>%
                arrange (desc(region_population)) %>%
                head(1) %>%
                pull())
  )

