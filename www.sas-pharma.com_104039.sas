/*filename text1 "D:\日常练习\公众号文章素材\修改SAS程序名\adsl.sas" lrecl=2560 encoding=any;*/
/*filename text2 "D:\日常练习\公众号文章素材\修改SAS程序名\adsl.sas.txt" lrecl=2560 encoding=utf8;*/
/**/
/*data _null_;*/
/*   rc=fcopy('text1', 'text2');*/
/*run;*/

/*filename dfo "&inpath.\&date1.";*/
/*data _null_;*/
/*	NewDir=fdelete('dfo');*/
/*	put rc=;*/
/*    msg=sysmsg();*/
/*    put msg=;*/
/**/
/*/*	NewDir=dcreate("&date1.","&inpath.");*/*/
/*run;*/
/*data _null_;*/
/*	NewDir=dcreate("&date1.","&inpath.");*/
/*run;*/
;

%macro filesas2txt(inpath=,allYN=1,outencoding=utf8);
*获取当前日期;
	data _null_;
		call symput("date1",left(compress(put("&sysdate"d,yymmdd10.),"-"," ")));
	run;
*删除文件夹;
	systask command "rd /s/q &inpath.\&date1.";
*睡眠0.5秒;
	data _null_;
		rc=sleep(0.5);
	run;
*创建文件夹;
	data _null_;
		NewDir=dcreate("&date1.","&inpath.");
	run;
	%if &allYN eq 1 %then %do;
		%let _pipfg=/b/s;
	%end;
	%else %do;
		%let _pipfg=/b;
	%end;

filename _pipfile pipe "dir &inpath.\*.sas &_pipfg."  ; 
data _pipfile;
   infile _pipfile truncover;
   input fname $char1000.;
   put fname=;
   	%if &allYN ne 1 %then %do;
	fname="&inpath.\"||strip(fname);
	%end;
	newfile=strip("&inpath.\&date1.\")||strip(kscan(fname,-1,'\'))||strip('.txt');
	call execute(
	strip('filename fn')||strip(_n_)||' '||strip(quote(strip(fname)))||' encoding=any  lrecl=30000 ;
	filename nf'||strip(_n_)||' '||strip(quote(strip(newfile)))||" lrecl=30000  encoding=&outencoding.;");
run;

data _null_;
	set _pipfile;
	 rc=fcopy(strip('fn')||strip(_n_),strip('nf')||strip(_n_));
run;

%mend;

%filesas2txt(inpath=D:\日常练习\公众号文章素材\修改SAS程序名,allYN=0,outencoding=utf8);
