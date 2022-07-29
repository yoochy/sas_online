*设置路径;
%let dir=D:\日常练习\sas_zip;
/*分配逻辑库*/
libname out "&dir";
/*定义一个csv文件*/
filename newcsv "&dir\pct.csv";
/*输出一个数据集到csv文件*/
ods csv file=newcsv;
proc print data=sashelp.class label;
run;
ods csv close;


/*利用ODS PACKAGE创建zip文件*/
ods package open nopf ;
/*将csv文件加入压缩包，path表示将该文件放入data文件夹中*/
ods package add file=newcsv path="data\";

/*将rtf文件加入压缩包*/
/*创建压缩包，制定压缩包名字、路径*/
ods package publish archive properties (archive_name="carstats1.zip" archive_path="&dir");
ods package close;
quit;
