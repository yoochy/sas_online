/*************************************************************************************************************************
宏名称		:  rtf_merge

目的			:  用与RTF文件的合并

参数说明		:  	
	
*
inpath 		输出文件夹
outfile		统计后输出数据集
order       排序顺序
pageyn		页码的修正：（默认为1进行修正）


%rtf_merge(inpath=D:\xxxxxx\Project\test,
	outfile=D:\xxxxxx\Project\test\test\all.rtf,
	order=1,pageyn=1);


____________________________________________________________________________________________________________________
/****************************************************************************************************************************************
__________________________________________________________________________________________________________________________
版本     日期           修改人             					修改描述
---     -----------    ------------    	 ----------------------------------------------------------------------------------
1.0     2018.11.14      SAS程序分享号号号（xiaocgn）           创建
****************************************************************************************************************************************/;

%macro   rtf_mergeV1(inpath=,outfile=,order=0,pageyn=1);
  %let ps1=800;
  %let ls1=256;
options ps=&ps1 ls=&ls1  nonotes  nosource nosource2   ;
skip 5;
*获取指定路径下文件夹下RTF文件名称;
filename xcl_fil pipe "dir &inpath.\*.rtf /b/s"; 
data add_rtflist;
   infile xcl_fil truncover;
   input fname $char1000.;
   order=.;
run;
*默认以文件名进行升序排别;
proc sort data=add_rtflist  out=add_rtflist1  sortseq=linguistic(numeric_collation=on);by fname ;quit;

*判断是否需要人工排序;
*当order为1时则需要进行排序，同时根据step判断是否需要将文件名导出到外部Excel进行人工手动添加顺序;

%if  &order. eq  1 %then %do;
*判断待合并RTF文件夹下有无file_order.xls文件（存放RTF文件合并先后的排序列表）
	*如无，则生成此文件并退出宏的执行;
	%if %sysfunc(fileexist(&inpath.\file_order.xls))=0   %then %do;
skip 2;
		%put *宏参数order=1,但发现&inpath.\file_order.xls文件未存在,系统将自动生成此文件并退出当前程序的执行！;
		%put *请在人工完成此文件的编辑后，再次执行此程序;
		proc export data= add_rtflist1
		    outfile="&inpath.\file_order.xls"
			dbms=excel replace label;
			sheet="order";
		    newfile= no;
		run;
		%return;
	%end;

	*如文件存在，则将此文件导入;
	%if %sysfunc(fileexist(&inpath.\file_order.xls))   %then %do;
	proc import out = order1
	    datafile = "&inpath.\file_order.xls"
	    dbms = excel replace;
	    sheet = "order";
	    dbdsopts = "firstobs=1";
	run;

	data _null_ ;
		set order1(where=(missing(order) ));
		put "RTF文件(将不会参与RTF的合并):" fname;
	run;
	skip 3;

   *如果数据集观测为0,1,则不进行合并,跳出循环;
	%let dsid=%sysfunc(open(order1));
	%let _checkobs=%sysfunc(attrn(&dsid,nobs));
	%let rc= %sysfunc(close(&dsid));
	%if &_checkobs. eq 0 or &_checkobs. eq 1 %then %return;
	proc sort data=order1(where=(^missing(order) ))  out=add_rtflist1  sortseq=linguistic(numeric_collation=on);by order fname;quit;
	%end;
%end;

*定义filename定义路径便于合并;
data _null_;
	set add_rtflist1  end=last;
   	rtffn=strip("filename rtffn")||strip(_N_)||right(' "')||strip(fname)||strip('" lrecl=5000 ;');
   	call execute(rtffn);
	call symput('ard_rtf'||compress(put(_n_,best.)),strip(fname));
	if last then call symput('maxn',vvalue(_n_));
run;
	skip 3;

%do i=1 %to &maxn.;
/*将文件导入SAS中，变成SAS数据集*/
%put  即将完成对文件：&&ard_rtf&i. 的合并！;

	data have&i. ;
		infile rtffn&i.  truncover;
		informat line $5000.;format line $5000.;length line $5000.;input line $1-5000;
		line=strip(line);
	run;
/*实现三个处理过程：
		1.除首个RTF外，其他RTF第一行的“{”要删除。
		2.除最后一个RTF外，其他RTF最后一行的“}”要删除。
		3.在每个俩个RTF编码间插入一行。这样一行放下面一串代码。
		\sect\sectd\linex0\endnhere\pgwsxn15840\pghsxn12240\lndscpsxn\headery1440\footery1440\marglsxn1440\margrsxn1440\margtsxn1440\margbsxn1440
*/
	%if  &i. eq 1 %then %do;
		data want;
			set have&i. end=last;
			if last then line=substr(strip(line),1,length(strip(line))-1);
		run;
	%end;
	%if  &i. ne 1 %then %do;
		proc sql;
		insert into want(line) values ('\sect\sectd\linex0\endnhere\pgwsxn15840\pghsxn12240\lndscpsxn\headery1440\footery1440\marglsxn1440\margrsxn1440\margtsxn1440\margbsxn1440');
		quit;
		data have&i.;
			set have&i. end=last;
			if last then line=substr(strip(line),1,length(strip(line))-1);
			if _n_=1 then line=substr(line,2);
		run;
		data want;
			set want  have&i. ;
		run;
		%if  &i. eq &maxn. %then %do;
		data want;
			set want end=last;
			if last then line=strip(line)||strip("}");
			%if &pageyn. eq 1 %then %do; /*删除 pgnrestart   即可解决页码错乱问题*/
			if index(line,'\pgnrestart\') then line=compress(tranwrd(line,'\pgnrestart',' '));
			%end;
		run;
		%end;
	%end;
	proc delete data= have&i.;quit;
%end;
/*data want;*/
/*	  set want;*/
/*	  line=tranwrd(line,'\sect\sectd\linex0\endnhere\sbknone\pgwsxn16837\pghsxn11905\lndscpsxn\headery720\footery1440\marglsxn1440\margrsxn1440\margtsxn720\margbsxn1440','');*/
/*	  line=tranwrd(line,'}\par}{\page\par}','}}{\page}');*/
/*	  line=tranwrd(line,'\pard{\par}{\pard\plain\qc{','\pard{}{\pard\plain\qc{');*/
/*	  line=tranwrd(line,'}\par}','}}');*/
/*run;*/

%put  已完成所有文件的合并！;
/*文件输出成合并完成后的RTF*/
	data _null_;
	   set want;
	   file "&outfile." lrecl=5000 ;
	   put line ;
	run;
proc delete data=want;quit;
%mend;


