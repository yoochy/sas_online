/*************************************************************************************************************************
������		:  rtf_merge

Ŀ��			:  ����RTF�ļ��ĺϲ�

����˵��		:  	
	
*
inpath 		����ļ���
outfile		ͳ�ƺ�������ݼ�
order       ����˳��
pageyn		ҳ�����������Ĭ��Ϊ1����������


%rtf_merge(inpath=D:\xxxxxx\Project\test,
	outfile=D:\xxxxxx\Project\test\test\all.rtf,
	order=1,pageyn=1);


____________________________________________________________________________________________________________________
/****************************************************************************************************************************************
__________________________________________________________________________________________________________________________
�汾     ����           �޸���             					�޸�����
---     -----------    ------------    	 ----------------------------------------------------------------------------------
1.0     2018.11.14      SAS�������źźţ�xiaocgn��           ����
****************************************************************************************************************************************/;

%macro   rtf_mergeV1(inpath=,outfile=,order=0,pageyn=1);
  %let ps1=800;
  %let ls1=256;
options ps=&ps1 ls=&ls1  nonotes  nosource nosource2   ;
skip 5;
*��ȡָ��·�����ļ�����RTF�ļ�����;
filename xcl_fil pipe "dir &inpath.\*.rtf /b/s"; 
data add_rtflist;
   infile xcl_fil truncover;
   input fname $char1000.;
   order=.;
run;
*Ĭ�����ļ������������ű�;
proc sort data=add_rtflist  out=add_rtflist1  sortseq=linguistic(numeric_collation=on);by fname ;quit;

*�ж��Ƿ���Ҫ�˹�����;
*��orderΪ1ʱ����Ҫ��������ͬʱ����step�ж��Ƿ���Ҫ���ļ����������ⲿExcel�����˹��ֶ����˳��;

%if  &order. eq  1 %then %do;
*�жϴ��ϲ�RTF�ļ���������file_order.xls�ļ������RTF�ļ��ϲ��Ⱥ�������б�
	*���ޣ������ɴ��ļ����˳����ִ��;
	%if %sysfunc(fileexist(&inpath.\file_order.xls))=0   %then %do;
skip 2;
		%put *�����order=1,������&inpath.\file_order.xls�ļ�δ����,ϵͳ���Զ����ɴ��ļ����˳���ǰ�����ִ�У�;
		%put *�����˹���ɴ��ļ��ı༭���ٴ�ִ�д˳���;
		proc export data= add_rtflist1
		    outfile="&inpath.\file_order.xls"
			dbms=excel replace label;
			sheet="order";
		    newfile= no;
		run;
		%return;
	%end;

	*���ļ����ڣ��򽫴��ļ�����;
	%if %sysfunc(fileexist(&inpath.\file_order.xls))   %then %do;
	proc import out = order1
	    datafile = "&inpath.\file_order.xls"
	    dbms = excel replace;
	    sheet = "order";
	    dbdsopts = "firstobs=1";
	run;

	data _null_ ;
		set order1(where=(missing(order) ));
		put "RTF�ļ�(���������RTF�ĺϲ�):" fname;
	run;
	skip 3;

   *������ݼ��۲�Ϊ0,1,�򲻽��кϲ�,����ѭ��;
	%let dsid=%sysfunc(open(order1));
	%let _checkobs=%sysfunc(attrn(&dsid,nobs));
	%let rc= %sysfunc(close(&dsid));
	%if &_checkobs. eq 0 or &_checkobs. eq 1 %then %return;
	proc sort data=order1(where=(^missing(order) ))  out=add_rtflist1  sortseq=linguistic(numeric_collation=on);by order fname;quit;
	%end;
%end;

*����filename����·�����ںϲ�;
data _null_;
	set add_rtflist1  end=last;
   	rtffn=strip("filename rtffn")||strip(_N_)||right(' "')||strip(fname)||strip('" lrecl=5000 ;');
   	call execute(rtffn);
	call symput('ard_rtf'||compress(put(_n_,best.)),strip(fname));
	if last then call symput('maxn',vvalue(_n_));
run;
	skip 3;

%do i=1 %to &maxn.;
/*���ļ�����SAS�У����SAS���ݼ�*/
%put  ������ɶ��ļ���&&ard_rtf&i. �ĺϲ���;

	data have&i. ;
		infile rtffn&i.  truncover;
		informat line $5000.;format line $5000.;length line $5000.;input line $1-5000;
		line=strip(line);
	run;
/*ʵ������������̣�
		1.���׸�RTF�⣬����RTF��һ�еġ�{��Ҫɾ����
		2.�����һ��RTF�⣬����RTF���һ�еġ�}��Ҫɾ����
		3.��ÿ������RTF��������һ�С�����һ�з�����һ�����롣
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
			%if &pageyn. eq 1 %then %do; /*ɾ�� pgnrestart   ���ɽ��ҳ���������*/
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

%put  ����������ļ��ĺϲ���;
/*�ļ�����ɺϲ���ɺ��RTF*/
	data _null_;
	   set want;
	   file "&outfile." lrecl=5000 ;
	   put line ;
	run;
proc delete data=want;quit;
%mend;


