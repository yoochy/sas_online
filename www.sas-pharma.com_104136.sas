/*symexist:�������Ƿ�Macro ���� ���ص�ֵΪ 0 1*/
%global x;
%macro test;
    %local y;
        %if %symexist(x) %then %put %nrstr(%symexist(x)) = TRUE;
                         %else %put %nrstr(%symexist(x)) = FALSE;
        %if %symexist(y) %then %put %nrstr(%symexist(y)) = TRUE;
                         %else %put %nrstr(%symexist(y)) = FALSE;
        %if %symexist(z) %then %put %nrstr(%symexist(z)) = TRUE;
                         %else %put %nrstr(%symexist(z)) = FALSE;
%mend test;
%test;


/*symglobl:�������Ƿ�δȫ�ֺ�Macro���� ���ص�ֵΪ 0 1*/

%global x;
%macro test;
        %local y;
        %if %symglobl(x) %then %put %nrstr(%symglobl(x)) = TRUE;
                         %else %put %nrstr(%symglobl(x)) = FALSE;
        %if %symglobl(y) %then %put %nrstr(%symglobl(y)) = TRUE;
                         %else %put %nrstr(%symglobl(y)) = FALSE;
        %if %symglobl(z) %then %put %nrstr(%symglobl(z)) = TRUE;
                         %else %put %nrstr(%symglobl(z)) = FALSE;
%mend test;
%test;



/*symlocal:�������Ƿ�Ϊ�ֲ���Macro���� ���ص�ֵΪ 0 1*/

%global x;
%macro test;
    %local y;
        %if %symlocal(x) %then %put %nrstr(%symlocal(x)) = TRUE;
                         %else %put %nrstr(%symlocal(x)) = FALSE;
        %if %symlocal(y) %then %put %nrstr(%symlocal(y)) = TRUE;
                         %else %put %nrstr(%symlocal(y)) = FALSE;
        %if %symlocal(z) %then %put %nrstr(%symlocal(z)) = TRUE;
                         %else %put %nrstr(%symlocal(z)) = FALSE;
%mend test;
%test;
