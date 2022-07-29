
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


%setpaths;

**run Macro;
libname MacLib "&runsetup.";
Options MAutoSource MStored SASMStore=MacLib;

/*************************************************************************************************************************
宏名称		:  rtf_merge

目的			:  用与RTF文件的合并

参数说明		:  	
	
*
inpath 		输入待合并RTF所在文件夹
outfile		输出文档
order       排序顺序
pageyn		页码的替换
Indexyn     文件名做索引（如是1、如否填0）
Indextitle  表格标题做索引（如是1、如否填0）【一个项目所有表格template应一致，且需根据template调整SAS代码】


%rtf_merge(inpath=D:\xxxxxx\Project\test,
	outfile=D:\xxxxxx\Project\test\test\all.rtf,
	order=1,pageyn=1);

____________________________________________________________________________________________________________________
/****************************************************************************************************************************************
__________________________________________________________________________________________________________________________
版本     日期           修改人             					修改描述
---     -----------    ------------    	 ----------------------------------------------------------------------------------
1.0     2018.11.14       setup                                   创建
2.0     2019.12.29       setup                                   添加索引
3.0     2020.05.29       setup                                   添加删除空白页

****************************************************************************************************************************************/;


			
%rtf_merge(inpath=%str(D:\日常练习\公众号文章素材\SAS实现RTF合并过程\RTF合并\)
			,outfile=%str(D:\日常练习\公众号文章素材\SAS实现RTF合并过程\RTF合并\xxxx.rtf),order=0,pageyn=1);

