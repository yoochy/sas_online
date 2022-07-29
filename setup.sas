
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
������		:  rtf_merge

Ŀ��			:  ����RTF�ļ��ĺϲ�

����˵��		:  	
	
*
inpath 		������ϲ�RTF�����ļ���
outfile		����ĵ�
order       ����˳��
pageyn		ҳ����滻
Indexyn     �ļ���������������1�������0��
Indextitle  ������������������1�������0����һ����Ŀ���б��templateӦһ�£��������template����SAS���롿


%rtf_merge(inpath=D:\xxxxxx\Project\test,
	outfile=D:\xxxxxx\Project\test\test\all.rtf,
	order=1,pageyn=1);

____________________________________________________________________________________________________________________
/****************************************************************************************************************************************
__________________________________________________________________________________________________________________________
�汾     ����           �޸���             					�޸�����
---     -----------    ------------    	 ----------------------------------------------------------------------------------
1.0     2018.11.14       setup                                   ����
2.0     2019.12.29       setup                                   �������
3.0     2020.05.29       setup                                   ���ɾ���հ�ҳ

****************************************************************************************************************************************/;


			
%rtf_merge(inpath=%str(D:\�ճ���ϰ\���ں������ز�\SASʵ��RTF�ϲ�����\RTF�ϲ�\)
			,outfile=%str(D:\�ճ���ϰ\���ں������ز�\SASʵ��RTF�ϲ�����\RTF�ϲ�\xxxx.rtf),order=0,pageyn=1);

