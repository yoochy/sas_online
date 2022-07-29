/*************************************************************************************************************************
宏名称		:  spec_adam

目的			:  依据Spec加工分析数据集

参数说明:  		

excelname:输入Spec所在位置
sheet	 	：导入sheet名称（分析数据集名称）
metadata 	：导入metadata（输入对应的sheet名称）
inds		: 输入需要修改标签的数据集
getvar		：是否获取其他数据集中的变量
usubjid		: 受试者唯一标识（left join 匹配是用）
*提供获取变量的数据需要在WORK逻辑库下
%spec_adam(excelname=D:\日常练习\Spec_adam\xxxx_adam_spec_xxx.xlsx,sheet=adsl,metadata=metadata,inds=adsl,getvar=1,usubjid=subjid)

__________________________________________________________________________________________________________________________
版本     日期           修改人             修改描述
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2019.08.01      setup             创建（SAS程序分享号号号）
****************************************************************************************************************************************/;

%macro  spec_adam(excelname=,sheet=,metadata=metadata,inds=,getvar=0,usubjid=);
*OPTION 偷着关闭修改变量长度长度报出的警告
*用之前要确保你的变量观测的实际长度均无超越Spec中限定的长度;
options validvarname=upcase varlenchk=nowarn notes;
*如果宏变量存在就删除下面这些宏变量;
%symdel _retainlist _relablist _relen _reoder sqlgetlist sqlleftlist/nowarn;
*导入metadata数据(目的是给数据集添加LABEL);
proc import out=_metadata(where=(upcase(strip(DOMAIN))=upcase(strip("&sheet."))))
	datafile= "&excelname." 
	dbms=excel replace;
	range="&metadata.$"; 
	getnames=yes;
	mixed=no;
	scantext=yes;
	usedate=yes;
	scantime=yes;
run;
*导入指定Sheet;
proc import out=_label_(where=(^missing(VARIABLE)))
	datafile= "&excelname." 
	dbms=excel replace;
	range="&sheet.$"; 
	getnames=yes;
	mixed=no;
	scantext=yes;
	usedate=yes;
	scantime=yes;
run;
*取来自其他数据集的变量 *如果数据集多条记录 需要某一条指定观测，则在Flag里面填写筛选条件;
data _temp_spec;
	set _label_;
	if ^missing(FLAG);
	_sqlds=scan(SOURCE_ALGORITHM,1,'.');
	_sqlvar=scan(SOURCE_ALGORITHM,2,'.');
	_sqlselect=compbl(strip(_sqlds)||strip(put(_n_,z4.))||strip(".")||strip(_SQLVAR)||" as "||strip(VARIABLE));
	_sqlfinal=compbl(left("left join ")||strip(_sqlds)||ifc(length(FLAG)>1,"(where=("||strip(FLAG)||left(")) as ")," as ")
	||strip(_sqlds)||strip(put(_n_,z4.))||" on  &inds..&usubjid.="||strip(_sqlds)||strip(put(_n_,z4.))||strip(".&usubjid."));
	keep VARIABLE SOURCE_ALGORITHM FLAG _sqlselect _sqlfinal;
run;
proc sql noprint;
	*变量顺序;
	select VARIABLE into:_retainlist separated by " " from _label_   ;
	*变量标签;
	select strip(VARIABLE)||strip("=")||strip(quote(LABEL)) into:_relablist separated by " " from _label_   ;
	*变量属性;
	select strip(VARIABLE)||" "||ifc(upcase(TYPE)='CHAR',strip('$')||cats(LENGTH)||strip('.'),cats(LENGTH)||strip('.')) 
	into:_relen separated by " " from _label_   ;
	*观测顺序;
	select VARIABLE  into: _reoder separated by " " from _label_ where ^missing(SORTORDER)   order by SORTORDER ;
	*取来自其他数据集的变量;
	%if &getvar. eq 1 %then %do;
	select strip(_sqlselect) into:sqlgetlist separated by "," from _temp_spec  ;
	select strip(_sqlfinal)  into:sqlleftlist separated by " " from _temp_spec  ;
	%end;
quit;

*取来自其他数据集的变量;
	%if &getvar. eq 1 %then %do;
	proc sql noprint undo_policy=none;
	    create table &inds.  as
	      select &inds..*,&sqlgetlist.
	        from   &inds.  as &inds.
			&sqlleftlist.;
	quit;
	%end;
*保留Spec中的变量:若数据集中无该变量,则会报出变量未初始化,用以核查是否有变量遗漏;
*修改变量标签;
data &inds.;
	set &inds.;;
	label &_relablist.;
	keep &_retainlist.;
run;

*修改变量长度,对字符变量用vvalue;
data &inds.;
	length &_relen.;
	set &inds.;;
	array  aa(*) _character_;
	do i=1 to dim(aa);
	aa(i)=vvalue(aa(i));
	end;
run;
*数据集排序;
proc sort data=&inds. ;by &_reoder.;quit; 

*清除数据集中字符变量的format,informat;
data &sheet.;
	set &inds.;;
	informat _all_;
	format _character_;
run;
*给数据集添加标签;
data _null_;
	set _metadata;
	call execute(left("data &sheet.(label=")||quote(strip(DESCRIPTION))||strip(");set &sheet.;run; "));
run;
*将option修改回默认;
option varlenchk=warn;
%symdel _retainlist _relablist _relen _reoder sqlgetlist sqlleftlist/nowarn;
proc delete data=work._label_ _metadata _temp_spec;quit;
%mend;


