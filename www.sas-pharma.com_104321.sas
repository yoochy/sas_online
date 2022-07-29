%inc "E:\macro\*.sas";/*运行.sas后缀的文件程序,*为夹子下的所有程序，单个程序子写出文件名*/

%csv_csv2sas(path=j:\,csvname=BNA.csv,colmax=%str(10000),outds=BNA,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=CCODE.csv,colmax=%str(10000),outds=CCODE,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=DD.csv,colmax=%str(10000),outds=DD,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=DDA.csv,colmax=%str(10000),outds=DDA,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=DDSOURCE.csv,colmax=%str(10000),outds=DDSOURCE,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=INA.csv,colmax=%str(10000),outds=INA,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=ING.csv,colmax=%str(10000),outds=ING,encoding=UTF-8,varr=0,labelr=0,length=500)
%csv_csv2sas(path=j:\,csvname=MAN.csv,colmax=%str(10000),outds=MAN,encoding=UTF-8,varr=0,labelr=0,length=500)

option compress=yes;


/*


*/
data atc1(rename=(VAR3=ATCNAME1 VAR1=ATCCODE1))
	atc2(rename=(VAR3=ATCNAME2 VAR1=ATCCODE2))
	atc3(rename=(VAR3=ATCNAME3 VAR1=ATCCODE3))
	atc4(rename=(VAR3=ATCNAME4 VAR1=ATCCODE4)) ;
	set ina;
	if length(VAR1)=1 then output atc1;
	if length(VAR1)=3 then output atc2;
	if length(VAR1)=4 then output atc3;
	if length(VAR1)=5 then output atc4;

	keep   Var1 Var2 Var3;
run;

/*第一次megre*/
data atc2;
	set atc2;
	ATCCODE1=substr(ATCCODE2,1,1);
run;
proc sort data=atc1 out=atc1  ; by ATCCODE1 ;run;
proc sort data=atc2 out=atc2  ; by ATCCODE1 ;run;
data atc2;
	merge atc1 atc2;
	by ATCCODE1;
run;

data atc3;
	set atc3;
	ATCCODE1=substr(ATCCODE3,1,1);
	ATCCODE2=substr(ATCCODE3,1,3);
run;
proc sort data=atc2 out=atc2  ; by ATCCODE1 ATCCODE2;run;
proc sort data=atc3 out=atc3  ; by ATCCODE1 ATCCODE2;run;

data atc3;
	merge atc2 atc3;
	by ATCCODE1 ATCCODE2;
run;

data atc4;
	set atc4;
	ATCCODE1=substr(ATCCODE4,1,1);
	ATCCODE2=substr(ATCCODE4,1,3);
	ATCCODE3=substr(ATCCODE4,1,4);

run;
proc sort data=atc4 out=atc4  ; by ATCCODE1 ATCCODE2 ATCCODE3;run;
proc sort data=atc3 out=atc3  ; by ATCCODE1 ATCCODE2 ATCCODE3;run;

data final;
	merge atc3 atc4;
	by ATCCODE1 ATCCODE2 ATCCODE3;
	drop var2;
run;




/*
从DD中拆分 Ina 并入Dda
*/
/*将ATC--编码并入*/

/*拆分编码分级*/
data atc1(rename=(Var5=ATCCODE1))
	atc2(rename=( Var5=ATCCODE2))
	atc3(rename=( Var5=ATCCODE3))
	atc4(rename=(Var5=ATCCODE4)) ;
	set dda;
	if length(Var5)=1 then output atc1;
	if length(Var5)=3 then output atc2;
	if length(Var5)=4 then output atc3;
	if length(Var5)=5 then output atc4;
	keep   Var1 Var2 Var5;
run;

/*分别并入每个药*/
proc sql UNDO_POLICY=NONE;
	create table atc1 as
	select distinct a.*,b.ATCNAME1
	from  atc1  as a
	left join   final as b
	on a.ATCCODE1 =b.ATCCODE1 ;
quit;
proc sql UNDO_POLICY=NONE;
	create table atc2 as
	select distinct a.*,b.ATCCODE1,b.ATCNAME1,b.ATCNAME2
	from  atc2  as a
	left join   final as b
	on a.ATCCODE2 =b.ATCCODE2 ;
quit;

proc sql UNDO_POLICY=NONE;
	create table atc3 as
	select distinct a.*,b.ATCCODE1,b.ATCNAME1,b.ATCNAME2,b.ATCCODE2,b.ATCNAME3 
	from  atc3  as a
	left join   final as b
	on a.ATCCODE3 =b.ATCCODE3 ;
quit;
proc sql UNDO_POLICY=NONE;
	create table atc4 as
	select distinct a.*,b.*
	from  atc4  as a
	left join   final as b
	on a.ATCCODE4 =b.ATCCODE4 ;
quit;

data final2;
	set atc1 atc2 atc3 atc4;
run;

/*DD 中关联每个药物-- 提取DD中 每个KEY的关键名 首选NAME  即  VAR1 VAR2 VAR3  - VAR3=001 */
data temp_dd_1 temp_dd_2;
	set DD;
	keep var1 var2 var3 var12;
	output temp_dd_1;
	if var3="001" then output temp_dd_2;
run;
/*将fianl2 并入 temp_dd_2  每个编码的首选语*/
proc sql undo_policy=none;
	create table final3 as
	select distinct *
	from  temp_dd_2  as a

	left join   final2 as b
	on a.Var1 =b.Var1 
	and a.Var2 =b.Var2 ;
quit;

/*衍生生成 preferred Code preferred Name*/
data final4;
	set final3;
	preferredCode=strip(VAR1)||" "||strip(VAR2)||" "||strip(VAR3);
	preferredName=VAR12;
	drop VAR12 VAR3;
run;


/*将fina4 并入temp_dd_1*/

proc sql undo_policy=none;
	create table whoDrugDD as
	select  *
	from  temp_dd_1  as a

	left join final4   as b
	on a.VAR1 =b.VAR1 
	and a.VAR2 =b.VAR2 
    ;
quit;
libname  text "D:\";
data text.whoDrugDD;
	set whoDrugDD;
	DrugCode=strip(VAR1)||" "||strip(VAR2)||" "||strip(VAR3);
	DrugName=VAR12;
	drop VAR1 VAR2 VAR3 VAR12;

run;




