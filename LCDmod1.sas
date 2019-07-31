
FILENAME pef_2 '/folders/myfolders/LCD/module 1/pef_2.xls';
PROC IMPORT DATAFILE=pef_2
	DBMS=XLS
	OUT=LCD1mod1.pef_2;
	GETNAMES=YES;
RUN;
proc ttest data=LCD1mod1.PEF_2 sides=2 h0=0 plots(showh0);
	class trt;
	var pef;
run;

proc reg data=lcd1mod1.pef_2;
model pef=trt;
run;

data lcd1mod1.alldata;
set lcd1mod1.pef_2 
lcd1mod1.pef_lg;
run;
proc mixed data=lcd1mod1.alldata;
class sub trt;
model pef=trt /s ddfm=satterth;
random sub;
run;

