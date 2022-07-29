/*************************************************************************************************************************
������		: xpt_sas2xpt

Ŀ��			: �����ݼ�ת����XPT�ļ�

����˵��		:
%xpt_sas2xpt(SASLIB=SAS,outfile=E:\�ճ�С����\�½��ļ��� (2)\xpt)
SASLIB  ��ת���ݼ������߼���
outfile xpt�洢�ļ���·�������ļ����²�����SAS���ݼ���
  
ʵ��			��%xpt_sas2xpt(SASLIB=SAS,outfile=E:\�ճ�С����\�½��ļ��� (2)\xpt);     
________________________________________________________________________________________________________________________

__________________________________________________________________________________________________________________________
�汾     ����           �޸���             �޸�����
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2017.04.12      setup           ����
****************************************************************************************************************************************/
%macro xpt_sas2xpt(SASLIB=,outfile=);
options nofmterr;
	%let lib1=%upcase(&SASLIB.);
proc sql noprint;
	select count(distinct memname) into: nn from dictionary.columns where libname="&lib1.";
	select distinct memname into:mem1-:mem%left(&nn.) from dictionary.columns where libname="&lib1.";
quit;

%do i=1 %to &nn;
libname xportout  xport   "&outfile.\&&mem&i...xpt" ;
	data xportout.&&mem&i.;
		set &lib1..&&mem&i.;
	run;
%end;
%mend;


