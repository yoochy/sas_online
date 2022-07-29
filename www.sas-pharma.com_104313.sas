/*******************************************************************************************************************************************************
*  Program name   	: MedDRA_v18_complete_dictionary.sas
*  Author			: 
*  Date			    : 
*  Purpose			: 1. to convert MedDRA V16.0 dictionary into SAS datasets: LLT_v16_0 and MDHIER_v16_0
					  2. to create a complete MedDRA dictionary SAS dataset meddra_dict_v16_0, which includes LLT, PT, HLT, HLGT, SOC code and name
*  Revision History :
*  Date  Author  Description of the change 

********************************************************************************************************************************************************/

libname meddra 'D:\Med\english';

%let meddir=D:\Med\english\MedAscii;

/* 1. convert LLT dictionary into SAS dataset */
data meddra.llt_v19;
      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
      infile "&meddir\llt.asc" encoding='utf-8' delimiter = '$' MISSOVER DSD  lrecl=32767 firstobs=1  ;
         informat llt_code best12. ;
         informat llt_name $500. ;
         informat pt_code best12. ;
         informat llt_whoart_code $7. ;
         informat llt_harts_code best12. ;
         informat llt_costart_sym $21. ;
         informat llt_icd9_code $8. ;
         informat llt_icd9cm_code $8. ;
         informat llt_icd10_code $8. ;
         informat llt_currency $1. ;
         informat llt_jart_code $6. ;


         format llt_code best12. ;
         format llt_name $500. ;
         format pt_code best12. ;
         format llt_whoart_code $7. ;
         format llt_harts_code best12. ;
         format llt_costart_sym $21. ;
         format llt_icd9_code $8. ;
         format llt_icd9cm_code $8. ;
         format llt_icd10_code $8. ;
         format llt_currency $1. ;
         format llt_jart_code $6. ;


      input
                  llt_code
                  llt_name
                  pt_code
                  llt_whoart_code
                  llt_harts_code
                  llt_costart_sym
                  llt_icd9_code
                  llt_icd9cm_code
                  llt_icd10_code
                  llt_currency
                  llt_jart_code

      ;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;

/* 2. convert MedDRA hierarchy dictionary into SAS dataset */
data meddra.mdhier_v19;
	%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "&meddir\mdhier.asc" encoding='utf-8' delimiter = '$' MISSOVER DSD  lrecl=32767 firstobs=1 ;

    informat pt_code best12. ;
	informat hlt_code best12.;
    informat hlgt_code best12. ;
	informat soc_code best12.;
    informat pt_name $100. ;
    informat hlt_name $100. ;
    informat hlgt_name $100. ;
    informat soc_name $100. ;
    informat soc_abbrev $10. ;
    informat null_field $1. ;
    informat pt_soc_code best12. ;
    informat primary_soc_fg $1. ;

    format pt_code best12. ;
	format hlt_code best12.;
    format hlgt_code best12. ;
	format soc_code best12.;
    format pt_name $100. ;
    format hlt_name $100. ;
    format hlgt_name $100. ;
    format soc_name $100. ;
    format soc_abbrev $10. ;
    format null_field $1. ;
    format pt_soc_code best12. ;
    format primary_soc_fg $1. ;


    input
      	pt_code
      	hlt_code
		hlgt_code
		soc_code
		pt_name
		hlt_name
		hlgt_name
		soc_name
		soc_abbrev
		null_field
		pt_soc_code
		primary_soc_fg;

	if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;


/* read in MedDRA v18.1 dictionary(LLT dataset), meddra.llt/mdhier was created by program d_meddra_asc.sas */
proc sql noprint;
	  create table llt as
		select llt_code, llt_name, pt_code, llt_currency
		from meddra.llt_v19
		order by llt_code;
quit;

/* MedDRA hierarchy including all higher level terms */
data mdhier;
	set meddra.mdhier_v19;
	where primary_soc_fg='Y';
run;

/* 3. create complete MedDRA v18.1 dictionary dataset including LLT, PT, HLT, HLGH, SOC code and name */
proc sql noprint;
	  create table meddra.meddra_dict_v21_English as
		select a.llt_code, a.llt_name, a.pt_code, b.pt_name, b.hlt_code, b.hlt_name, 
			   b.hlgt_code, b.hlgt_name, b.soc_code, b.soc_name,a.llt_currency, b.pt_soc_code, b.primary_soc_fg
		from llt a, mdhier b
		where a.pt_code=b.pt_code
		order by llt_code;
quit;

