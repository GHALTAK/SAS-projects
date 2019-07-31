proc import out=lcdass1.holism replace dbms=dta
  datafile='/folders/myfolders/LCD/Assignment1/holism.dta';
run;

proc sgplot data=lcdass1.holism;
	series x=timepoint y=mhqol/group=hliscat;
run;

/* boxplot by treatment */
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=LCDASS1.HOLISM;
	vbox mhqol / category=hliscat;
	yaxis grid;
run;

ods graphics / reset;

/* boxplot for timepoint */
ods graphics / reset width=6.4in height=4.8 in imagemap;

proc sgplot data=LCDASS1.HOLISM;
	vbox mhqol / category=hliscat group=timepoint;
	yaxis grid;
run;

ods graphics / reset;

/* panel plot */
proc sgpanel data=lcdass1.holism;
	panelby hliscat / columns=2;
	series x=timepoint y=mhqol/group=id;
run;

/* */
proc sort data=lcdass1.holism;
	by hliscat;
run;

proc loess data=lcdass1.holism;
	model mhqol=timepoint;
	by hliscat;
	ods output OutputStatistics=lcdass1.loess;
run;

proc glm data=lcdass1.holism;
	model mhqol=timepoint;
	run;
	
/*correlation matric and scatter plot of the  data*/
proc sort data=lcdass1.holism;
	by id;
run;

proc transpose data=lcdass1.holism out=lcdass1.holisms prefix=lag_;
	by id hliscat;
	var mhqol;
run;

proc corr data=lcdass1.holisms noprob;
title "Correlation matrix for Healthy group";
where hliscat=0;
	var lag_1-lag_3;
run;

proc corr data=lcdass1.holisms noprob;
	where hliscat=1;
	var lag_1-lag_3;
run;


proc sgscatter data=lcdass1.holisms;
	title "Scatterplot Matrix for Healthy group";
	where hliscat=1;
	matrix lag_1-lag_3;
run;
proc sgscatter data=lcdass1.holisms;
	title "Scatterplot Matrix for Other group";
	where hliscat=0;
	matrix lag_1-lag_3;
run;

	/* 2. estimate for mean diff in MHQOL healthy and other group sepretly 
	 for year 1 and 2*/
	proc glm data=lcdass1.holism ;
	class hliscat (ref= '0');
	model mhqol=hliscat/ solution clparm ;
	where timepoint=1;
	run;
	proc glm data=lcdass1.holism ;
	class hliscat (ref= '0');
	model mhqol=hliscat/ solution clparm;
	where timepoint=2;
	run;
	
	
	/**/
proc sort data=lcdass1.holism;
	by id;
run;
proc reg data=lcdass1.holism outest=lcdass1.ols noprint;
	model mhqol=timepoint;
	by id;
	run;

data lcdass1.ols;
	set lcdass1.ols;
	keep id timepoint;

	if timepoint ne 0;

	if timepoint ne .;
	
	rename timepoint=ols;
run;

proc tabulate data=lcdass1.ols order=data ;
class id;
var ols;
table id ols ;
run;
proc sort;
	by id;
run;

data mean;
	set lcdass1.holism;

	if timepoint ne 0;

	if timepoint ne .;

proc sort;
	by id;

proc means noprint;
	var mhqol /*timepoint*/ hliscat;
	by id;
	output out=lcdass1.holismmean mean=newmhqol hliscat;
run;


/*proc iml;
	edit lcdass1.holismmean;
	delete point 1;
	close lcdass1.holismmean;
run;*/

data lcdass1.holismmean(drop=_TYPE_);
	set lcdass1.holismmean;
run;

data lcdass1.merge;
	merge lcdass1.holismmean lcdass1.ols;
	by id;
run;

proc glm data=lcdass1.merge plots=all;
	class hliscat(ref='0');
	model ols=hliscat/ solution clparm;
	run;

proc glm data=lcdass1.merge;
	class hliscat(ref='0');
	model newmhqol=hliscat/ solution;
    run;
    /* ols against mean*/
   proc glm data=lcdass1.merge;
	class hliscat(ref='0');
	model ols=newmhqol/ solution;
    run;
    
    
/*4. */
proc genmod data=lcdass1.holism /*plots=all*/;
	class hliscat (ref="0") id/ param=reference;
	model mhqol=hliscat timepoint timepoint*hliscat/ dist=normal link=identity type3 corrb;
	repeated subject=id/type=ind modelse;
run;

proc genmod data=lcdass1.holism plots=all;
	class hliscat (ref="0") id/ param=reference;
	model mhqol=hliscat timepoint timepoint*hliscat/ dist=normal link=identity type3;
	repeated subject=id/type=exch modelse;
run;

proc genmod data=lcdass1.holism /*plots=all*/;
	class hliscat (ref="0") id/ param=reference;
	model mhqol=hliscat timepoint timepoint*hliscat / dist=normal link=identity type3;
	repeated subject=id/type=ar(1) modelse;
run;
proc genmod data=lcdass1.holism /*plots=all*/;
	class hliscat (ref="0") id/ param=reference;
	model mhqol=hliscat timepoint timepoint*hliscat / dist=normal link=identity type3;
	repeated subject=id/type=ar(2) modelse;
run;proc genmod data=lcdass1.holism /*plots=all*/;
	class hliscat (ref="0") id/ param=reference;
	model mhqol=hliscat timepoint timepoint*hliscat / dist=normal link=identity type3;
	repeated subject=id/type= ar modelse;
run;