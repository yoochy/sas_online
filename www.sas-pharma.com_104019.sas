**************************************************************

*inds 		�������ݼ�;
*invar 		��Ҫ���format�Ķ�ѡ�������ַ��ͣ�;
*dlm   		��ѡ��ֵ��ָ���ַ��ָ�;
*valuelist	��ѡ��ֵ��Ӧ��FORMAT��ֵ;
*orderYN    �Ƿ�����Ĭ�ϣ�1�� ����ָ�ĵ��ǣ���3��2��1 �ȼ��� 1��2��3��;
*fmtname	������format������;




*************����һ���Կո���;

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
/*/*%add_multipe_fmt(inds=a,invar=y,dlm=%str( ),valuelist=%str(1=����|2=����|3=����),orderYn=0,fmtname=testfmt1_);*/*/
/*/**������;*/*/
/*/*data a1;*/*/
/*/*	set a;*/*/
/*/*	format y $testfmt1_.;*/*/
/*/*run;*/*/
/*/**����;*/*/
/*/*%add_multipe_fmt(inds=a,invar=y,dlm=%str( ),valuelist=%str(1=����|2=����|3=����),orderYn=1,fmtname=testfmt2_);*/*/
/*/*data a2;*/*/
/*/*	set a;*/*/
/*/*	format y $testfmt2_.;*/*/
/*/*run;*/*/
/*/**************���Զ����ԣ����;*/*/
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
/*/*%add_multipe_fmt(inds=a,invar=x,dlm=%str(,),valuelist=%str(1=����|2=����|3=����),orderYn=0,fmtname=testfmt3_);*/*/
/*/**������;*/*/
/*/*data b1;*/*/
/*/*	set a;*/*/
/*/*	format x $testfmt3_.;*/*/
/*/*run;*/*/
/*/**����;*/*/
/*/*%add_multipe_fmt(inds=a,invar=x,dlm=%str(,),valuelist=%str(1=����|2=����|3=����),orderYn=1,fmtname=testfmt4_);*/*/
/*/*data b2;*/*/
/*/*	set a;*/*/
/*/*	format x $testfmt4_.;*/*/
/*/*run;*/*/





*****************************************************************;

%macro add_multipe_fmt(inds=,invar=,dlm=%str(),valuelist=,orderYn=1,fmtname=);

*��ȡ���ݼ��й۲�����;

proc sql undo_policy=none;
create table tmp_ds1 as
select distinct &invar. from  &inds.;
quit;

*�����ݼ�����һ���кţ������ݷָ����������;
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

/*���ѡ��ֵ����һ�������������valuelist �������ݼ���(�ԡ�|����Ϊ�ָ���)*/
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
*��ѡ��ֵ����һ��left join ;
proc sql undo_policy=none;
	create table tmp_ds3 as
	select  a.*,b.valuelist_s2
	from  tmp_ds2  as a
	left join  valuelist  as b
	on a.value_s =b.valuelist_s1 
	order by line1,line2;
quit;

*������� orderYn=1 �����������orderYn=0;
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
*����־��ӡ����;


%put   ********************��ѡFORMAT��&fmtname.������*********************;
%put  &add_fmt.;
proc delete data=work.tmp_ds1 work.tmp_ds2 work.tmp_ds3 work.tmp_ds4;run;
%mend;






