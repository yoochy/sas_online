/*************************************************************************************************************************
������		:  spec_adam

Ŀ��			:  ����Spec�ӹ��������ݼ�

����˵��:  		

excelname:����Spec����λ��
sheet	 	������sheet���ƣ��������ݼ����ƣ�
metadata 	������metadata�������Ӧ��sheet���ƣ�
inds		: ������Ҫ�޸ı�ǩ�����ݼ�
getvar		���Ƿ��ȡ�������ݼ��еı���
usubjid		: ������Ψһ��ʶ��left join ƥ�����ã�
*�ṩ��ȡ������������Ҫ��WORK�߼�����
%spec_adam(excelname=D:\�ճ���ϰ\Spec_adam\xxxx_adam_spec_xxx.xlsx,sheet=adsl,metadata=metadata,inds=adsl,getvar=1,usubjid=subjid)

__________________________________________________________________________________________________________________________
�汾     ����           �޸���             �޸�����
---     -----------    ------------     ----------------------------------------------------------------------------------
1.0     2019.08.01      setup             ������SAS�������źźţ�
****************************************************************************************************************************************/;

%macro  spec_adam(excelname=,sheet=,metadata=metadata,inds=,getvar=0,usubjid=);
*OPTION ͵�Źر��޸ı������ȳ��ȱ����ľ���
*��֮ǰҪȷ����ı����۲��ʵ�ʳ��Ⱦ��޳�ԽSpec���޶��ĳ���;
options validvarname=upcase varlenchk=nowarn notes;
*�����������ھ�ɾ��������Щ�����;
%symdel _retainlist _relablist _relen _reoder sqlgetlist sqlleftlist/nowarn;
*����metadata����(Ŀ���Ǹ����ݼ����LABEL);
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
*����ָ��Sheet;
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
*ȡ�����������ݼ��ı��� *������ݼ�������¼ ��Ҫĳһ��ָ���۲⣬����Flag������дɸѡ����;
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
	*����˳��;
	select VARIABLE into:_retainlist separated by " " from _label_   ;
	*������ǩ;
	select strip(VARIABLE)||strip("=")||strip(quote(LABEL)) into:_relablist separated by " " from _label_   ;
	*��������;
	select strip(VARIABLE)||" "||ifc(upcase(TYPE)='CHAR',strip('$')||cats(LENGTH)||strip('.'),cats(LENGTH)||strip('.')) 
	into:_relen separated by " " from _label_   ;
	*�۲�˳��;
	select VARIABLE  into: _reoder separated by " " from _label_ where ^missing(SORTORDER)   order by SORTORDER ;
	*ȡ�����������ݼ��ı���;
	%if &getvar. eq 1 %then %do;
	select strip(_sqlselect) into:sqlgetlist separated by "," from _temp_spec  ;
	select strip(_sqlfinal)  into:sqlleftlist separated by " " from _temp_spec  ;
	%end;
quit;

*ȡ�����������ݼ��ı���;
	%if &getvar. eq 1 %then %do;
	proc sql noprint undo_policy=none;
	    create table &inds.  as
	      select &inds..*,&sqlgetlist.
	        from   &inds.  as &inds.
			&sqlleftlist.;
	quit;
	%end;
*����Spec�еı���:�����ݼ����޸ñ���,��ᱨ������δ��ʼ��,���Ժ˲��Ƿ��б�����©;
*�޸ı�����ǩ;
data &inds.;
	set &inds.;;
	label &_relablist.;
	keep &_retainlist.;
run;

*�޸ı�������,���ַ�������vvalue;
data &inds.;
	length &_relen.;
	set &inds.;;
	array  aa(*) _character_;
	do i=1 to dim(aa);
	aa(i)=vvalue(aa(i));
	end;
run;
*���ݼ�����;
proc sort data=&inds. ;by &_reoder.;quit; 

*������ݼ����ַ�������format,informat;
data &sheet.;
	set &inds.;;
	informat _all_;
	format _character_;
run;
*�����ݼ���ӱ�ǩ;
data _null_;
	set _metadata;
	call execute(left("data &sheet.(label=")||quote(strip(DESCRIPTION))||strip(");set &sheet.;run; "));
run;
*��option�޸Ļ�Ĭ��;
option varlenchk=warn;
%symdel _retainlist _relablist _relen _reoder sqlgetlist sqlleftlist/nowarn;
proc delete data=work._label_ _metadata _temp_spec;quit;
%mend;


