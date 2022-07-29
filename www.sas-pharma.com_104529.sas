/***************************************************************************************************************************************
������		:  ods_excel

Ŀ��		:  ����ods excel�������ݼ������  

����˵��:  		

outpath:	����ļ�����
dslist��	������ݼ������嵥  sashelp.class\ѧԱ����\ѧԱ���������Ϣ\��ϸ��Ϣ|sashelp.class\ȫ������
sheetlist��	���Sheet����
Contents��	�Ƿ�����Ŀ¼
				Y�����Ŀ¼
				N�������Ŀ¼
outds�����Ŀ¼ʱ������ݼ�  Ĭ��Ϊ0
Description :����ȱʧʱ�Ƿ���䣨Ĭ�Ϸ�  
Click:		�Ƿ�ʵ����ת

%ods_excelxp(outpath=G:\�ճ���ϰ\Excel�����\ods Excelxp\tagsets\tagsets\TESTw.xls
,dslist=a\class\ѧ����Ϣ
,ContentsYN=Y,Click=0)

________________________________________________________________________________________________________________________
*
__________________________________________________________________________________________________________________________
�汾     ����           �޸���            				 �޸�����
---     -----------    ------------   		  ----------------------------------------------------------------------------------
1.0     2017.12.28     shun dai                             ����
****************************************************************************************************************************************/;




%macro ods_excelxp(outpath=,dslist=,ContentsYN=Y,outds=1,Description=0,Click=0);
/*options nonotes nosource nosource2;*/

proc template;
	define style ods_excelxp_tp;
	parent=styles.rtf;
		replace fonts / 'TitleFont2'        = ("Courier New", 9pt, medium)
			'TitleFont'         = ("Courier New", 9pt, medium)
			'DocFont'           = ("Courier New", 9pt, medium)
			'StrongFont'        = ("Courier New", 9pt, medium)
			'EmphasisFont'      = ("Courier New", 9pt, Italic)
			'FixedFont'         = ("Courier New", 9pt, medium)
			'BatchFixedFont'    = ("Courier New", 9pt, medium)
			'FixedStrongFont'   = ("Courier New", 9pt, medium)
			'FixedEmphasisFont' = ("Courier New", 9pt, Italic)
			'HeadingFont'       = ("Courier New", 9pt, medium);
		replace table from output / font = ("Courier New", 9pt, medium)
			background = _undef_
			frame = void
			rules = group
			cellspacing = 0.5pt
			cellpadding = 1pt
			outputwidth = 100%;;
		replace cell from output / 
			font = ("Courier New", 9pt, medium) ;
			*�����ͷ;
			style header /
			backgroundcolor=white 
			color=black
			fontweight=bold;
			*������;
			style Table from Output /   cellpadding = 0                                                      
			cellspacing = 0    outputwidth = 100%
			frame = HSIDES			OUTPUTHEIGHT=1;
	 end;
run;



