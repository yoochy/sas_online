*����·��;
%let dir=D:\�ճ���ϰ\sas_zip;
/*�����߼���*/
libname out "&dir";
/*����һ��csv�ļ�*/
filename newcsv "&dir\pct.csv";
/*���һ�����ݼ���csv�ļ�*/
ods csv file=newcsv;
proc print data=sashelp.class label;
run;
ods csv close;


/*����ODS PACKAGE����zip�ļ�*/
ods package open nopf ;
/*��csv�ļ�����ѹ������path��ʾ�����ļ�����data�ļ�����*/
ods package add file=newcsv path="data\";

/*��rtf�ļ�����ѹ����*/
/*����ѹ�������ƶ�ѹ�������֡�·��*/
ods package publish archive properties (archive_name="carstats1.zip" archive_path="&dir");
ods package close;
quit;
