#include "Belzil_and_Hansen_2002_edits.h"

Schooling::Replicate() {
	  decl Omega, chol, Exper;


	 decl sig = unit(Mcomp);
	  Omega = stdevs.*sig.*stdevs';
	  chol = choleski(Omega);	
		SetClock(NormalAging,maxT);   // Decision periods
		
		Actions			(
			leave = new BinaryChoice("Leave"),   // 1-d in the paper
			attend = new BinaryChoice("attend")
			);//d in the paper-- remember this choice will be conditional on entering on a state variable I, if I = 0 then d = 1, else if I = 1 then d = 1 or 0
		ExogenousStates (shocks = new MVNvectorized("eps", ArbDraws,Mcomp,{zeros(Mcomp,1),vech(chol)}));
		EndogenousStates(
			S = new ActionCounter("totSch",maxS,attend),
			L = new LaggedAction("Left",leave),
			Irupt = new IIDBinary("Irupt", Zeta )  
			);
		L->MakeTerminal(1);
		GroupVariables	(v = new RandomEffect("v",Types, vprob) );
		SetDelta(1/(1+discrate));	//CF: fixed
		
    }

/*  IF YOU DEFINE THIS IT HAS TO RETURN VECTOR OF 0s ... CAN"T LEAVE IT BLANK */
Schooling::FeasibleActions() {
 if (CV(L))  //if already left, must set both to 0
 	return (1-CV(leave)).*(1-CV(attend))   ;
 if (I::t==maxS-1) //Must leave, can't attend in last choice period
 	return CV(leave).*(1-CV(attend)) ;
 if (CV(Irupt)) // if interrupted can only do neither
  	return ( (1-CV(leave)).*(1-CV(attend)) ); 
 return //if not interrupted, either leave OR attend but not both
 	CV(leave)+CV(attend).==1;
 }

Schooling::Create() {
	Initialize( new Schooling() );	
	Replicate();
	CreateSpaces();
}

Schooling::Utility(){
	decl currSch= CV(S)+Sch0,
		currE=0; // initialize 0 experience if leaving
	decl
		ln_w,//log wage at time t
		ln_e,//log experience at time t
		ln_zeta  //School Utility at time t,
		;
 /* Work Utility */
	ln_w = pars[LogWage] * (currE|currE^2) + vcoef[Wage][CV(v)] + AV(shocks)[Wage]';
	if( currSch <10 )
		ln_w += splinesWages[SevenToTen]*currSch;
	else if	( currSch>16 )
		ln_w += splinesWages[SeventeenMore]*currSch;
	else
		ln_w += splinesWages[currSch-10]*currSch;
	
    ln_e = (-1)*(pars[Employ] * (1|currSch|currE|currE^2) + AV(shocks)[Employment]');
	
    WorkUtil = sumr(ln_w + ln_e);
	//println("WorkUtil: ",WorkUtil);
	if (CV(L)==1)  { //return discounted expected lifetime utility
		decl time, Eu;
		Eu = zeros( (maxT-(I::t-1)), 1);
		//print("Zero's matrix: ",Eu);
		for (time = I::t;time<(maxT+1);++time){
		//println("Current time: ", time);
		//println("Time index: ",time-I::t);
			Eu[time-I::t][] = ( beta^( time-(I::t+1) ) )*(
			-exp( 0+0.5*(stdevs[Employ])^2 )
			+ (-1)*( currSch*pars[Employ][Sch]
			+  (currE+(time-I::t) )*pars[Employ][Exp]
			+  ((currE+(time-I::t) )^2)*pars[Employ][SqrdExp])
			     );
			}
		//println("Expected LT Utility: ",Eu);
		return WorkUtil + sumc(Eu);
		}
	//Otherwise, still haven't left
    //ln_zeta = pars[SchlUtil]'*X[F_educ:Sou] +  shocks[0];
	ln_zeta = sumc(pars[SchlUtil]') + vcoef[School][CV(v)] + AV(shocks)[School];
	//print(WorkUtil);
	//println(v);
	if (currSch < 10) 
		ln_zeta += splines[SevenToTen]*currSch;
    else if ( currSch>16 )
		ln_zeta += splines[SeventeenMore]*currSch;
    else
		ln_zeta += splines[currSch-10]*currSch;

	return ln_zeta * CV(attend) /*+ (WorkUtil * CV(leave))'*/;
   
}