***********************************************************
*����Ҫ��������ݼ�����contents_indx���ݼ���			  *
*1.ȷ����Ҫ��������ݼ�									  *
*2.ȷ�������Sheet										  *
*3.ȷ�����ݼ��۲���										  *
***********************************************************;
data  contents_indx;
	length i 8. lib dsn SheetName Description Comments $400. ;
	contents="&dslist.";
	do i=1 to count(contents,'|')+1;
		list=strip(scan("&dslist",i,'|'));
		dsn=strip(scan(list,1,'\'));
		SheetName=strip(scan(list,2,'\'));
		Description=strip(scan(list,3,'\'));
	if find(dsn,'.')>0 then do;
		lib=upcase(scan(dsn,1,'.'));
		dsn=upcase(scan(dsn,2,'.'));
	end;
	else do;
		dsn=upcase(scan(dsn,1,'.'));
		lib=upcase('work');
	end;
	if missing(SheetName) then SheetName=dsn;
	%if &Description. %then %do;
	if missing(Description) then Description=SheetName;
	%end;

	inlibds=catx('.',lib,dsn);
	dsexist=exist(inlibds);
	if  dsexist=1 then do;
		nobs=attrn(open(inlibds,'i'),'nobs');
/*		rc=close(inlibds);;*/
		if nobs=0 then Comments="There are no observations to listing. ";
	end;
	else if dsexist=0 then do;
		Comments="Plesce check your dataset name";
		nobs=0;
	end;
	if nobs>0 then Comments=left("This Listing have ")||strip(vvalue(nobs))||right(" observations");
	label i="SEQ" lib ="Libname" dsn="DataSet Name"  SheetName="Sheet Name"  Description="Listing Title/(Description)"   Comments="Comments";
output contents_indx;
end;
	keep lib  dsn SheetName  Comments Description  i nobs ; 
run;
***********************************************************
*�������												  *
***********************************************************;
ods path tpt.template(read)  sasuser.templat(read) sashelp.tmplmst(read);
ods listing close;
ods results off;
ods tagsets.excelxp file="&outpath." options(contents="no"  frozen_headers="YES" autofilter='no' absolute_column_width='none' embedded_titles='no' embedded_footnotes='no' ) style=ods_excelxp_tp;
%let ps1=800;
%let ls1=256;
Options ps=&ps1 ls=&ls1 formchar=" ___________" nodate nonumber nocenter;
options notes;
ods tagsets.excelxp  options(zoom="90"   ABSOLUTE_COLUMN_WIDTH=  %if &outds.=1 %then %do;  "2cm,3cm,3cm,8cm,15cm,10cm" %end; %else %do ; "2cm,8cm,15cm,10cm" %end; ORIENTATION= 'LANDSCAPE' FROZEN_ROWHEADERS='2');
 
***********************************************************
*���Ŀ¼												  *
***********************************************************;
%if  &ContentsYN. eq Y  or   &ContentsYN. eq 1 %then %do;
ods tagsets.excelxp  options(sheet_name="Contents"   ) ;
	proc report data=contents_indx  headskip headline nowd  style(header)={just=c asis=on font_weight=bold font_style=italic} ;
		column ("Contents" I  %if &outds.=1 %then %do; LIB dsn %end;  SheetName  Description comments  nobs );
		define  i/display "SEQ"   style=[ just=left tagattr='text' ];
		define SheetName/ display "Sheet Name"  style=[ just=left tagattr='text'];
		define Description/display "Description" style=[ just=left tagattr='text' ] ;
		define comments/computed  display "Comments" style=[ just=left tagattr='text' ] ;
		define nobs/display ;
		define nobs /  noprint;
		compute before  _PAGE_/ style = [ font_style=italic just=l font_weight=bold font_size=8pt borderbottomcolor=black borderbottomwidth=.5pt  background=white ];
		endcomp;
		compute SheetName ;
			if SheetName ne ''  and nobs ne 0  then do;
			urlstring = "#" ||strip(SheetName)|| "!A1";
			call define(_col_, 'URL', urlstring);
			end;
		endcomp;
		compute Description ;
			if Description ne ''  and nobs ne 0 then do;
			urlstring = "#" ||strip(SheetName)|| "!A1";
			call define(_col_, 'URL', urlstring);
			end;
		endcomp;
		compute comments ;
			if comments ne ''  and nobs ne 0 then do;
			urlstring = "#" ||strip(SheetName)|| "!A1";
			call define(_col_, 'URL', urlstring);
			end;
		endcomp;
    run;
%end;
***********************************************************
*��ֵ�����:׼�����									  *
***********************************************************;

	data contents_indx1;
		set contents_indx(where=(nobs^=0))  end=last;
		call symput('outdsname'||compress(put(_n_,best.)),strip(lib)||strip(".")||strip(dsn));
		call symput('outhtname'||compress(put(_n_,best.)),strip(SheetName));
		call symput('outdpname'||compress(put(_n_,best.)),strip(Description));
	    if last then call symput('_loop',compress(put(_n_,best.)));
	run;

***********************************************************
*��ֵ�����:׼�����									  *
***********************************************************;


%do mlop=1 %to &_loop.;
***********************************************************
*zoom�����Ʒ�������
*ABSOLUTE_COLUMN_WIDTH�����Ƶ�Ԫ���ȣ�none,xx cm���ã��Ÿ�����
***********************************************************;

ods tagsets.excelxp  options(zoom="90" ABSOLUTE_COLUMN_WIDTH="3cm"  );
ods tagsets.excelxp  options(sheet_name="&&outhtname&mlop" ) ;
	%ods_excelxp_report(inds=%str(&&outdsname&mlop),title=%str(&&outdpname&mlop),contents=%str(&&outdpname&mlop),flag=%str(0),Contents_Index=%str(Contents));
%end;
ods tagsets.excelxp close;
ods  listing;


%mend;





%macro ods_excelxp_report(inds=%str(),title=%str(),sheetname=%str(),contents=%str(),flag=%str(1),Contents_Index=%str(Contents));
options nofmterr compress=yes missing='';
/*--------    �����������ݼ��Ƿ���ȷ-------------------*/
%local data lib;
%if &inds.= %then %do;
	%put NOTE:plesce check your dataset name;
	%goto exit;
%end;
%if %length(%sysfunc(compress("&inds.","."))) ne %length(%sysfunc(compress("&inds.",""))) %then %do;
	%let lib=%upcase(%scan("&inds.",1,"."));
	%let data=%upcase(%scan("&inds.",2,"."));
%end;
%else %do;
	%let lib=WORK;
	%let data=%upcase(&inds.);
%end;
%put NOTE:&lib. &data.;
proc sql noprint;
	select count(*) into: nvars from &lib..&data;
	select count(*) into: _dssnm from dictionary.columns where libname=%upcase("&lib") and memname=%upcase("&data");
	select distinct name into: dsname1-:dsname%left(&_dssnm) from dictionary.columns where libname=%upcase("&lib") and memname=%upcase("&data");
	select type into: vartype1-:vartype%left(&_dssnm) from dictionary.columns where libname=%upcase("&lib") and memname=%upcase("&data");
quit;
%if &flag.=1 %then %do;
	ods tagsets.excelxp options(sheet_name="&sheetname" ) ;
%end;


	data &data._excl;
		set &lib..&data;
		_tem102_s=.;
	run;
***********************************************************
*������ݼ�Ϊ�գ�����һ����¼							  *
***********************************************************;
%if &nvars=0 %then %do;
	proc sql;
		insert into &data._excl(_tem102_s) values (2 );
	quit;
%end;
	proc report data=&data._excl   headskip headline nowd   contents="&contents." style(header)=
		{just=c asis=on font_weight=bold nobreakspace=off bordertopcolor=black borderbottomcolor=black BORDERRIGHTCOLOR=black bordertopwidth=.5    borderbottomwidth=.5    BORDERRIGHTwidth=.5   } ;
	column ("&title" _ALL_);

	%do _qsloop=1 %to &_dssnm;
		define &&dsname&_qsloop / display style=[ just=left  asis=on tagattr='text'	bordertopcolor=black borderbottomcolor=black BORDERRIGHTCOLOR=black borderbottomwidth=.5 BORDERRIGHTwidth=.5 bordertopcolor=black  bordertopwidth=.5 nobreakspace=off ];
	%end;
	define _tem102_s / display  style(column)=[  just=left tagattr='text' asis=on  ]  ;
	define _tem102_s / noprint ;
	%if &nvars=0 %then %do;
		compute before  / style = [ font_style=italic just=c font_weight=medium font_size=8pt borderbottomcolor=black borderbottomwidth=.5pt  background=white];
			line "There are no observations to report. An empty listing will be created.";	
		endcomp;
	%end;

	%if &Click. eq 1 and (  &ContentsYN. eq Y  or   &ContentsYN. eq 1  )  %then %do;
		compute before  _PAGE_/ style = [font_style=italic just=l font_weight=bold font_size=8pt borderbottomcolor=black borderbottomwidth=.5pt  background=white URL="#&Contents_Index.!A1"];
			line "Click here to return the Contents";	
		endcomp;
	%end;
	run;
	proc delete data=&data._excl;
	quit;

%exit:
%mend;






