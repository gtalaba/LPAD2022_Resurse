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
###              IF                                                          ###
################################################################################



x <- -1
if(x > 0) print("Non-negative number") else print("Negative number")

team_A <- 1 # Number of goals scored by Team A
team_B <- 7# Number of goals scored by Team B
if (team_A > team_B){
  print ("Team A won")
} else if (team_A < team_B){
  print ("Team B won")
} else {
  print("Team A & B tied")
}

################################################################################
###              IF-ELSE                                                     ###
################################################################################


covid_new %>%
  mutate(zi_confirmati = if_else(confirmed_new > 1, 1,0)) %>%
  select(report_date,confirmed_new,zi_confirmati) %>%
  filter(zi_confirmati==1)


covid_new %>%
  mutate(grad_infectare = if_else(confirmed_new <100, "low", if_else(confirmed_new >100, "high","mediu"))) %>%
  select(report_date,confirmed_new,grad_infectare) %>%
  filter(grad_infectare=='mediu')

covid_new %>%
  mutate(zi_trista = if_else(confirmed_new >0 & deaths_new >0, "da","nu")) %>%
  select(report_date,confirmed_new,deaths_new,zi_trista) %>%
  filter(zi_trista=='nu')

#varf - confirmat + decedati
#acalmie - (confirmati - fara decedati) sau (decedati - fara confirmati)
#relaxare - fara confirmati - fara decedati

covid_new %>%
  mutate(tip_zi = if_else(confirmed_new >0 & deaths_new >0, "varf", if_else( confirmed_new >0 |deaths_new >0, "acalmie","relaxare"))) %>%
  select(country_code,report_date,confirmed_new, deaths_new,tip_zi) %>%
  filter(tip_zi=='relaxare')


################################################################################
###              CASE                                                        ###
################################################################################



x <- 2000
case_when( x < 1964 ~ "Generatia Baby Boomer",
           x < 1980 ~ "Generatia X",
           x < 1996 ~ "Generatia Millenials",
           TRUE ~ "Generatia Z")


# Folosind CASE clasificati zilele in functie de urmatoare reguli intr-o coloana noua tip_zi
#Ambele - (confirmati si decese)
#Confirmati(confirmati fara decese )
#Decese (decese fara confirmati)
#Niciunul(fara decese si confirmari noi)

##### La laborator

################################################################################
###              LOOPS                                                       ###
################################################################################


#https://www.datacamp.com/community/tutorials/tutorial-on-loops-in-r

u1 <- c(1,2,3,4,5,6,7,8,9,10)
print("This loop calculates the square of the first 10 elements of vector u1")
# Initialize `usq`
usq <- 0
for(i in 1:10) {
  # calculam patratatul elementului i
  usq[i] <- u1[i]*u1[i]
  print(usq[i])
}

print(i)

### WHILE
i <-1
while (i <=10) {   
  # calculam patratatul elementului i
  usq[i] <- u1[i]*u1[i]
  print(usq[i])
  i<- i+1
}
print(i)
## REPEAT
i<-1
repeat {   
  if (i == 11) {
    print("Done!");
    break
  } else 
    # calculam patratatul elementului i
    usq[i] <- u1[i]*u1[i]
  print(usq[i])
  i<-i+1
}  
print(i)


################################################################################
###              PSEUDOCOD                                                   ###
################################################################################

#  Sa se afiseze , prima si ultima zi cu
#   cazuri COVID in RO, fara a folosi functiile MIN si MAX 


v_prima_zi <- as.Date('1970-01-01')
v_ultima_zi_id <-0
v_ultima_zi <-''

for (i in 1:nrow(covid_data)) {
  if (covid_data$country_code[[i]]== 'ROU' & !is.na(covid_data$confirmed[[i]])) {
    if (covid_data$confirmed[[i]] >0 & v_prima_zi == as.Date('1970-01-01')) {
      v_prima_zi <- covid_data$report_date[[i]]
    } else if (covid_data$confirmed[[i]] >0 & covid_data$report_date[[i]] > v_prima_zi) {
      v_ultima_zi_id <-i
    }
  }
}
v_ultima_zi <- covid_data$report_date[[v_ultima_zi_id]]
print(v_prima_zi)
print(v_ultima_zi)

### Verificam
covid_data%>%
  filter(country_code == "ROU" & confirmed >0) %>%
  summarise(min(report_date), max(report_date))





##sa se calculeze numarul de cazuri noi din RO 
##fara a folosi functia LAG  (atributul `CONFIRMED_NEW`)   

covid_test <- covid_data %>%
  mutate(confirmed_new = 0)


###### La laborator

### Verificare
covid_test %>%
  filter(confirmed_new >0 ) %>%
  arrange(report_date) %>%
  select (report_date,confirmed, confirmed_new) 





### UDF

#  https://www.datacamp.com/community/tutorials/functions-in-r-a-tutorial
# Define a simple function
myFirstFun<-function(n)
{
  # Compute the square of integer `n`
  n*n   
}

