*����ת;
%ods_excel(outpath=D:\�ճ���ϰ\���ں������ز�\Excel�����\Excel�����\odsexcel\test_ods.xlsx
,dslist=sashelp.class\sheet����\����
,ContentsYN=Y,Click=1)

*�޿���ת;
%ods_excel(outpath=D:\�ճ���ϰ\���ں������ز�\Excel�����\Excel�����\odsexcel\test_ods_nohref.xlsx
,dslist=sashelp.class\sheet����\����
,ContentsYN=N,Click=0)



%ods_excelxp(outpath=D:\�ճ���ϰ\���ں������ز�\Excel�����\Excel�����\odsexeclxp\test_odsxp.xls,dslist=sashelp.class\class|sashelp.class\test1);

%exp_sas2xls(outpath=D:\�ճ���ϰ\���ں������ز�\Excel�����\Excel�����\export\test_export,dslist=sashelp.class\sheet����|sashelp.class\sheet����2)
