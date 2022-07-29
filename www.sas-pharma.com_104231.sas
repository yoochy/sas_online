*****************************************************************************

作者：setup
时间：20200706
描述：SAS制表

	
******************************************************************************;

proc delete data=work._all_;quit;
%macro setpaths;
%global setup_ runsetup runsetup1 runsetup2 ;
%let setup_= %upcase(%sysget(sas_execfilepath));
%let runsetup=%sysfunc(prxchange(s/(.*)\\.*/\1/,-1,&setup_));
%let runsetup1=%sysfunc(prxchange(s/(.*)\\.*/\1/,-1,&runsetup));
%let runsetup2=%sysfunc(prxchange(s/(.*)\\.*/\1/,-1,&runsetup1));
proc datasets library=work kill nolist;
quit;
%put &runsetup2.;
%put &runsetup1.;
%put &runsetup.;

%mend;
dm log 'clear' ;
dm output 'clear' ;  
options nomprint nocenter nosymbolgen orientation=landscape nodate nonumber nobyline missing = ' ' nomlogic 
formchar="|----|+|---+=|-/\<>*" validvarname=upcase nofmterr
mrecall noxwait nosource nosource2  ;
options extendobscounter=no compress=yes;
option minoperator mindelimiter=',';

%setpaths;





proc template;
define style threelines_setup;
parent = styles.rtf;
replace	 fonts /                                                         
	"TitleFont2" = ("宋体",9pt) 
	"TitleFont" = ("宋体",9pt)  
	"StrongFont" = ("宋体",9pt,Bold) 
	"EmphasisFont" = ("宋体",9pt,Italic)                                                              
	"FixedEmphasisFont" = ("宋体",9pt,Italic)                                                              
	"FixedStrongFont" = ("宋体",9pt)  
	"FixedHeadingFont" = ("宋体",10pt)      
	"BatchFixedFont" = ("宋体",10pt)        
	"FixedFont" = ("宋体",9pt)             
	"headingEmphasisFont" = ("宋体",10pt,Bold Italic)                                                      
	"headingFont" = ("宋体",10pt,Bold)
	"docFont" = ("宋体",9pt);

class GraphFonts /
	'NodeDetailFont' = ("宋体",10pt)
	'NodeInputLabelFont' = ("宋体",10pt)
	'NodeLabelFont' = ("宋体",10pt)
	'NodeTitleFont' = ("宋体",10pt)
	'GraphDataFont' = ("宋体",10pt)
	'GraphUnicodeFont' = ("宋体",9pt)
	'GraphValueFont' = ("宋体",10pt)
	'GraphLabel2Font' = ("宋体",10pt)
	'GraphLabelFont' = ("宋体",11pt)
	'GraphFootnoteFont' = ("宋体",11pt)
	'GraphTitleFont' = ("宋体",10pt)
	'GraphTitle1Font' = ("宋体",10pt)
	'GraphAnnoFont' = ("宋体",10pt);


replace Header from HeadersandFooters / font = ("宋体", 9pt, medium) 
	background = _undef_
	protectspecialchars = off;
	replace table from output / font = ("宋体", 9pt, medium)
	background = _undef_
	frame = void
	rules = group
	cellspacing = 0.5pt
	cellpadding = 1pt
	outputwidth = 100%;;
	replace cell from output / 
	font = ("宋体", 9pt, medium) ;
	*定义表头;
	style header /
		backgroundcolor=white 
		color=black
		fontweight=bold;

*定义文件的布局;
style body from document / 
	bottommargin = 15mm
	topmargin = 15mm
	rightmargin = 15mm
	leftmargin = 15 mm;

*定义表格;
style Table from Output /   
	cellpadding = 0                                                      
	cellspacing = 0                                                     
	outputwidth = 100%
	frame = HSIDES
	OUTPUTHEIGHT=1;

end;
run;

data _null_;
	call symput("date",left(put("&sysdate"d,yymmdd10.)));
	call symput("date1",left(compress(put("&sysdate"d,yymmdd10.),"-"," ")));
run;

ods rtf file="&runsetup.\RTF_Output_all_setup.rtf" style=threelines_setup startpage=no;
ODS graphics on /width=18cm height=10cm noborder ;
ods  rtf nogtitle nogfootnote;

title1 j= l 	"官网：https://www.sas-pharma.com" j= r "作者：Setup";
title2 j= l 	"微信号：xiaocgn" j= r"日期：&date1.";
footnote j= l 	"SAS制表" 	j= r "欢迎关注公众号";
ods rtf exclude none;

data class;
		length Setup text desc $10000.;
		text="Setup的测试";
		setup=text;
		desc="无插入";
		output;
		setup="(*ESC*)R/RTF'\tab "||strip(text);*缩进多种方式:1;
		desc="采用\tab缩进";
		output;
		setup="(*ESC*)R/RTF'\u32?\u32?\u32?\u32? "||strip(text);*缩进多种方式:2;
		desc="采用\u32缩进";
		output;
		setup="(*ESC*)R/RTF'\b "||strip(text);*字体加粗;
		desc="采用\b控制字体粗细";
		output;
		setup="(*ESC*)R/RTF'\fs24 "||strip(text);*字体大小;
		desc="采用\fs控制字体大小";
		output;
		setup="setup (*ESC*)R/RTF'{\fs32\b ssss} "||strip(text);*利用{}控制文本局部变化;
		desc="采用\fs控制字体大小,利用{}控制文本局部变化";
		output;
		setup="setup (*ESC*)R/RTF'{\sub ssss} "||strip(text);*上角标控制;
		desc="采用\sub控制角标";
		output;
		setup="22setup (*ESC*)R/RTF'{\super 2} "||strip(text);*下角标控制;
		desc="采用\super";
		output;
		setup="setup (*ESC*)R/RTF'\par "||strip(text);*文本换行;
		desc="采用\par文本换行";
		output;
		setup="setup (*ESC*)R/RTF'\brdrb\brdrs "||strip(text);*下划线;
		desc="采用\brdrb\brdrs实现下划线";
		output;
		setup="(*ESC*){unicode '03bc'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '006f'x}(*ESC*){unicode '006c'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '004c'x}";*特殊符号;
		desc="Unicode 表达特殊符号";
		output;
		setup="(*ESC*){unicode '006b'x}(*ESC*){unicode '0067'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '00b2'x}";
		desc="Unicode 表达特殊符号";
		output;
		setup="(*ESC*){unicode '0068'x}(*ESC*){unicode '0074'x}(*ESC*){unicode '0074'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '003a'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '0077'x}(*ESC*){unicode '0077'x}(*ESC*){unicode '0077'x}(*ESC*){unicode '002e'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '002d'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0072'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '002e'x}(*ESC*){unicode '0063'x}(*ESC*){unicode '006f'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '002d'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0072'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '0075'x}(*ESC*){unicode '006e'x}(*ESC*){unicode '0069'x}(*ESC*){unicode '0063'x}(*ESC*){unicode '006f'x}(*ESC*){unicode '0064'x}(*ESC*){unicode '0065'x}(*ESC*){unicode '0063'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0067'x}(*ESC*){unicode '002e'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0070'x}";*特殊符号;
		desc="Unicode 表达文本";
		output;
run;

proc report data=class nowd headskip headline split='|' missing nocenter;
	  column setup desc ;
	  define setup / display "展现" style(header)=[just=left] style(column)=[just=left cellwidth=20% asis=on] flow;
	  define desc / display "描述"   style(header)=[just=left] style(column)=[cellwidth=80% just=left asis=on] flow;

run;



ods rtf close;




