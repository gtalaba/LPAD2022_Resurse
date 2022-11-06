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


load('covid_2022-09-25.RData')

glimpse(covid_data)
glimpse(country__other_data)
glimpse(country__pop_coord)
glimpse(country_gen_info)


################################################################################
###              To tally or not                                             ###
################################################################################

### n()
covid_new %>%
  tally()

covid_new %>%
  group_by(country_code) %>%
  tally()

### sum()

covid_new %>%
  group_by(country_code) %>%
  tally(confirmed_new) 

### Ziua cu cele mai multe cazuri din alta abordare

 covid_data %>%
  group_by(country_code) %>%
  slice_max(confirmed) %>%
  filter(row_number()==1)
  

 

 ################################################################################
 ###              Sample or all                                               ###
 ################################################################################
 

### sample_n

covid_new %>%
  select(country_code,report_date,confirmed) %>%
  sample_n(20)
### sample_frac
covid_new %>%
  select(country_code,report_date,confirmed) %>%
  sample_frac(0.10)


### Validam procentul
covid_new %>%
  tally()


### slice_sample
covid_new %>%
  select(country_code,report_date,confirmed) %>%
  slice_sample(n=100)

covid_new %>%
  group_by(country_code) %>%
  select(country_code,report_date,confirmed) %>%
  slice_sample(n=2)




################################################################################
###              Operators                                                   ###
################################################################################

#https://guigui351.github.io/Datacamp-R/10%20-%20Joining%20Data%20in%20R%20with%20dplyr/ch2_-_Filtering_joins_and_set_operations.html#apply-a-semi-join

# union  --> UNION
# interesect --> INTERSECT
# setdiff  --> EXCEPT

mtcars1 <- mtcars%>%
  sample_frac(0.50)
glimpse(mtcars1)

mtcars2 <- mtcars%>%
  sample_frac(0.50)
glimpse(mtcars2)

mtcars %>% count()
mtcars1 %>%
  union(mtcars2) %>%
  tally()

mtcars1 %>%
  union_all(mtcars2) %>%
  tally()

mtcars1 %>%
  intersect(mtcars2)

mtcars1 %>%
  setdiff(mtcars2)

mtcars2 %>%
  setdiff(mtcars1)


mtcars1 %>%
  setequal(mtcars)


mtcars1 %>%
  setequal(mtcars1)

################################################################################
###              Regexp                                                      ###
################################################################################



#https://r4ds.had.co.nz/strings.html

x <- c("Am", "ajuns", "la","jumatatea","semestrului","3333")
str_view(x, "a")
str_view(x, "^a")
str_view(x,"[:digit:]")

#https://github.com/rstudio/cheatsheets/blob/master/strings.pdf

### Tema validati numerele de telefon si ip-urile folosind expresii regulate
x <- c("am", "nr", "344h33454", "0741111111", "0745")

x <- c ("10.126.10.1", "10*126.10.1", "10 126 10 1")

################################################################################
###             Interogari si iar interogari                                 ###
################################################################################
#II.4'' Afisati, pentru fiecare tara (in ordine alfabetica), 
#       ziua cu cea mai mare rata de mortalitate (procent)


### De lucrat


# II.4''' Afisati, pentru fiecare tara (in ordine alfabetica), 
#       top 5 zile cu cea mai mare rata de confimat (procent)



### Lucru individual



################################################################################
## Sa se obtina un raport in care pe fiecare linie sa fie afisata cate o tara  #
## si pe coloane, in afara numelui tarii, sa se afiseze numarul de             #    
## cazuri COVID pe fiecare din primele trei trimestre ale anului 2021          #
##                                                                             #  
##     Tara              cazuri_trim1    cazuri_trim2   cazuri_trim3   Total   #  
##     Total                 x               x                x                #  
##   In plus, adaugati o coloana si o linie cu totaluri                        # 
################################################################################





rezultat <- bind_rows(
    country_gen_info %>%
      filter(!is.na(country_name)) %>%
      select (country_name, country_code) %>%
      inner_join( covid_new %>%
                   filter (year(report_date) == 2021 & month(report_date) %in% c(1, 2, 3)) %>%
                   group_by(country_code) %>%
                   summarise(cazuri_trim1 = sum(confirmed_new)) %>%
                   ungroup()
      ) %>%
      inner_join( covid_new %>%
                   filter (year(report_date) == 2021 & month(report_date) %in% c(4, 5, 6)) %>%
                   group_by(country_code) %>%
                   summarise(cazuri_trim2 = sum(confirmed_new)) %>%
                   ungroup()
      ) %>%
      inner_join( covid_new %>%
                   filter (year(report_date) == 2021 & month(report_date) %in% c(7, 8, 9)) %>%
                   group_by(country_code) %>%
                   summarise(cazuri_trim3 = sum(confirmed_new)) %>%
                   ungroup()
      ) %>%
      inner_join( covid_new %>%
                   filter (year(report_date) == 2021 & month(report_date) <= 9) %>%
                   group_by(country_code) %>%
                   summarise(cazuri_trim1_2_3 = sum(confirmed_new)) %>%
                   ungroup()
      ) %>%
      mutate (cazuri_trim1 = coalesce(cazuri_trim1, 0),
              cazuri_trim2 = coalesce(cazuri_trim2, 0),
              cazuri_trim3 = coalesce(cazuri_trim3, 0),
              cazuri_trim1_2_3 = coalesce(cazuri_trim1_2_3, 0)
      ),
    tibble(
      country_name = ' T O T A L ',
      country_code = '',
      cazuri_trim1 = (covid_new %>%
                        filter (year(report_date) == 2021 & month(report_date) %in% c(1, 2, 3)) %>%
                        summarise (cazuri_trim1 = sum(confirmed_new)) %>%
                        pull(cazuri_trim1)) ,
      cazuri_trim2 = (covid_new %>%
                        filter (year(report_date) == 2021 & month(report_date) %in% c(4, 5, 6)) %>%
                        summarise (cazuri_trim2 = sum(confirmed_new)) %>%
                        pull(cazuri_trim2)) ,
      cazuri_trim3 = (covid_new %>%
                        filter (year(report_date) == 2021 & month(report_date) %in% c(7, 8, 9)) %>%
                        summarise (cazuri_trim3 = sum(confirmed_new)) %>%
                        pull(cazuri_trim3)) ,
      cazuri_trim1_2_3 = (covid_new %>%
                            filter (year(report_date) == 2021 & month(report_date) <= 9) %>%
                            summarise (cazuri_trim1_2_3 = sum(confirmed_new)) %>%
                            pull(cazuri_trim1_2_3))
    )
  )
  

#### Tema

# Eliminati tarile fara nici un caz raportat in  primele trei trimestre ale anului 2021 
  
################################################################################
## Sa se obtina un raport in care pe fiecare linie sa fie afisata cate o tara  #
## si pe coloane, in afara numelui tarii, sa se afiseze numarul de             #
## cazuri COVID pe fiecare luna ale primelor trei trimestre ale anului 2021    #
################################################################################

#https://cmdlinetips.com/2020/11/reshape-tidy-data-to-wide-data-with-pivot_wider-from-tidyr/
covid_new %>%
  filter (year(report_date) == 2021 & month(report_date) <= 9) %>%
  transmute (country_code, month = month(report_date), confirmed_new) %>%
  group_by(country_code, month) %>%
  summarise(new_cases = sum(confirmed_new)) %>%
  ungroup() %>%
  pivot_wider(names_from = month, values_from = new_cases)




