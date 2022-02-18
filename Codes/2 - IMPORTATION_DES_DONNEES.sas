libname in "C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_SAS";
libname macros "C:\Users\dionc\Desktop\Projet SAS 2\codes" ;


data RECESSION_bis; set in.RECESSION_bis; run;


/****************************************************************************************
                               IMPORTATION DES DONNEES - FRED                                                                    */
/****************************************************************************************/
proc import out=fred
datafile="C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_Excel\FRED_DATABASE.xls"
dbms=xls replace;
GETNAMES=yes;
RANGE="FRED_Graph$A21:L516"; 
run;


data fred; set fred;
LABEL
IPB50001N_PCH="Industrial Production: Total Index"
USRECM="NBER based Recession Indicators"
MYAGM2USM052N_PCH="M2 for United States"
BOGMBASE_PCH="Monetary Base ; Total"
MYAGM1USM052N_PCH="M2 for United States"
TB3MS="3-Month Treasury Bill"
T10Y3MM="10-Year Treasury Constant Maturity Minus 3-Month Treasury Constant Maturity"
PERMITNSA_PCH="New Private Housing Units Authorized by Building Permits"
WILL5000PR_PCH="Wilshire 5000 Price Index"
DTWEXBGS_PCH="Trade Weighted U.S. Dollar Index: Broad, Goods and Services" 
UNRATE="Unemployment Rate";

RENAME 
observation_date=date
IPB50001N_PCH=INDPRO
USRECM=RECESSION
MYAGM2USM052N_PCH=M2
BOGMBASE_PCH=M0
MYAGM1USM052N_PCH=M1
WILL5000PR_PCH=WILL500
TB3MS=BILL
PERMITNSA_PCH=HI
DTWEXBGS_PCH=TWD
T10Y3MM=SPREAD ;
run;



/*****************************************************************************************
                               IMPORTATION DES DONNEES - SP500                                                */
/****************************************************************************************/
proc import out=sp500
datafile="C:\Users\dionc\Desktop\Projet SAS 2\Donnees\Tables_Excel\SP500 - GSPC.csv"
dbms=csv replace;
DELIMITER=",";
GETNAMES=yes;
guessingrows = max;
run;

data sp500; set sp500;
SP500=((close-open)/open)*100;
label SP500="S & P 500 Index";
run;


/****************************************************************************************
                          MERGE DES DONNEES IMPORTEES -> TABLE FINAL : DONNNES                                                */
/****************************************************************************************/

proc sort data=sp500; by date; run;
proc sort data=fred; by date; run;
proc sort data=recession_bis; by date; run;
data donnees; merge fred(in=obs1) sp500( in=obs2 keep=date sp500) recession_bis(in=obs3) ;
if obs1;
by date;
run;


%let liste = M2 M0 M1 SPREAD BILL HI INDPRO TWD WILL500 SP500 UNRATE;

options MSTORED SASMSTORE = macros;
%lag(&liste., donnees); /* Création de lag pour toutes les variables listées */
%SYSMSTORECLEAR;/*Close macros catalog*/

data in.donnees ; set donnees; run;