# Assign `10` to `k`
k <- 10

# Call `myFirstFun` with that value
m <- myFirstFun(k)

# Call `m` 
m


### Creati functie pentru determinarea numarului distinct de tari din dataset

tari_distincte <- function()  
{
  covid_data%>%
    distinct(country_code) %>%
    arrange(country_code) %>%
    pull()
}

t <- tari_distincte()
t

covid_new%>%
  group_by(country_code) %>%
  filter(confirmed_new >0) %>%
  summarise(min(report_date), max(report_date))



#  Sa se afiseze pentru fiecare tara , nr de zile scurse de la inceputul pandemiei pana la prima infectie locala


v_prima_zi <- as.Date('1970-01-01')
v_ultima_zi_id <-0
v_ultima_zi <-''

for(j in 1:length(tari_distincte()))
{
  for (i in 1:nrow(covid_data)) {
    if (covid_data$country_code[[i]]== tari_distincte()[j])
    {
      if (covid_data$confirmed[[i]] >0  & !is.na(covid_data$confirmed[[i]]))
      {
        if(v_prima_zi == as.Date('1970-01-01')) {
          v_prima_zi <- covid_data$report_date[[i]]
          v_ultima_zi_id <- i
        } else if (  covid_data$confirmed[[i]]>coalesce(covid_data$confirmed[[i-1]],0) ) {
          v_ultima_zi_id <-i
        } 
      }
    }
  }
  v_ultima_zi <- covid_data$report_date[[v_ultima_zi_id]]
  mesaj <- paste0('Prima zi de pandemie:',v_prima_zi,' ultima zi de pandemie:',v_ultima_zi,' din:',tari_distincte()[j])
  print(mesaj)
  v_prima_zi <- as.Date('1970-01-01')
  
}  

covid_new%>%
  group_by(country_code) %>%
  filter(confirmed_new >0) %>%
  summarise(min(report_date), max(report_date))

# Optimizati pentru a trece o singura data prin covid_data folosind un df ajutator


tari <- tibble(
  tari  = tari_distincte(),
  prima_zi = as.Date('1970-01-01'),
  ultima_zi = as.Date('9999-01-01')
)




###### La laborator


### Verificam
tari

covid_new%>%
  group_by(country_code) %>%
  filter(confirmed_new >0) %>%
  summarise(min(report_date), max(report_date))



#### Construiti o functie care sa intoarca prima si ultima zi de pandemie dintr-o tara, in cazul in care nu se specifica tara 
#### sa fie considerata Romania

calcul_pandemie <- function( tara = "ROU" ){
  covid_new %>%
    filter(country_code == tara)%>%
    filter(confirmed_new >0) %>%
    summarise(inceput = min(report_date), sfarsit = max(report_date)) 
}

calcul_pandemie()
calcul_pandemie('BRN')
calcul_pandemie('ESP')


#### Adaugam si o verificare ca tara exista in DF
tari_distincte
calcul_pandemie <- function( tara = "ROU" ){
  if(!tara %in% tari_distincte())
  { stop("Tara nu este in dataframe")}
  covid_new %>%
    filter(country_code == tara)%>%
    filter(confirmed_new >0) %>%
    summarise(inceput = min(report_date), sfarsit = max(report_date)) 
}

calcul_pandemie('AAA')
calcul_pandemie('ROU')


#### Facem si un parametru dinamic

tari_distincte
calcul_pandemie <- function( ... ){
  covid_new %>%
    filter(...)%>%
    filter(confirmed_new >0) %>%
    summarise(inceput = min(report_date), sfarsit = max(report_date)) 
}

calcul_pandemie(country_code == 'ROU')
calcul_pandemie(report_date > '2021-01-01')
calcul_pandemie(report_date > '2021-01-01' & country_code == 'ROU')


################################################################################
##  In cadrul de date `covid` adaugati atributul                              ## 
## `nr_cazuri_u3zile_lucrat` care va contine, pentru fiecare                  ## 
## linie (tara si data calendaristica a raportarii)                           ##  
## valoarea numarului de cazuri cumulat pe ultimele trei zile LUCRATOARE      ##  
## (trei zile, inclusiv data curenta, daca este zi lucratoare (luni-vineri)   ## 
## inregistratre in tara curenta.                                             ##   
##                                                                            ## 
##  Calculati valorile acestui atribut folosind structuri de control          ## 
##  R/tidyverse (adica redactati o solutie mai `programatica`)                ## 
##                                                                            ## 
## Nota: zile lucratoare se considera toate zilele de lunea pana vinerea      ##
################################################################################


lubridate::wday(Sys.Date())

lubridate::wday(lubridate::ymd('2020-11-19'))

lubridate::wday(Sys.Date(), label= TRUE)


covid_2 <- covid_new %>%
  select (country_code, report_date, confirmed_new) %>%
  mutate (week_day_num =wday (report_date),
          week_day_string =wday (report_date, label= TRUE)) %>%
  arrange(country_code, report_date) %>%
  mutate (nr_cazuri_u3zile_lucrat = 0)


