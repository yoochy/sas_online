/*************************************************************************************************************************
������		:  chk_log_ds

Ŀ��			:  log�ĵ��뼰ERROR���͵Ļ���/ɸѡ�����final output dataset

����˵��		:  ds	�� ����Log���ݼ�
			   loop	�� ѭ����������Ҫ����infile ����file�ļ���

________________________________________________________________________________________________________________________
*
__________________________________________________________________________________________________________________________
�汾     ����           �޸���            				 �޸�����
---     -----------    ------------   		  ----------------------------------------------------------------------------------
1.0     2018.01.07     shun_dai        					   ����
****************************************************************************************************************************************/;


%macro chk_log_ds(ds,loop);
/*ʹ��infile ��������*/
data &ds._1;
length type $100.;
infile fn&loop. end=last;
input desc $1-5000 @@;
line=_N_;
if index(desc,"_ERROR_")  then type="B_ERROR_";/*_ERROR_�����ݲ����л��е����⣬������ǰ���һ���ַ�������ת����ȥ*/
else if index(desc,"ERROR") then type="ERROR";
else if index(desc,"WARNING") then type="WARNING";
else if index(desc,"δ��ʼ��") or index(desc,"uninitialized") then type="UNINITIALIZED";
run;
/*��ȡÿ������ERROR��ǰ����������У����������б��е�review��*/
data log_tmp;
set &ds._1;
if ^missing(type) then do;
a1=line-2;
a2=line-1;
a3=line;
a4=line+1;
a5=line+2;end;
where ^missing(type);
keep LINE  type a1-a5;
run;
%let dsid=%sysfunc(open(log_tmp));
%let _nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%if &_nobs. eq 0 %then %do;
data &ds._desc;
length LogName $200.;
LogName="&ds.";
ERROR=0;
_ERROR_=0;
WARNING=0;
UNINITIALIZED=0;
run; 

%end;
%if &_nobs. ne 0 %then %do;
proc freq data=LOG_tmp noprint; 
 table  type/   out=&ds._desc1(keep=type COUNT );
run;
proc sort data=&ds._desc1  out=&ds._desc1 ;by type ;quit;
proc transpose data=&ds._desc1 out=&ds._desc  ;
var COUNT;
ID type;
IDLABEL type;
run;
data &ds._desc;
set &ds._desc;
length LogName $200.;
LogName="&ds.";
DROP _NAME_ _LABEL_;
run;
proc sort data=log_tmp(drop= type)  out=log_tmp_  ;by LINE ;quit;
proc transpose data=log_tmp_ out=log_tmp_  prefix=ORRES;
by LINE;
var a1-a5;
run;
proc sql noprint;
select ORRES1 into:varlist separated by ' '  from log_tmp_   ;
quit;
data &ds.;
set &ds._1 ;
if type="B_ERROR_" then Type="_ERROR_";/*ת���ر���*/
where line in (&varlist.);
run;
proc delete data=LOG_tmp LOG_tmp_  &ds._1 &ds._desc1 ;quit;
%end;

%mend;
