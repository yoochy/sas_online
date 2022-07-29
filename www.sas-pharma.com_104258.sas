proc format library=work CNTLOUT=work.fmt;
invalue $ fmt_cdo  "°×Ï¸°û"="WBC"  "ºìÏ¸°û"="RBC" "ÑªÐ¡°å¼ÆÊý"="PLAT"
"Ñªºìµ°°×"="HGB"  "ÖÐÐÔÁ£Ï¸°û"="NEUT" "ÁÜ°ÍÏ¸°û"="NEUT";

value $ fmt_cdt  "°×Ï¸°û"="WBC"  "ºìÏ¸°û"="RBC" "ÑªÐ¡°å¼ÆÊý"="PLAT"
"Ñªºìµ°°×"="HGB"  "ÖÐÐÔÁ£Ï¸°û"="NEUT" "ÁÜ°ÍÏ¸°û"="NEUT";


run;

data temp1;
length LBTEST $40.;
input LBTEST  ;
LBTESTCD1=input(LBTEST,$fmt_cdo30.);
LBTESTCD2=put(LBTEST,$fmt_cdt30.);
LBTESTCD3=put(LBTEST,$fmt_cdo30.);
LBTESTCD4=input(LBTEST,$fmt_cdt30.);

cards;
°×Ï¸°û
ºìÏ¸°û
ÑªÐ¡°å¼ÆÊý
Ñªºìµ°°×
ÖÐÐÔÁ£Ï¸°û
ÁÜ°ÍÏ¸°û
;
run;


proc format library=work CNTLOUT=work.fmt;
value  rang  1-<20="Õý³£"  Low-<1="Òì³£" 20< -High="Òì³£ÎÞÁÙ´²ÒâÒå" .="MISS";
run;
data temp1;
input ORRES1  ;
LBTESTCD1=put(ORRES1,rang.);
cards;
100
209
.
23
22
18
-1
;
run;


proc format library=work CNTLIN=work.fmt;
run;






data aaa;
length aa1 bb1 $200.;
input aa1 $ bb1 $;
cc1=strip('"')||strip(aa1)||strip('"="')||strip(bb1)||strip('"');
cards;
°×Ï¸°û	WBC
ºìÏ¸°û	RBC
ÑªÐ¡°å¼ÆÊý	PLAT
Ñªºìµ°°×	HGB
ÖÐÐÔÁ£Ï¸°û	NEUT
ÁÜ°ÍÏ¸°û	LYM
µ¥ºËÏ¸°û	MONO
;
run;
proc sql noprint;
select cc1 into:varlist separated by "  " from aaa   ;
quit;
skip 5;
%put &varlist;
 



/*Éú³É·½Ê½*/

data temp2;
	set fmt;
	if _N_>4 then fmtname=strip("$")||strip(fmtname);
	keep fmtname start end label;
run;
proc format library=work CNTLIN=work.temp2 CNTLout=sss;
run;




