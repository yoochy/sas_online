/*************************************************************************************************************************
宏名称		: xpt_sas2xpt

目的			: 将数据集转换成XPT文件

参数说明		:
%xpt_sas2xpt(SASLIB=SAS,outfile=E:\日常小程序\新建文件夹 (2)\xpt)
SASLIB  待转数据集所在逻辑库
outfile xpt存储文件夹路径（此文件夹下不能有SAS数据集）
  
实例			：%xpt_sas2xpt(SASLIB=SAS,outfile=E:\日常小程序\新建文件夹 (2)\xpt);     
________________________________________________________________________________________________________________________

__________________________________________________________________________________________________________________________
版本     日期           修改人             修改描述
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2017.04.12      setup           创建
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


