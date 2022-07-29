/*************************************************************************************************************************
宏名称		: xpt_xpt2sas

目的			: 将xpt数据集转换成SAS数据集

参数说明		:


	infile  填写xpt所在的物理路径及文件夹

  
实例			：
%xpt_xpt2sas(D:\日常练习\临时\test\衍生数据集)
infile  填写xpt所在的物理路径及文件夹;     
________________________________________________________________________________________________________________________

__________________________________________________________________________________________________________________________
版本     日期           修改人             修改描述
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2017.04.12      setup           创建
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
%let dsid=%sysfunc(open(b));/*b 处填写数据集名称*/
%let nobs=%sysfunc(attrn(&dsid,nobs));/*nobs为观测数*/
%let rc= %sysfunc(close(&dsid));
	data _null_;
		call symput("date",left(put("&sysdate"d,yymmdd10.)));
		call symput("date1",left(compress(put("&sysdate"d,yymmdd10.),"-"," ")));
	run;

data _null_;
NewDir=dcreate("&date1.","&infile.");
run;/*在D盘下创建一个文件夹，创建mydata的文件夹*/
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
