libname in "C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_SAS"; 
Libname macros "C:\Users\dionc\Desktop\Projet SAS 2\codes\plus";


/**********************************************************************************************
                                       PREPARATION ECHANTILLON
***********************************************************************************************/
data donnees; set in.donnees;run;

/* RECUPERATION LISTE DES VARIABLES EXPLICATIVES UTILISEES POUR LE MODELE*/ 
data donnees1; set donnees;
drop recession recession_bis date M2 M0 M1 SPREAD BILL HI INDPRO INDPRO_lag: TWD TWD_lag: WILL500 UNRATE SP500 ;
run;

options MSTORED SASMSTORE = macros;
%let liste_explicatives=%GetVars(donnees1);/* Macro qui permet d'obtenir la liste de toutes les variables d'un dataset*/
%put &liste_explicatives;
%clear_data(&liste_explicatives. , donnees);/* Macro qui permet de nettoyer un dataset pour n'avoir aucune valeur manquante pour les variables listées*/
%SYSMSTORECLEAR; /*Close macros catalog*/


/* SPECIFICATION TRAIN DATASET ET VALIDATE DATASET*/
data donnees; set donnees; 
if _n_<142 then role=0; else role=1; 
run;

/**********************************************************************************************
                                       PROBIT ET LOGIT
***********************************************************************************************/
ODS OUTPUT PartFitStats=stat_modele;
proc hplogistic data = donnees ;
model RECESSION_bis (EVENT="1") =  &liste_explicatives. 
                                    / ASSOCIATION ctable=roc2 ;
partition rolevar=role(train='0' test='1');
selection method=stepwise details=all;
run;
/*SPREAD_lag2 SPREAD_lag12 BILL_lag2 HI_lag5 SP500_lag2 UNRATE_lag1 UNRATE_lag9*/


/* PEAUFINAGE DU MODELE A LA MAIN DU MODELE*/
proc hplogistic data = donnees  ;
model RECESSION_bis (EVENT="1") = /*+*/M0_lag5 M0_lag7 SPREAD_lag2 SPREAD_lag12 BILL_lag2 WILL500_lag4 HI_lag5 SP500_lag2 /*UNRATE_lag1*/ /*+*/UNRATE_lag4 UNRATE_lag8 /*UNRATE_lag9*/

 
                                    / ASSOCIATION ctable=roc2 ;
									output out=data
pred=predict ;
partition rolevar=role(train='0' test='1');
run;
