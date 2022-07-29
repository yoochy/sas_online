*****************************************************************************

���ߣ�setup
ʱ�䣺20200706
������SAS�Ʊ�

	
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
	"TitleFont2" = ("����",9pt) 
	"TitleFont" = ("����",9pt)  
	"StrongFont" = ("����",9pt,Bold) 
	"EmphasisFont" = ("����",9pt,Italic)                                                              
	"FixedEmphasisFont" = ("����",9pt,Italic)                                                              
	"FixedStrongFont" = ("����",9pt)  
	"FixedHeadingFont" = ("����",10pt)      
	"BatchFixedFont" = ("����",10pt)        
	"FixedFont" = ("����",9pt)             
	"headingEmphasisFont" = ("����",10pt,Bold Italic)                                                      
	"headingFont" = ("����",10pt,Bold)
	"docFont" = ("����",9pt);

class GraphFonts /
	'NodeDetailFont' = ("����",10pt)
	'NodeInputLabelFont' = ("����",10pt)
	'NodeLabelFont' = ("����",10pt)
	'NodeTitleFont' = ("����",10pt)
	'GraphDataFont' = ("����",10pt)
	'GraphUnicodeFont' = ("����",9pt)
	'GraphValueFont' = ("����",10pt)
	'GraphLabel2Font' = ("����",10pt)
	'GraphLabelFont' = ("����",11pt)
	'GraphFootnoteFont' = ("����",11pt)
	'GraphTitleFont' = ("����",10pt)
	'GraphTitle1Font' = ("����",10pt)
	'GraphAnnoFont' = ("����",10pt);


replace Header from HeadersandFooters / font = ("����", 9pt, medium) 
	background = _undef_
	protectspecialchars = off;
	replace table from output / font = ("����", 9pt, medium)
	background = _undef_
	frame = void
	rules = group
	cellspacing = 0.5pt
	cellpadding = 1pt
	outputwidth = 100%;;
	replace cell from output / 
	font = ("����", 9pt, medium) ;
	*�����ͷ;
	style header /
		backgroundcolor=white 
		color=black
		fontweight=bold;

*�����ļ��Ĳ���;
style body from document / 
	bottommargin = 15mm
	topmargin = 15mm
	rightmargin = 15mm
	leftmargin = 15 mm;

*������;
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

title1 j= l 	"������https://www.sas-pharma.com" j= r "���ߣ�Setup";
title2 j= l 	"΢�źţ�xiaocgn" j= r"���ڣ�&date1.";
footnote j= l 	"SAS�Ʊ�" 	j= r "��ӭ��ע���ں�";
ods rtf exclude none;

data class;
		length Setup text desc $10000.;
		text="Setup�Ĳ���";
		setup=text;
		desc="�޲���";
		output;
		setup="(*ESC*)R/RTF'\tab "||strip(text);*�������ַ�ʽ:1;
		desc="����\tab����";
		output;
		setup="(*ESC*)R/RTF'\u32?\u32?\u32?\u32? "||strip(text);*�������ַ�ʽ:2;
		desc="����\u32����";
		output;
		setup="(*ESC*)R/RTF'\b "||strip(text);*����Ӵ�;
		desc="����\b���������ϸ";
		output;
		setup="(*ESC*)R/RTF'\fs24 "||strip(text);*�����С;
		desc="����\fs���������С";
		output;
		setup="setup (*ESC*)R/RTF'{\fs32\b ssss} "||strip(text);*����{}�����ı��ֲ��仯;
		desc="����\fs���������С,����{}�����ı��ֲ��仯";
		output;
		setup="setup (*ESC*)R/RTF'{\sub ssss} "||strip(text);*�ϽǱ����;
		desc="����\sub���ƽǱ�";
		output;
		setup="22setup (*ESC*)R/RTF'{\super 2} "||strip(text);*�½Ǳ����;
		desc="����\super";
		output;
		setup="setup (*ESC*)R/RTF'\par "||strip(text);*�ı�����;
		desc="����\par�ı�����";
		output;
		setup="setup (*ESC*)R/RTF'\brdrb\brdrs "||strip(text);*�»���;
		desc="����\brdrb\brdrsʵ���»���";
		output;
		setup="(*ESC*){unicode '03bc'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '006f'x}(*ESC*){unicode '006c'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '004c'x}";*�������;
		desc="Unicode ����������";
		output;
		setup="(*ESC*){unicode '006b'x}(*ESC*){unicode '0067'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '00b2'x}";
		desc="Unicode ����������";
		output;
		setup="(*ESC*){unicode '0068'x}(*ESC*){unicode '0074'x}(*ESC*){unicode '0074'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '003a'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '0077'x}(*ESC*){unicode '0077'x}(*ESC*){unicode '0077'x}(*ESC*){unicode '002e'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '002d'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0072'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '002e'x}(*ESC*){unicode '0063'x}(*ESC*){unicode '006f'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0073'x}(*ESC*){unicode '002d'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '0072'x}(*ESC*){unicode '006d'x}(*ESC*){unicode '0061'x}(*ESC*){unicode '002f'x}(*ESC*){unicode '0075'x}(*ESC*){unicode '006e'x}(*ESC*){unicode '0069'x}(*ESC*){unicode '0063'x}(*ESC*){unicode '006f'x}(*ESC*){unicode '0064'x}(*ESC*){unicode '0065'x}(*ESC*){unicode '0063'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0067'x}(*ESC*){unicode '002e'x}(*ESC*){unicode '0070'x}(*ESC*){unicode '0068'x}(*ESC*){unicode '0070'x}";*�������;
		desc="Unicode ����ı�";
		output;
run;

proc report data=class nowd headskip headline split='|' missing nocenter;
	  column setup desc ;
	  define setup / display "չ��" style(header)=[just=left] style(column)=[just=left cellwidth=20% asis=on] flow;
	  define desc / display "����"   style(header)=[just=left] style(column)=[cellwidth=80% just=left asis=on] flow;

run;



ods rtf close;




