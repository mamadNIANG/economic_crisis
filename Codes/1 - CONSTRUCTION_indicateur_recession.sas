libname in"C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_SAS";


/*****************************************************************************************************
                                         I - IMPORTATION INDICE DE PRODUCTION
******************************************************************************************************/
proc import out=ind_prod
datafile="C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_Excel\INDPRO.xls"
dbms=xls replace;
GETNAMES=yes;
RANGE="FRED_Graph$A11:B506"; 
run;

data ind_prod; set ind_prod;
LABEL INDPRO="Industrial Production: Total Index";
RENAME observation_date=date ;
run;

Data ind_prod; set ind_prod;
L_INDPRO=log(INDPRO);
Obs=_n_;
run;

Data in.ind_prod; set ind_prod;
run;


/********************************************************************************************************************************************************
                           II-  EXTRACTION DES POINTS DE RUPTURES ET DATES ASSOCIES DU CYCLE D'INDPRO
                                 POUR DETERMINER LES PHASES DE RECESSIONS ET D'EXPANSIONS
                 ------>         PROGRAMME R - "C:\Users\dionc\Desktop\Projet SAS 2 \Codes\BCDating_INDPRO.R" ( doit être exécuter)
*********************************************************************************************************************************************************/
/*RECUPERATION TABLE SORTIE PROGRAMME R*/
DATA  in.Phase_INDPROD ;
INFILE  "C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_SAS\Phase_cycle_INDPRO.txt"
     DSD 
     LRECL= 10 ;
INPUT
 series1_Obs
 ind_INDPRO
;
LABEL  series1_Obs = "series1.Obs" ;
RUN;

data ind_prod; set in.ind_prod;run;
data Phase_INDPROD; set in.Phase_INDPROD;run;

data Cycle_plus;merge ind_prod Phase_INDPROD(rename=(series1_obs=obs));
by obs;
run;


Data cycle_plus; set cycle_plus;
If ind_INDPRO=1 then RECESSION_bis=0; /*EXPENSION*/
If ind_INDPRO=-1 then RECESSION_bis=1; /*RECESSION*/
keep date RECESSION_bis;
run;

/* CONTROLE DE L'INDICATEUR DE RECESSION*/
data tt2; merge ind_prod(keep=l_indpro date) cycle_plus;
by date;
run;

symbol i=join;
proc gplot data=tt2;
plot l_indpro*date / overlay;
plot2 recession_bis*date;
run;
quit;


data in.RECESSION_bis; set cycle_plus;run;


