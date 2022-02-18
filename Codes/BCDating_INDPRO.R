install.packages("BCDating")
install.packages("haven")
install.packages("forecast")
install.packages("foreign")

# CZ
library(haven)
series1<-read_sas("C:/Users/dionc/Desktop/Projet SAS 2/Donnees/Tables_SAS/ind_prod.sas7bdat")
INDPRO<-series1$L_INDPRO

library(forecast)
INDPRO_times_series<-ts(INDPRO, start=c(1980, 1), end=c(2021, 3), frequency=12)

library(BCDating)
dat1 <- BBQ(INDPRO_times_series,minphase = 6, name="Dating IND")
show(dat1)
plot(dat1)
ind_INDPRO<-dat1@states
phase_INDPRO <- data.frame(series1$Obs,ind_INDPRO)

library(foreign)
write.foreign(phase_INDPRO,"C:/Users/dionc/Desktop/Projet SAS 2/Donnees/Tables_SAS/Phase_cycle_INDPRO.txt","C:/Users/dionc/Desktop/Projet SAS 2/Donnees/Tables_SAS/Phase_cycle_INDPRO.sas",   package="SAS")





