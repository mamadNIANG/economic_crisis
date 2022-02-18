* Written by R;
*  write.foreign(phase_INDPRO, "C:/Users/dionc/Desktop/Projet SAS 2/Donnees/Tables_SAS/Phase_cycle_INDPRO.txt",  ;

DATA  rdata ;
INFILE  "C:/Users/dionc/Desktop/Projet SAS 2/Donnees/Tables_SAS/Phase_cycle_INDPRO.txt" 
     DSD 
     LRECL= 10 ;
INPUT
 series1_Obs
 ind_INDPRO
;
LABEL  series1_Obs = "series1.Obs" ;
RUN;
