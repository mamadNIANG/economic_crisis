libname in "C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_SAS"; 
Libname macros "C:\Users\dionc\Desktop\Projet SAS 2\codes";

data donnees; set in.donnees;run;

/* RECUPERATION LISTE DES VARIABLES EXPLICATIVES UTILISEES POUR LE MODELE*/ 
data donnees1; set donnees;
drop recession recession_bis date M2 M0 M1 SPREAD BILL HI INDPRO INDPRO_lag: TWD TWD_lag: WILL500 UNRATE SP500 ;
run;

options MSTORED SASMSTORE = macros;
%let liste_explicatives=%GetVars(donnees1);/* Macro qui permet d'obtenir la liste de toutes les variables d'un dataset*/
%put &liste_explicatives;
%clear_data(&liste_explicatives.,donnees);
%SYSMSTORECLEAR; /*Close macros catalog*/
/*********************************************************************************************************************************/

/**********************************************************************************************************************************
                                          I -  ARBRE DECISIONELLE - SELECTION DU MODELE ET RESULTATS
***********************************************************************************************************************************/
/*SELECTION DU MODELE*/
proc hpsplit data=donnees cvmodelfit;
class Recession_bis ;
model Recession_bis (event='1') = &liste_explicatives;
grow entropy;
prune costcomplexity(leaves=6);
ODS OUTPUT ConfusionMatrix=decisiontree_cmatrix;
ODS OUTPUT TreePerformance=decisiontree_perform;
ODS OUTPUT VarImportance= decisiontree_var;
code file='trescore.sas';
run;

/*BILL_lag4 UNRATE_lag9 SPREAD_lag12 UNRATE_lag8 UNRATE_lag1*/

data donnees; set donnees; 
if _n_<142 then role=0; else role=1; 
run;

/* RESULTAT DU MODELE - IN SAMPLE ET OUT SAMPLE*/
proc hpsplit data=donnees;
class recession_bis;
model recession_bis(event='1') = BILL_lag4 UNRATE_lag9 SPREAD_lag12 UNRATE_lag8 UNRATE_lag1;
prune costcomplexity;
partition Rolevar=role(train='0' test='1');
code file='hpsplexc.sas';
rules file='rules.txt';
run;




/**********************************************************************************************************************************
                                          II -  RANDOM FOREST - SELECTION DU MODELE ET RESULTATS
***********************************************************************************************************************************/
proc hpforest data=donnees maxtrees=50 leafsize=5 alpha=0.5;
input  &liste_explicatives / level=INTERVAL ;
target RECESSION_bis / level=BINARY;
SCORE out=sortie_prevision;
ods output Baseline=B;
ods output fitstatistics=fitstats;
ods output VariableImportance=var_imp; 
run;

/* taux de mauvaise classification actuel = 0.208 > classifie bien dans 80.2% des cas*/

/* visualisation*/
proc sql;
select Variable, MarginOOB, GiniOOB
from var_imp
where MarginOOB > 0 and GiniOOB > 0;
run;

/* Graphique pour visualiser nos variables électionnées*/
proc sort data=var_imp; by  GINIOOB; run;

title "Loss reduction variable importance";
proc sgplot data = var_imp;
 scatter x=GiniOOB y=variable/legendlabel='GiniOOB';
 xaxis values=(0 to 0.05 by 0.005);
run;

/* Graphiques pour voir à partir de combien d'arbre on ne baisse pas significativement l'erreur */
title "The Average Square Error";
proc sgplot data = fitstats;
 series x=NTrees y=PredAll/legendlabel='Train Error';
 series x=NTrees y=PredOob/legendlabel='OOB Error';
 xaxis values=(0 to 150 by 1);
 yaxis values=(0.001 to 0.3 by 0.01) label='Average Square Error';
run;

title "The Misclasification Error";
proc sgplot data = fitstats;
 series x=NTrees y=MiscAll/legendlabel='Train Misclassification Error';
 series x=NTrees y=MiscOob/legendlabel='OOB Misclassification Error';
 xaxis values=(0 to 150 by 1);
 yaxis values=(0.001 to 0.3 by 0.01) label='Misclassification Error';
run;

/* après avoir fait la random forest avec 150 arbres, le plus pertinent d'après les graphiques est de faire l'algorythme avec 55 */


/* random forest with its variable's selection */
proc hpforest data=donnees maxtrees=50 alpha=0.5 leafsize=5;
input SPREAD_lag1 SPREAD_lag2 SPREAD_lag3 SPREAD_lag5 SPREAD_lag6 SPREAD_lag7 SPREAD_lag8 SPREAD_lag9 SPREAD_lag10 SPREAD_lag11 SPREAD_lag12 UNRATE_lag1 UNRATE_lag6 UNRATE_lag7 UNRATE_lag8 UNRATE_lag9 UNRATE_lag10 UNRATE_lag11 UNRATE_lag12
BILL_lag1 BILL_lag3 BILL_lag4 BILL_lag5 BILL_lag6 BILL_lag7 BILL_lag8 BILL_lag9 BILL_lag10 TWD_lag1 TWD_lag2/ level=INTERVAL ;
target  RECESSION_bis  / level=BINARY;
ods output fitstatistics=fitstats2;
ods output VariableImportance=var_imp2; 
run;


