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
			L = new LaggedAction("Left",leave),	//Create a variable that tracks the previous value of action variable.
			Irupt = new IIDBinary("Irupt", Zeta )  
			);
		L->MakeTerminal(1);
		GroupVariables	(v = new RandomEffect("v",Types, vprob) );
		SetDelta(1/(1+discrate));	//CF: fixed
		
    }


Schooling::FeasibleActions() {
 if (CV(L))  //if already left, must set both to 0
 	return (1-CV(leave)).*(1-CV(attend))   ;
 if (CV(S)==maxS-1) //Must leave, can't attend in last choice period
 	return CV(leave).*(1-CV(attend)) ;
 if (CV(Irupt)) // if interrupted can only do neither
  	return ( (1-CV(leave)).*(1-CV(attend)) ); 
 return //if not interrupted, either leave OR attend but not both
 	CV(leave)+CV(attend).==1;
 }

Schooling::Create() {
	Initialize( /*1.0,*/ new Schooling() );	
	Replicate();
	CreateSpaces();
	
}

Schooling::Utility(){
	decl currSch= CV(S)+Sch0,
		currE=0, // initialize 0 experience if leaving
		ln_w,//log wage at time t
		ln_e,//log experience at time t
		ln_zeta,//School Utility at time t,
		phi1
		;

 /* Work Utility */		//move down to into if cv(l)
	
	
	if( currSch <10 )
		phi1 = splinesWages[SevenToTen]*currSch;
	else if	( currSch>16 )
		phi1 = splinesWages[SeventeenMore]*currSch;
	else
		phi1 = splinesWages[currSch-10]*currSch;
		
	ln_w = phi1 + pars[LogWage] * (currE|currE^2) + vcoef[Wage][CV(v)] + AV(shocks)[Wage]';
    ln_e = (-1)*(pars[Employ] * (1|currSch|currE|currE^2) + AV(shocks)[Employment]');
	
    WorkUtil = ln_w + ln_e;

	if (CV(L)==0){
	ln_zeta = sumc(pars[SchlUtil]') + vcoef[School][CV(v)] + AV(shocks)[School];
		if (currSch < 10) 
			ln_zeta += splines[SevenToTen]*currSch;
    	else if ( currSch>16 )
			ln_zeta += splines[SeventeenMore]*currSch;
    	else
			ln_zeta += splines[currSch-10]*currSch;

		if (CV(Irupt))
			//println("ln_zeta: ", ln_zeta, " Time: ", I::t," Current Schooling: ", currSch);
			return ln_zeta;	
	//	println("ln_zeta*CV(attend) + (WorkUtil*CV(leave))", ln_zeta*CV(attend) + (WorkUtil*CV(leave)), " CV(leave): ", CV(leave));
		return ln_zeta*CV(attend) + (WorkUtil*CV(leave));

	}
	
		else { //return discounted expected lifetime utility
			decl time, Eu;
			//Eu = zeros( (maxT-(I::t-1)), 1);
			Eu = 0;
			currE =1;
			for (time =0;time<(maxT- I::t);++time,++currE){
				Eu += ( beta^( time ) )*(
				(-1)*exp(pars[Employ]*(1|currSch|currE|currE^2)+ 0.5*sqr(stdevs[Employ]) )
				+ phi1
				+ currE*pars[LogWage][wageExp]
				+ sqr(currE)*pars[LogWage][wageExpSqrd]);
				//println("phi1: ",phi1)
				;
			}	  //print("Eu: ",Eu/*, ", Time: ", I::t,", Current Schooling: ", currSch, ", Current Experience: ", currE*/);
			return /*WorkUtil +*/ Eu;
		}
   	 //ln_zeta = pars[SchlUtil]'*X[F_educ:Sou] +  shocks[0];
	
   
}

