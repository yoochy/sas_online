/*
 * ========================================================================================================================================
 *           
 *             文件名: Contents.sas
 *           
 *           程序说明:			 
  					  ODS PDF 输出文档：采用 Proc document过程步+Proc report过程步组合实现输出。
							1.Proc document用于目录页的生成/文档的创建等
					  		2.Proc report用于文档内容的输出
					  特点：可直接生成目录页，无需打开文档进行手动设置

					  ODS RTF 输出文档：Proc Report过程直接内嵌进ODS RTF中
					  特点：ODS RTF输出报表拥有众多参数可选，在格式调整上优于ODS PDF。在目录页的生成上SASHELP指导中采用contents选项，
					  生成目录后，需打开文档进行更新目录。基于RTF输出，还可通过另外一种方式生成，利用RTF标记语言\outlinelevel进行设置标题级别，可手动自定义目录。
					  程序内目录生成的这俩种方式均支持。但与ODS PDF相比，此处需手动处理略显不足。环境兼容性ODS PDF相对ODS RTF强。

*               
*======================================================================================================================================== 
* 
*               作者:Setup 
*               邮箱:setup@mail.sas-pharma.com 
*               网站:https://www.sas-pharma.com 
*               微信号:gongnxc 
*               微信公众号:SAS程序分享号号号（xiaocgn） 
*
* ========================================================================================================================================
*/ 



proc template;
	define style tp;
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
	replace Header from HeadersandFooters / font = ("宋体", 9pt, medium) 
		background = _undef_
		protectspecialchars = off;
	replace table from output / font = ("宋体", 9pt, medium)
		background = _undef_
		frame = void
		rules = none
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
   class Contents /
      liststyletype = "decimal"
      tagattr = " onload=""expandAll()"""
      pagebreakhtml = html('break')
      color = colors('contentfg')
      backgroundcolor = colors('contentbg')
      marginright = 0
      marginleft = 0;
/*控制目录标题*/
   style ContentTitle from IndexTitle
      "Controls the title of the Contents file." /
      fillrulewidth = 0pt 
      marginright = 1em
      marginleft = 1em
      width = 100%
      marginbottom = 0ex
      margintop = 0ex
      font = ("宋体",12pt,Bold)  /*目录字体*/
  	   pretext = "(*ESC*){style   
	[fontweight=medium
     backgroundcolor=white
     fontsize=5
     color=black nobreakspace=off   borderbottomcolor=black borderbottomwidth=.5 ]目录}"
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
	footnote1  justify = c '第 ^{thispage} 页';
	ods document name=mydocrep1(write);


data class;
	set sashelp.class;
	holder=1;/*无实际作用：控制显示*/
run;

	proc report data=class nowd headskip headline split='|' missing nocenter contents="表1"
	style(report)={ pretext="表1"  };
		  column NAME AGE holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define AGE / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';

	run;

	proc report data=class nowd headskip headline split='|' missing nocenter contents="表2"
	style(report)={ pretext="表2"  };
		  column NAME SEX holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define SEX / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';

	run;
	ods document close;


%macro prodoc;
	/*
		利用document输出 PDF 添加目录 标签等信息
	*/
	ods output properties=Props;
	proc document name=mydocrep1;
	list / levels=all;
	run;
	quit;
	data _null_;
	set props end=last;
	   if type in("Table" "表") then do;
	      count+1;
	      call symputx('patht'||trim(left(count)),path);
	   end;
	call symputx('total',count);
	run;
	proc document name=work.mydocrep1;
	   %do i=1 %to &total;
	      setlabel &&patht&i "表&i.";
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
      font = ("宋体",12pt,Bold)  /*目录字体*/
      textalign = center
	  pretext = "目录";
	end;
run;

	ods proclabel=' ';
	ods escapechar='^';
	option nomprint nosymbolgen nomlogic nomfile;
	option nobyline nodate nonumber orientation="PORTRAIT" papersize=A4  ;
	title1  justify = c  "(*ESC*)R/RTF'\brdrb\brdrs https://www.sas-pharma.com";
	footnote1  justify = c '第 ^{thispage} 页';
	ods rtf file="&runsetup./Content_test.rtf" contents style=tp_rtf startpage=yes toc_data  ;
	ods proclabel=' ';
	proc report data=class nowd headskip headline split='|' missing nocenter contents="表1"
	style(report)={ pretext="\outlinelevel2{表1}\line" };
		  column NAME AGE holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define AGE / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';

	run;
	ods proclabel=' ';
	proc report data=class nowd headskip headline split='|' missing nocenter contents="表2"
	style(report)={ pretext="\outlinelevel2{表2}\line" };
		  column NAME SEX holder;
		  define NAME / display "" style(header)=[just=left] style(column)=[just=left cellwidth=70% asis=on];
		  define SEX / display "" style(header)=[just=left] style(column)=[just=right cellwidth=26% asis=on];
		  define holder / noprint order;
		  break before holder / page contents='';
	run;


	ods rtf close;

