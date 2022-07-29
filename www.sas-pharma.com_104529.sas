/***************************************************************************************************************************************
宏名称		:  ods_excel

目的		:  采用ods excel进行数据集的输出  

参数说明:  		

outpath:	输出文件名称
dslist：	输出数据集名称清单  sashelp.class\学员资料\学员资料相关信息\详细信息|sashelp.class\全分析集
sheetlist：	输出Sheet名称
Contents：	是否生成目录
				Y：输出目录
				N：不输出目录
outds：输出目录时输出数据集  默认为0
Description :描述缺失时是否填充（默认否）  
Click:		是否实现跳转

%ods_excelxp(outpath=G:\日常练习\Excel的输出\ods Excelxp\tagsets\tagsets\TESTw.xls
,dslist=a\class\学生信息
,ContentsYN=Y,Click=0)

________________________________________________________________________________________________________________________
*
__________________________________________________________________________________________________________________________
版本     日期           修改人            				 修改描述
---     -----------    ------------   		  ----------------------------------------------------------------------------------
1.0     2017.12.28     shun dai                             创建
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
			*定义表头;
			style header /
			backgroundcolor=white 
			color=black
			fontweight=bold;
			*定义表格;
			style Table from Output /   cellpadding = 0                                                      
			cellspacing = 0    outputwidth = 100%
			frame = HSIDES			OUTPUTHEIGHT=1;
	 end;
run;



***********************************************************
*将需要输出的数据集存入contents_indx数据集中			  *
*1.确定需要输出的数据集									  *
*2.确定输出的Sheet										  *
*3.确定数据集观测数										  *
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
*设置输出												  *
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
*输出目录												  *
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
*赋值宏变量:准备输出									  *
***********************************************************;

	data contents_indx1;
		set contents_indx(where=(nobs^=0))  end=last;
		call symput('outdsname'||compress(put(_n_,best.)),strip(lib)||strip(".")||strip(dsn));
		call symput('outhtname'||compress(put(_n_,best.)),strip(SheetName));
		call symput('outdpname'||compress(put(_n_,best.)),strip(Description));
	    if last then call symput('_loop',compress(put(_n_,best.)));
	run;

***********************************************************
*赋值宏变量:准备输出									  *
***********************************************************;


%do mlop=1 %to &_loop.;
***********************************************************
*zoom：控制放缩比例
*ABSOLUTE_COLUMN_WIDTH：控制单元格宽度（none,xx cm或用，号隔开）
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
/*--------    检查输入的数据集是否正确-------------------*/
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
*如果数据集为空：插入一条记录							  *
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






