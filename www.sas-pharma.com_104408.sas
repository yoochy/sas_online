*可跳转;
%ods_excel(outpath=D:\日常练习\公众号文章素材\Excel的输出\Excel输出宏\odsexcel\test_ods.xlsx
,dslist=sashelp.class\sheet名称\描述
,ContentsYN=Y,Click=1)

*无可跳转;
%ods_excel(outpath=D:\日常练习\公众号文章素材\Excel的输出\Excel输出宏\odsexcel\test_ods_nohref.xlsx
,dslist=sashelp.class\sheet名称\描述
,ContentsYN=N,Click=0)



%ods_excelxp(outpath=D:\日常练习\公众号文章素材\Excel的输出\Excel输出宏\odsexeclxp\test_odsxp.xls,dslist=sashelp.class\class|sashelp.class\test1);

%exp_sas2xls(outpath=D:\日常练习\公众号文章素材\Excel的输出\Excel输出宏\export\test_export,dslist=sashelp.class\sheet名称|sashelp.class\sheet名称2)
