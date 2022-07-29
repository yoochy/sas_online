/*************************************************************************************************************************
������		:  chk_log_mn

Ŀ��			:  ��Macro,�������report��

����˵��		:  path		�� ��д·����(����log��·��+�ļ���.log)
			   encoding	�� Log�ı��루�Ա㴦���ڲ�ͬSAS�汾�����\Ĭ������gb2312��
%chk_log_mn(path=D:\�ճ���ϰ\sas_checklog\);
________________________________________________________________________________________________________________________
*options notes;

proc delete data=work._all_;quit;
__________________________________________________________________________________________________________________________
�汾     ����           �޸���            				 �޸�����
---     -----------    ------------   		  ----------------------------------------------------------------------------------
1.0     2018.01.07     shun_dai        					   ����
****************************************************************************************************************************************/;

%macro chk_log_mn(path=,encoding=gb2312);
/**********************************************************
check�ǵ���log�ĺ˲�,���Ƕ��log�ĺͺ˲�
ԭ���ǣ���path��д�˾�����ļ����ƣ���txt ���� Log��׺���ļ����ƣ�
��pathΪһ���ļ�·��ʱ,�Զ�ɨ���ȡ�ļ�·���µ�txt/Log�ļ���
����log����Ϊ���ݼ������ڸ�logȡ��ʱ��Ҫע��.
***********************************************************/
%put NOTE:&path.;
%let file=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&path));
%put NOTE:&file.;

%if %upcase(%qscan(%qscan(&path,-1,'\'),-1,'.'))=TXT  or %upcase(%qscan(%qscan(&path,-1,'\'),-1,'.'))=LOG  %then %do;
%let _mian=%scan(&path,-1,'\');
%put NOTE:&_mian.;
%end;
/**********************************************************
����Pipe��ȱ�ļ������ļ��б�
***********************************************************/
filename xcl_fil pipe "dir &file\*.*/b/s"; 
data _templog;
infile xcl_fil truncover;
input fname $char1000.;
put fname=;
dsn=scan(scan(fname,-1,'\'),1,'.');
/**********************************************************
��symlocal��������Ƿ񴴽���_Main�����
��������򷵻�1��û�д����򷵻�0
/************************************************************/
%if %symlocal(_mian)=1 %then %do;
if find(upcase(fname),upcase("&_mian."))>0  then output;
%end;
%else %if %symlocal(_mian)=0 %then %do;
if find(upcase(fname),'.TXT')>0 or find(upcase(fname),'.LOG')>0   then output;
%end;
;
run;
data _templog2;
length data1 $20000.;
set _templog;
/**********************************************************
����һ��filename ����filename
����call execute ִ�����
���ø�����Macroʵ�ֶ�Log���ݼ��ļӹ�/ɸѡ
***********************************************************/
call execute("filename "||strip(compress("fn"||_N_))||'  "'||strip(fname)||strip('"  encoding=')||left("&encoding.;"));
call symput('N'||compress(put(_n_,best.)),strip(dsn));
run;
%let dsid=%sysfunc(open(_templog2));
%let nobs=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
%do j=1 %to &nobs;
%chk_log_ds(&&N&j.,&j.)
%end;

data contents;
retain LogName;
set %do i=1 %to &nobs.;%sysfunc(compress(&&N&i.._desc))  %end;;
if missing(B_ERROR_) then B_ERROR_=0;
if missing(ERROR) then ERROR=0;
if missing(WARNING) then WARNING=0;
if missing(UNINITIALIZED) then UNINITIALIZED=0;
run;

data _lasttemp;
set contents;
where sum(B_ERROR_,ERROR,WARNING,UNINITIALIZED)^=0;
call symput('M'||compress(put(_n_,best.)),strip(LogName));
run;
%let dsid=%sysfunc(open(_lasttemp));
%let _mloop=%sysfunc(attrn(&dsid,nobs));
%let rc= %sysfunc(close(&dsid));
/**********************************************************
�������
***********************************************************/;
ods path tpt.template(read)  sasuser.templat(read) sashelp.tmplmst(read);
ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="&file.\ Log report.xlsx" options(contents="no"  FROZEN_HEADERS="Yes" autofilter='all' ) style=tag_1;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=800;
%let ls1=256;
Options ps=&ps1 ls=&ls1  nodate nonumber nocenter;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 
ods excel options(sheet_name="Contents_Index"  START_AT='D4') ;

proc report data=contents  headskip headline nowd  
style(header)={just=c asis=on font_weight=bold font_style=italic} ;
column ("Contents of Table" LogName ERROR B_ERROR_ WARNING UNINITIALIZED);
define LogName/ computed display style=[ just=left tagattr='text'  cellwidth=15% ] ;
define ERROR/ display "ERROR" style=[ just=left tagattr='text' cellwidth=15% ] ;
define B_ERROR_/  display "^__ERROR_"  style=[ just=left tagattr='text' cellwidth=15% ];
define WARNING/ display style=[ just=left tagattr='text' cellwidth=15%] ;
define UNINITIALIZED/ display style=[ just=left tagattr='text' cellwidth=15%] ;

compute LogName ;
if LogName ne '' and  sum(B_ERROR_,ERROR,WARNING,UNINITIALIZED) ne 0  then do;
urlstring = "#" ||strip(LogName)|| "!A1";
call define(_col_, 'URL', urlstring);
end;
endcomp;
run;
ods excel options(START_AT='A1' ) ;

%do mlop=1 %to &_mloop.;
ods excel options(sheet_name="&&M&mlop" ) ;
proc report data=&&M&mlop.   headskip headline nowd   contents="Contents_Index." ;
column ("��־����" _ALL_);
define line /  display style=[ just=left tagattr='text'  cellwidth=4% ] ;
define type / computed display style=[ just=left tagattr='text'  cellwidth=15% ] ;
define desc /  display  "Description" style=[ just=left tagattr='text'  cellwidth=80% ] ;
compute type ;
if type  eq "ERROR"  then do;
call define(_ROW_,"style","style={  foreground=RED  }"); 
end;
if type  eq "_ERROR_"  then do;
call define(_ROW_,"style","style={  foreground=black }"); 
end;
if type  eq "WARNING"  then do;
call define(_ROW_,"style","style={  foreground=Green }"); 
end;
if type  eq "UNINITIALIZED"  then do;
call define(_ROW_,"style","style={  foreground=Blue  }"); 
end;
endcomp;
run;
%end;
proc delete data=work._lasttemp   _templog _templog2 ;quit;
ods excel close;
ods  listing;
%mend;

