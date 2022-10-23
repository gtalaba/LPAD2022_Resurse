install.packages("lubridate")
library(lubridate)
#https://r4ds.had.co.nz/dates-and-times.html
#https://blog.rsquaredacademy.com/handling-date-and-time-in-r/

test <- now()
test

test <- today()
test
ymd(test)
test <- ymd("2020-10-30")
test

mdy("November 2nd, 2020")
dmy("02-Nov-2020")

test <- now()

ymd_hms(test)
ymd_hms("2020-11-01 18:11:59")

year(test)

month(test)

mday(test)
yday(test)
wday(test)


wday(test, label = TRUE, abbr = FALSE)
wday(test, label = TRUE, abbr = TRUE)


test1 <- test + years(10)
test1
test - days(20)

test1 -test
t <-difftime(test1,test)
t
as.numeric(t, units="weeks")
time_length(t, "years")

#http://adv-r.had.co.nz/Subsetting.html


##Subseting vectori
x <- c(2.1, 4.2, 3.3, 5.4)
x
x[3]
x[c(1,4)]
x[1:3]
x[-2]
x[-c(1,4)]


## Subseting matrici

a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")


a[1,]
a[1,3]
a[,2:3]
a[-1,]
a[,c(3,1)]

df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df

df[1,3]
df[,2]

df$z
df[df$x == 2,]


### New driver working with Postgres 13
##https://rpostgres.r-dbi.org/



# install.packages("RPostgres")
library(DBI)

# On Windows systems, PostgreSQL database service must already be started
con <- dbConnect(RPostgres::Postgres(),dbname = 'lab2023', 
                 host = 'localhost', 
                 port = 5432, # or any other port specified by your DBA
                 user = 'postgres',
                 password = 'oracle')

###  B. Display the table names in PostgreSQL database 

dbListTables(con)

tables <- dbSendQuery(con, 
                     "select table_name from information_schema.tables where table_schema = 'public'")
dbFetch(tables)


country__other_data <- dbReadTable(con, "country__other_data" )
str(country__other_data)
head(country__other_data)

country_gen_info <- dbReadTable(con, "country_gen_info" )
str(country_gen_info)
covid_data <- dbReadTable(con, "covid_data" )
country__pop_coord <- dbReadTable(con, "country__pop_coord" )



rez <- dbSendQuery(con, "select country_code,
                                report_date,
	                              tests,
	                              confirmed
                        from covid_data
                        where country_code='ROU'
                        order by report_date desc")
dbFetch(rez)
library(tidyverse)

covid_data %>%
  filter(country_code == 'ROU') %>%
  select(country_code,report_date,tests,confirmed) %>%
  arrange(desc(report_date))



###  F. close all PostgreSQL connections 
dbClearResult(rez)
dbDisconnect(con)

## Clear everything

rm(list = ls())


#install.packages('tidyverse')
#install.packages('lubridate')

library(tidyverse)
library(lubridate)
setwd('e:/##FEAA/2023')

getwd()

#SELECT
#JOIN
#ARRANGE   - ORDER BY
#GROUP BY
#FILTER
# MUTATE TRANSMUTE
#UNGROUP

###############################################################
###                    Incarcarea datelor
###############################################################

load('covid_2022-09-25.RData')
glimpse(covid)
glimpse(country__other_data)
glimpse(country_gen_info)

## Recapitulare joinuri https://statisticsglobe.com/r-dplyr-join-inner-left-right-full-semi-anti

country_gen_info %>%
  mutate(nume_tara=country_name) %>%
  transmute(region, nume_tara_1=country_name)

###Nr de tari din fiecare regiune
rez <- country_gen_info %>%
  group_by(region) %>%
  count()
rez


rez %>%
  select(-region)

# afisati situatia Romaniei de la inceputul pandemiei
# SELECT *
# FROM covid
# WHERE country_code = 'ROU'
# ORDER BY report_date ;

rezultat <- covid_data %>%
  filter (country_code == 'ROU') %>%
  arrange(report_date)



#       I.2 tara cu cea mai mare populatie

# sol.1 
glimpse(country_gen_info)
glimpse(country__pop_coord)
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  filter (population == max(population)) %>%
  select  (country_code:population)


# sol.2
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  top_n(1, population)  %>%
  select (country_name, country_code, population)


# sol.3
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  arrange(desc(population)) %>%
  head(1) %>%
  select (country_name, country_code, population)

# sol.4
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  arrange(desc(population)) %>%
  mutate(nr=row_number()) %>%

  filter (nr == 1) %>%
  select (country_name, country_code, population)



# I.8 TOP 3 tari cu cea mai mare populatie

# sol.1
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  top_n(3, population)  %>%
  select (country_name, country_code, population)
glimpse(rezultat)

rezultat <- country__pop_coord  %>%
  inner_join(country_gen_info, by = c('country_code3' = 'country_code')) %>%
  top_n(3, population)  %>%
  select (country_name, country_code3, population)



# sol.2 (in cazul in care sunt tari cu aceeasi populatie, aceasta solutie
#    nu este completa)
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  arrange(desc(population)) %>%
  head(3) %>%
  select (country_name, country_code, population)


# sol.3 (in cazul in care sunt tari cu aceeasi populatie, aceasta solutie
#    nu este completa)
rezultat <- country_gen_info %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  arrange(desc(population)) %>%
  filter (row_number() <= 3) %>%
  select (country_name, country_code, population)



#   I.8' Pentru fiecare regiune geografica, extrageti 
#               TOP 3 tari cu cea mai mare populatie
rezultat <- country_gen_info   %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  group_by(region) %>%
  top_n(3, population)  %>%
  arrange (region, desc(population)) %>%
  select (region, country_name, country_code, population) 


# care este diferenta dintre un set de date "grupat" si unul "negrupat"
rezultat <- country_gen_info   %>%
  inner_join(country__pop_coord, by = c('country_code' = 'country_code3')) %>%
  group_by(region) %>%
  top_n(3, population)  %>%
  arrange (region, desc(population)) %>%
  select (region, country_name, country_code, population) %>%
  # in acest moment, rezultatul este "grupat", ca sa eliminam 
  #    gruparea, avem nevoie de ungroup
  ungroup () %>%
  top_n(3, population) 









