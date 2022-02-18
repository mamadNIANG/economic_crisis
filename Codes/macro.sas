Libname macros "C:\Users\dionc\Desktop\Projet SAS 2\codes";
options mstored sasMSTORE=macros;

%Macro GetVars(Dset) / store
     des='Get all the columns names of a dataset' ;
 %Local VarList ;
 /* open dataset */
 %Let FID = %SysFunc(Open(&Dset)) ; 
 /* If accessable, process contents of dataset */
 %If &FID %Then %Do ;
 %Do I=1 %To %SysFunc(ATTRN(&FID,NVARS)) ; 
 %Let VarList= &VarList %SysFunc(VarName(&FID,&I));
 %End ;
 /* close dataset when complete */
 %Let FID = %SysFunc(Close(&FID)) ; 
 %End ;
 &VarList
%Mend GetVars;


%macro clear_data(list, data_name)/ store
     des='Get a data with no missing value for all variable listed clear_data(liste_var, data_name)' ;
%let x=%sysfunc(countw(&list.));
%do i=1 %to &x.;

%let var=%scan(&list.,&i.);
data &data_name. ; set &data_name.;
if &var ^=.;
run;

%end;
%mend clear_data;


%macro lag(list, data_name) / store des='Create lag for all variable listed in dataset (liste_var, dataset_name)' ;
%let x=%sysfunc(countw(&list.));
%do i=1 %to &x.;
%let var=%scan(&list.,&i.);

%do r=1 %to 12;
data &data_name. ; set &data_name.;
&var._lag&r.=lag&r.(&var.);
run;
%end;

%end;
%mend lag;

%SYSMSTORECLEAR; /*Close macros catalog*/
