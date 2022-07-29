**************************************************************

*inds 		输入数据集;
*invar 		需要添加format的多选变量（字符型）;
*dlm   		各选项值以指定字符分隔;
*valuelist	各选项值对应的FORMAT的值;
*orderYN    是否排序（默认：1） 排序指的的是：（3，2，1 等价于 1，2，3）;
*fmtname	新生成format的名称;




*************测试一：以空格间隔;

/*/*data a;*/*/
/*/*	length y $200.;*/*/
/*/*	input y $ 1-10@;*/*/
/*/*	cards;*/*/
/*/*1 2 3*/*/
/*/*3 2 1*/*/
/*/*1 2*/*/
/*/*2 3*/*/
/*/*3 3*/*/
/*/*1 1*/*/
/*/*1-3*/*/
/*/*1-2*/*/
/*/*2-3*/*/
/*/*;*/*/
/*/*run;*/*/
/*/**/*/
/*/*%add_multipe_fmt(inds=a,invar=y,dlm=%str( ),valuelist=%str(1=张三|2=李四|3=王五),orderYn=0,fmtname=testfmt1_);*/*/
/*/**不排序;*/*/
/*/*data a1;*/*/
/*/*	set a;*/*/
/*/*	format y $testfmt1_.;*/*/
/*/*run;*/*/
/*/**排序;*/*/
/*/*%add_multipe_fmt(inds=a,invar=y,dlm=%str( ),valuelist=%str(1=张三|2=李四|3=王五),orderYn=1,fmtname=testfmt2_);*/*/
/*/*data a2;*/*/
/*/*	set a;*/*/
/*/*	format y $testfmt2_.;*/*/
/*/*run;*/*/
/*/**************测试二：以，间隔;*/*/
/*/*data a;*/*/
/*/*length x $200.;*/*/
/*/*input x $ 1-10@;*/*/
/*/*cards;*/*/
/*/*1,2,3*/*/
/*/*3,2,1*/*/
/*/*1,2*/*/
/*/*2,3*/*/
/*/*3,3*/*/
/*/*1,1*/*/
/*/*1-3*/*/
/*/*;*/*/
/*/*run;*/*/
/*/**/*/
/*/*%add_multipe_fmt(inds=a,invar=x,dlm=%str(,),valuelist=%str(1=张三|2=李四|3=王五),orderYn=0,fmtname=testfmt3_);*/*/
/*/**不排序;*/*/
/*/*data b1;*/*/
/*/*	set a;*/*/
/*/*	format x $testfmt3_.;*/*/
/*/*run;*/*/
/*/**排序;*/*/
/*/*%add_multipe_fmt(inds=a,invar=x,dlm=%str(,),valuelist=%str(1=张三|2=李四|3=王五),orderYn=1,fmtname=testfmt4_);*/*/
/*/*data b2;*/*/
/*/*	set a;*/*/
/*/*	format x $testfmt4_.;*/*/
/*/*run;*/*/





*****************************************************************;

%macro add_multipe_fmt(inds=,invar=,dlm=%str(),valuelist=,orderYn=1,fmtname=);

*获取数据集中观测种类;

proc sql undo_policy=none;
create table tmp_ds1 as
select distinct &invar. from  &inds.;
quit;

*将数据集衍生一个行号，并根据分隔符拆分数据;
data tmp_ds2;
	set tmp_ds1;
	line1=_N_;
	do i=1 to count(strip(&invar),"&dlm.")+1;
		line2=i;
		value_s=kscan(strip(&invar),i,"&dlm.");
		if index(value_s,'-') then do;
			do _sm_=input(scan(value_s,1,'-'),??best.) to input(scan(value_s,2,'-'),??best.);
				value_s=strip(vvalue(_sm_));
				output;
			end;
		end;
		else output;
	end;
run;

/*针对选项值进行一步处理，将宏变量valuelist 存入数据集中(以“|”作为分隔符)*/
data valuelist;
	length valuelist $20000.;
	format valuelist $20000.;
	informat valuelist $20000.;
	valuelist="&valuelist.";
	do i=1 to count(strip(valuelist),"|")+1;
		valuelist_s=kscan(strip(valuelist),i,"|");
		valuelist_s1=kscan(valuelist_s,1,"=");
		valuelist_s2=kscan(valuelist_s,2,"=");
		output;
	end;
run;
*将选项值进行一个left join ;
proc sql undo_policy=none;
	create table tmp_ds3 as
	select  a.*,b.valuelist_s2
	from  tmp_ds2  as a
	left join  valuelist  as b
	on a.value_s =b.valuelist_s1 
	order by line1,line2;
quit;

*如果排序及 orderYn=1 如果不排序则orderYn=0;
%if &orderYn. eq 1 %then %do;
proc sort data=tmp_ds3  out=tmp_ds3  sortseq=linguistic(numeric_collation=on);by line1 value_s ;quit;
%end;
data tmp_ds4;
	set tmp_ds3;
	by line1 ;
	length final $20000.;
	retain final ;
	if first.line1 then do;
	final=strip(valuelist_s2);
	end;
	else do;
	final=strip(catx("&dlm.",final,valuelist_s2));
	end;
	fmt=quote(strip(&invar.))||strip("=")||quote(strip(final));
	if last.line1 then output;
run;
proc sql noprint;
	select fmt into:add_fmt separated by "  " from tmp_ds4   ;
quit;

proc format ;
	value $ &fmtname. &add_fmt.;
run;
*在日志打印内容;


%put   ********************多选FORMAT：&fmtname.已生成*********************;
%put  &add_fmt.;
proc delete data=work.tmp_ds1 work.tmp_ds2 work.tmp_ds3 work.tmp_ds4;run;
%mend;






