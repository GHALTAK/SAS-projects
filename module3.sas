proc sort data=lcd3.rats;
	by id;
run;

proc glm data=LCD3.rats;
	class trt(ref="1");
	model weight=trt week week*trt/ solution;
	run;

proc genmod data=lcd3.rats;
	class trt (ref="1") id/ param=reference;
	model weight=trt week trt*week/ dist=normal link=identity type3;
	repeated subject=id/type=ind modelse;
run;

proc genmod data=lcd3.rats /*plots=all*/;
	class trt (ref="1") id/ param=reference;
	model weight=trt week trt*week/ dist=normal link=identity type3;
	repeated subject=id/type=exch modelse;
run;

proc genmod data=lcd3.rats /*plots=all*/;
	class trt (ref="1") id/ param=reference;
	model weight=trt week trt*week/ dist=normal link=identity type3;
	repeated subject=id/type=ar(1) modelse;
run;

proc genmod data=lcd3.rats plots=all;
	class trt (ref="1") id/ param=reference;
	model weight=trt week trt*week week*week/ dist=normal link=identity type3;
	repeated subject=id/type=ar(1) modelse;
run;