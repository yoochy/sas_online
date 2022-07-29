/*
 * ========================================================================================================================================
 *           
 *             �ļ���: Contents.sas
 *           
 *           ����˵��:			 
  					  ODS PDF ����ĵ������� Proc document���̲�+Proc report���̲����ʵ�������
							1.Proc document����Ŀ¼ҳ������/�ĵ��Ĵ�����
					  		2.Proc report�����ĵ����ݵ����
					  �ص㣺��ֱ������Ŀ¼ҳ��������ĵ������ֶ�����

					  ODS RTF ����ĵ���Proc Report����ֱ����Ƕ��ODS RTF��
					  �ص㣺ODS RTF�������ӵ���ڶ������ѡ���ڸ�ʽ����������ODS PDF����Ŀ¼ҳ��������SASHELPָ���в���contentsѡ�
					  ����Ŀ¼������ĵ����и���Ŀ¼������RTF���������ͨ������һ�ַ�ʽ���ɣ�����RTF�������\outlinelevel�������ñ��⼶�𣬿��ֶ��Զ���Ŀ¼��
					  ������Ŀ¼���ɵ������ַ�ʽ��֧�֡�����ODS PDF��ȣ��˴����ֶ��������Բ��㡣����������ODS PDF���ODS RTFǿ��

*               
*======================================================================================================================================== 
* 
*               ����:Setup 
*               ����:setup@mail.sas-pharma.com 
*               ��վ:https://www.sas-pharma.com 
*               ΢�ź�:gongnxc 
*               ΢�Ź��ں�:SAS�������źźţ�xiaocgn�� 
*
* ========================================================================================================================================
*/ 



proc template;
	define style tp;
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
	replace Header from HeadersandFooters / font = ("����", 9pt, medium) 
		background = _undef_
		protectspecialchars = off;
	replace table from output / font = ("����", 9pt, medium)
		background = _undef_
		frame = void
		rules = none
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
   class Contents /
      liststyletype = "decimal"
      tagattr = " onload=""expandAll()"""
      pagebreakhtml = html('break')
      color = colors('contentfg')
      backgroundcolor = colors('contentbg')
      marginright = 0
      marginleft = 0;
/*����Ŀ¼����*/
   style ContentTitle from IndexTitle
      "Controls the title of the Contents file." /
      fillrulewidth = 0pt 
      marginright = 1em
      marginleft = 1em
      width = 100%
      marginbottom = 0ex
      margintop = 0ex
      font = ("����",12pt,Bold)  /*Ŀ¼����*/
  	   pretext = "(*ESC*){style   
	[fontweight=medium
     backgroundcolor=white
     fontsize=5
     color=black nobreakspace=off   borderbottomcolor=black borderbottomwidth=.5 ]Ŀ¼}"
      textalign = center;
   style PrintedContentsLabel
      "Sort of a post-posttext for the CONTENTS" /
      posttext = " (*ESC*){leaders .}(*ESC*){tocentrypage}"
      pretext = "(*ESC*){tocentryindent 2em}";
   style ContentItem from IndexItem
      "Controls the leafnode item in the Contents file." /
      marginright = 5% 
      marginleft = 5%;
   style ContentFolder from IndexItem
      "Controls the generic folder definition in the Contents file." /
      marginright = 5%
      marginleft = 5%
      listentryanchor = off
      color = colors('confolderfg');
   style ContentProcName from IndexProcName
      "Controls the proc name in the Contents file." /
      marginright = 5%
      marginleft = 5%;
	end;
run;






%macro setpaths;
%global setup_ runsetup ;
%let setup_= %upcase(%sysget(sas_execfilepath));
%let runsetup=%sysfunc(prxchange(s/(.*)\\.*/\1/,-1,&setup_));
proc datasets library=work kill nolist;
quit;

%mend;
%setpaths;

	ods escapechar='^';
	option nomprint nosymbolgen nomlogic nomfile;
	option nobyline nodate nonumber orientation="PORTRAIT" papersize=A4  ;
	title1  justify = c  "(*ESC*){style rowheader  [color=black nobreakspace=off   borderbottomcolor=black borderbottomwidth=.5 ]
	                              https://www.sas-pharma.com                           }";
	footnote1  justify = c '�� ^{thispage} ҳ';
	ods document name=mydocrep1(write);


data class;
	set sashelp.class;
	holder=1;/*��ʵ�����ã�������ʾ*/
run;

	proc report data=class nowd headskip headline split='|' missing nocenter contents="��1"
	style(report)={ pretext="��1"  };
		  column NAME AGE holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define AGE / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';

	run;

	proc report data=class nowd headskip headline split='|' missing nocenter contents="��2"
	style(report)={ pretext="��2"  };
		  column NAME SEX holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define SEX / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';

	run;
	ods document close;


%macro prodoc;
	/*
		����document��� PDF ���Ŀ¼ ��ǩ����Ϣ
	*/
	ods output properties=Props;
	proc document name=mydocrep1;
	list / levels=all;
	run;
	quit;
	data _null_;
	set props end=last;
	   if type in("Table" "��") then do;
	      count+1;
	      call symputx('patht'||trim(left(count)),path);
	   end;
	call symputx('total',count);
	run;
	proc document name=work.mydocrep1;
	   %do i=1 %to &total;
	      setlabel &&patht&i "��&i.";
	      move &&patht&i to ^;
	   %end;

	ods pdf file="&runsetup./Content_test.pdf" contents=yes style=tp startpage=yes  ;
	     replay ;
	run;
	ods pdf close;
	quit;
%mend;
%prodoc;



proc template;
	define style tp_rtf;
	parent =tp;
   style ContentTitle from IndexTitle
      "Controls the title of the Contents file." /
      fillrulewidth = 10pt 
      marginright = 1em
      marginleft = 1em
      width = 100%
      marginbottom = 1ex
      margintop = 1ex
      font = ("����",12pt,Bold)  /*Ŀ¼����*/
      textalign = center
	  pretext = "Ŀ¼";
	end;
run;

	ods proclabel=' ';
	ods escapechar='^';
	option nomprint nosymbolgen nomlogic nomfile;
	option nobyline nodate nonumber orientation="PORTRAIT" papersize=A4  ;
	title1  justify = c  "(*ESC*)R/RTF'\brdrb\brdrs https://www.sas-pharma.com";
	footnote1  justify = c '�� ^{thispage} ҳ';
	ods rtf file="&runsetup./Content_test.rtf" contents style=tp_rtf startpage=yes toc_data  ;
	ods proclabel=' ';
	proc report data=class nowd headskip headline split='|' missing nocenter contents="��1"
	style(report)={ pretext="\outlinelevel2{��1}\line" };
		  column NAME AGE holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define AGE / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';

	run;
	ods proclabel=' ';
	proc report data=class nowd headskip headline split='|' missing nocenter contents="��2"
	style(report)={ pretext="\outlinelevel2{��2}\line" };
		  column NAME SEX holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define SEX / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';
	run;


	ods rtf close;

