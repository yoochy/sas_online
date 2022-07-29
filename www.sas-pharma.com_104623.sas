/*



libname  test "E\Data";
lib 输入逻辑库
%chklib_var_len(lib=test);
setup出品
https://www.sas-pharma.com
*/



options nofmterr compress=yes  validvarname=upcase ;

*计算 输入数据集的每个变量真实的最大长度;
%macro  chk_var_len(inds);
%local libname memname;
%if &inds.= %then %do;
   %put NOTE:plesce check your dataset name;
   %return;
%end;
%if %length(%sysfunc(compress("&inds.","."))) ne %length(%sysfunc(compress("&inds.",""))) %then %do;
   %let libname=%scan("&inds.",1,".");
   %let memname=%scan("&inds.",2,".");
%end;
%else %do;
   %let libname=WORK;
   %let memname=&inds.;
%end;
proc sql noprint;
select  strip("MAX(length(")||strip(NAME)||strip("))")||"  as  "||strip("len_")||strip(NAME) into:varlist separated by "," from sashelp.vcolumn
where libname=upcase("&libname.") and memname=upcase("&memname.")  and type='char'  ;
quit;

proc sql undo_policy=none;
create table tp1_&memname. as select distinct &varlist. from  &inds.  ;
quit;
proc transpose data=tp1_&memname. out=tp1_&memname. ;
var _all_;
run;
data tp1_&memname.;
	set tp1_&memname.;
	length  domain var $200.;
	domain=upcase("&memname.");
	var=substr(_NAME_,5);
	drop _NAME_;
run;

%mend;


%macro chklib_var_len(lib=);
*利用循环得到每个数据集 每个变量的最大长度 ;
proc sql noprint;
	select count(distinct memname) into: nn from dictionary.columns where libname=upcase("&lib.");
	select distinct memname into:mem1-:mem%left(&nn.) from dictionary.columns where libname=upcase("&lib.");
quit;
%do i=1 %to &nn;
	%chk_var_len(inds=&lib..&&mem&i.)
%if &i=1 %then %do;
	data temp1;
		set tp1_&&mem&i.;
	run;
	%end;
%if &i.>1 %then %do;
	data temp1;
		set temp1 tp1_&&mem&i.;
	run;
	%end;
%end;
proc datasets lib=work memtype=data noprint;
delete   tp1_:;
run;
quit;
*得到长度存入temp1数据集后;
proc contents data=&lib.._all_ out=_varstemp10(keep=LIBNAME memname NAME LABEL type Varnum length) DIRECTORY NOPRINT MEMTYPE=data CENTILES;
proc sort data=_varstemp10  out=_varstemp10  sortseq=linguistic(numeric_collation=on);by memname Varnum ;
run;

proc sql ;
*计算最大长度;
	create table _varstemp11 as
	select  *,max(COL1) as newlen
	from  temp1 group by var;
*并入全部变量列表中;
	create table _varstemp12 as
	select  LIBNAME,memname,strip(NAME)||" "||ifc(^missing(newlen),strip("$")||strip(put(newlen,8.))||strip('.'),strip(put(LENGTH,8.))||strip('.')) as final
	from  _varstemp10  as a
	left join   _varstemp11 as b
	on a.memname =b.domain 
	and a.NAME =b.var 
	order by memname,Varnum;
quit;
*修改长度不用报警告;
options varlenchk=nowarn;

data _null_;
	set _varstemp12;
	length news  fmt $20000.;
	retain news fmt;
	by memname notsorted;
	if first.memname then  do;news=strip(final);
	if index(final,'$') then fmt=strip(final);
	else fmt="";
	end;
	else do news=strip(news)||" "||strip(final);
	if index(final,'$') then fmt=strip(fmt)||" "||strip(final);
	end;
	if last.memname then call execute("data "||memname||"; length "||strip(news)||
	"; format "||strip(fmt)||
	"; informat "||strip(fmt)||
	";set "||strip(LIBNAME)||strip(".")||strip(memname)||strip(";run;"));
run;


proc datasets lib=work memtype=data noprint;
delete   _varstemp:;
run;
quit;
%mend;

