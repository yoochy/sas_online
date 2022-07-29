/*************************************************************************************************************************
������		: xpt_xpt2sas

Ŀ��			: ��xpt���ݼ�ת����SAS���ݼ�

����˵��		:


	infile  ��дxpt���ڵ�����·�����ļ���

  
ʵ��			��
%xpt_xpt2sas(D:\�ճ���ϰ\��ʱ\test\�������ݼ�)
infile  ��дxpt���ڵ�����·�����ļ���;     
________________________________________________________________________________________________________________________

__________________________________________________________________________________________________________________________
�汾     ����           �޸���             �޸�����
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2017.04.12      setup           ����
****************************************************************************************************************************************/

%macro xpt_xpt2sas(infile);
options nofmterr;
filename xcl_fil pipe "dir ""&infile.""\*.xpt /b"; 
data a;
   infile xcl_fil truncover;
   input fname $char1000.;
   put fname=;
run;
data b;
	set a;
	uf=find(fname,'.',-200);
	ef=substr(fname,1,uf-1);
	zf=compress(ef,'.');
	keep zf fname;
run;
data _null_;
	set b;
	call symput('N'||compress(put(_n_,best.)),strip(fname));
	call symput('M'||compress(put(_n_,best.)),strip(zf));
run;
%let dsid=%sysfunc(open(b));/*b ����д���ݼ�����*/
%let nobs=%sysfunc(attrn(&dsid,nobs));/*nobsΪ�۲���*/
%let rc= %sysfunc(close(&dsid));
	data _null_;
		call symput("date",left(put("&sysdate"d,yymmdd10.)));
		call symput("date1",left(compress(put("&sysdate"d,yymmdd10.),"-"," ")));
	run;

data _null_;
NewDir=dcreate("&date1.","&infile.");
run;/*��D���´���һ���ļ��У�����mydata���ļ���*/
libname MyWork "&infile.\&date1.";
%do i=1 %to &nobs;
libname xportout  xport   "&infile.\&&N&i." ;
data MyWork.&&M&i.;
	set xportout.&&M&i.;
run;

%end;
libname MyWork clear;
libname xportout clear;

%mend;
