/*************************************************************************************************************************
������		:  exp_sas2xls

Ŀ��			:  ���� proc export ���

����˵��		:  	
	
outpath:	����ļ�����
dslist��	������ݼ������б�  sashelp.class\ѧԱ����|sashelp.class
%ds_var2char(inds=sashelp.class,outds=class);

________________________________________________________________________________________________________________________
*
__________________________________________________________________________________________________________________________
�汾     ����           �޸���             �޸�����
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2017.12.28     shun dai                             ����
****************************************************************************************************************************************/;


%macro exp_sas2xls(outpath=,dslist=);

option compress=yes nonotes;
***********************************************************
*����Ҫ��������ݼ�����contents_indx���ݼ���			  *
*1.ȷ����Ҫ��������ݼ�									  *
*2.ȷ�������Sheet										  *
*3.ȷ�����ݼ��۲���										  *
***********************************************************;
data  contents_indx;
	length i 8. lib dsn SheetName  $400. ;
	contents="&dslist.";
	do i=1 to count(contents,'|')+1;
		list=strip(scan("&dslist",i,'|'));
		dsn=strip(scan(list,1,'\'));
		SheetName=strip(scan(list,2,'\'));
		if find(dsn,'.')>0 then do;
			lib=upcase(scan(dsn,1,'.'));
			dsn=upcase(scan(dsn,2,'.'));
		end;
		else do;
			dsn=upcase(scan(dsn,1,'.'));
			lib=upcase('work');
		end;
		if missing(SheetName) then SheetName=dsn;

		output contents_indx;
end;
	keep lib  dsn  SheetName; 
run;
***********************************************************
*�������												  *
***********************************************************;

***********************************************************
*��ֵ�����:׼�����									  *
***********************************************************;

	data contents_indx1;
		set contents_indx end=last;
		call symput('outdsname'||compress(put(_n_,best.)),strip(lib)||strip(".")||strip(dsn));
		call symput('outhtname'||compress(put(_n_,best.)),strip(SheetName));
	    if last then call symput('_loop',compress(put(_n_,best.)));
	run;

%do mlop=1 %to &_loop.;
%ds_var2char(inds=&&outdsname&mlop.,outds=_export_temp_ds,type=1,length=2000);
%put &&outhtname&mlop..;
proc export data= _export_temp_ds
    outfile="&outpath"
	dbms=excel replace ;
    sheet="&&outhtname&mlop.";
    newfile= no;
run;

%end;
option compress=yes notes;

%mend;



%macro ds_var2char(inds=,outds=,type=0,length=500);
proc contents data=&inds. out=ds_cnt_temp(keep=name label varnum) directory noprint memtype=data centiles;
proc sort data=ds_cnt_temp  out=ds_cnt_temp  sortseq=linguistic(numeric_collation=on);by varnum ;
run;
proc sql noprint;
select name into:msvar_temp separated by " " from ds_cnt_temp   ;
select strip(name)||"_c="||"strip(vvalue("||strip(name)||strip("))") into:ys_vas1 separated by " ;" from ds_cnt_temp   ;
select strip(name)||"_c="||strip(name) into:re_vas1 separated by " " from ds_cnt_temp   ;
select strip(name)||"_c" into:msvar_temp2 separated by " " from ds_cnt_temp   ;
quit;
data ds_cnt_temp;
set ds_cnt_temp;
names=name;
labels=label;
run;
proc transpose data=ds_cnt_temp out=ds_cnt_temp1 ;
var  labels names;
id name ;
idlabel label;
run;
data cnts_ds(rename=(&re_vas1.));
length &msvar_temp2. $&length.;
set &inds.;
&ys_vas1.;
drop &msvar_temp.;
run;
data &outds.;
length &msvar_temp. $&length..;
set ds_cnt_temp1(keep=&msvar_temp.)  cnts_ds;
%if &type.=1 %then %do;
if _N_=2 then delete;
%end;

%if &type.=2 %then %do;
if _N_=1 then delete;
%end;

%if &type.=0 %then %do;
if _N_ in (1 2 )then delete;
%end;


run;
proc delete data=ds_cnt_temp1  ds_cnt_temp  cnts_ds  ;quit;
%mend;