test <- covid_new %>%
  select (country_code:confirmed_new) %>%
  mutate (week_day_num =wday (report_date),
          week_day_string =wday (report_date, label= TRUE)
  ) %>%
  arrange(country_code, report_date)


tari <- covid_2 %>%
  distinct(country_code) %>%
  arrange(country_code)

#i <- 1
# bucla principala parcurge fiecare tara 
for (i in 1:nrow(tari)) {
  
  # procesam zilele pentru tara curenta
  tara_crt <- tari$country_code[i]
  
  zile_tara_crt <- covid_2 %>%
    filter (country_code == tara_crt) %>%
    arrange(report_date)  
  
  #j <- 93
  # a doua bucla parcurge toate datele calendaristice (zilele) ale tarii curente
  for (j in 1:nrow(zile_tara_crt)) {
    
    trei_zile_lucratoare <- tibble()
    
    # a treia bucla se executa pana cand sunt trei inregistrari in `trei_zile_lucratoare`
    # sau am ajuns la prima zi a tarii
    
    k <- j 
    while (k >= 1 & nrow(trei_zile_lucratoare) < 3) {
      if (wday(zile_tara_crt$report_date[k]) > 1 & wday(zile_tara_crt$report_date[k]) < 7) {
        trei_zile_lucratoare <- bind_rows(trei_zile_lucratoare,
                                          zile_tara_crt[k,])
      }  
      k <- k - 1
    }
    
    # sum(trei_zile_lucratoare$confirmed_new)
    covid_2 <- covid_2 %>%
      mutate (nr_cazuri_u3zile_lucrat = 
                ifelse(country_code == tara_crt & report_date == zile_tara_crt$report_date[j],
                       sum(trei_zile_lucratoare$confirmed_new), nr_cazuri_u3zile_lucrat
                ))
    
  }
  
}





################################################################################
###                Scadenta facturi                                          ###
################################################################################


####https://github.com/marinfotache/Data-Processing-Analysis-Science-with-R/blob/master/04%20Basic%20Programming/04c2a_Problema_laborator_scadenta_facturi_1_Cerinte.pdf


library(tidyverse)
library(lubridate)
library(readxl)
library(openxlsx)

setwd('e:/##FEAA/R/Scadente facturi R')

Sys.setlocale("LC_TIME", "English_United States.1252")

sarbatori_fixe      <- read_excel("sarbatori_fixe_variabile_si_scadente_facturi_new.xlsx", 
                                  sheet = "SARBATORI_FIXE",      
                                  col_types = c("numeric", "numeric", "text"))
sarbatori_Variabile <- read_excel("sarbatori_fixe_variabile_si_scadente_facturi_new.xlsx",
                                  sheet = "SARBATORI_VARIABILE", 
                                  col_types = c("date", "text"))
scadente_facturi    <- read_excel("sarbatori_fixe_variabile_si_scadente_facturi_new.xlsx", 
                                  sheet = "SCADENTE_FACTURI",             
                                  col_types = c("numeric", "date", "numeric"))

check_if_weekend_day <- function(invoice_date){
  return(weekdays(invoice_date) %in% c("Saturday", "Sunday"))
}

check_if_varying_holiday <- function(invoice_date){
  return(invoice_date %in% sarbatori_Variabile$Data)
}

check_if_fixed_holiday <- function(invoice_date){
  for(idx_f_h in 1:nrow(sarbatori_fixe)){
    if(sarbatori_fixe$Zi[idx_f_h] == day(invoice_date) && sarbatori_fixe$Luna[idx_f_h] == month(invoice_date))
      return(TRUE)
  }
  return(FALSE)
}

check_if_working_day <- function(invoice_date){
  is_weekend_day <- check_if_weekend_day(invoice_date)
  is_varying_holiday <- check_if_varying_holiday(invoice_date)
  is_fixed_holiday <- check_if_fixed_holiday(invoice_date)
  return(!(is_weekend_day||is_varying_holiday||is_fixed_holiday))
}

Data_Scadenta <- c()
for (idx_row in 1:nrow(scadente_facturi)){
  nr_scadente_zile <- scadente_facturi$Nr_zile_lucratoare_scadenta[idx_row]
  
  invoice_date <- scadente_facturi$Data_Factura[idx_row]
  
  working_days <- 0
  
  while ( working_days < nr_scadente_zile ){
    invoice_date <- invoice_date + days(1)
    if(check_if_working_day(invoice_date))
      working_days <- working_days + 1
  }
  Data_Scadenta <- c(Data_Scadenta, format(invoice_date, "%Y-%m-%d"))
}

scadente_facturi$Data_Factura <- format(scadente_facturi$Data_Factura, "%Y-%m-%d")

scadente_facturi_cu_data_scadenta <- cbind(scadente_facturi, Data_Scadenta)

write.xlsx(scadente_facturi_cu_data_scadenta, "scadente_facturi_cu_data_scadenta_var_1_new.xlsx", sheetName="SCADENTE_FACTURI")
