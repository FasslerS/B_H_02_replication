#include "Belzil_and_Hansen_2002_edits.h"

Schooling::Replicate() {
		SetClock(NormalAging,maxT);   // Decision periods
		
		Actions			(
			leave = new BinaryChoice("Leave"),   // 1-d in the paper
			attend = new BinaryChoice("attend")
			);//d in the paper-- remember this choice will be conditional on entering on a state variable I, if I = 0 then d = 1, else if I = 1 then d = 1 or 0
		ExogenousStates (shocks = new MVNvectorized("eps", ArbDraws,Mcomp,{zeros(stdevs),vech(diag(stdevs))}));
        #ifdef LTERM
		    L = new LaggedAction("Left",leave);	//Create a variable that tracks the previous value of action variable.				
		    L->MakeTerminal(1);
            Xper = 0;
        #else
            L = new PermanentChoice("Left",leave);
            Xper = new Freeze(new StateCounter("Xper",maxT,L),notLeft);
        #endif;
		Irupt = new IIDBinary("Irupt", Zeta ),
		S = new Freeze(new ActionCounter("totSch",maxS,attend),L);
		EndogenousStates(Irupt,S,L);
        AuxiliaryOutcomes(new StaticAux("E",AuxEarn));
        #ifndef LTERM
		  EndogenousStates(Xper);
        #endif
		GroupVariables	(v = new RandomEffect("v",Types, vprob[:Types-1]/sumc(vprob[:Types-1]) ) );
		SetDelta(1/(1+discrate));	//CF: fixed
		
    }
/** shocks have no effect after leaving.  Avoid summing over them.**/
Schooling::IgnoreExogenous() {
 return CV(L);  // 0 will use eps everywhere
    }
Schooling::Reachable() {
    return CV(S)+CV(Xper)<= I::t;
    }
Schooling::FeasibleActions() {
 if (CV(L))  //if already left, must set both to 0
 	return (CV(leave)).*(1-CV(attend))   ;
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

Schooling::notLeft() { return !CV(L);    }
Schooling::ExpectedEarn(xv) {
 return -exp(pars[Employ]*xv+ 0.5*sqr(stdevs[Employ]) ) + pars[LogWage]*(xv[Exp:]);
}

/** Computed in ThetaUtility so available for prediction.**/
Schooling::AuxEarn() { return    Earn; }

Schooling::Utility() {
	if (notLeft()){
        decl sv = AV(shocks),
	         ln_zeta = ln_zeta0 + sv[School];//School Utility at time t
        if (CV(Irupt)) return ln_zeta;
    	return ln_zeta*CV(attend) + (ln_w0 + sv[Wage] + ln_e0*exp(sv[Employment]))*CV(leave);
        }
    return Earn;
    }

Schooling::ThetaUtility(){
	decl currSch= CV(S)+Sch0,	phi1 ;
	if( currSch < Spline1 )
		phi1 = splinesWages[SevenToTen]*currSch;
	else if	( currSch<Spline2 )
		phi1 = splinesWages[currSch-Spline1]*currSch;	
	else
		phi1 = splinesWages[SeventeenMore]*currSch;
	if (notLeft()){
	    ln_zeta0 = sumc(pars[SchlUtil]') + vcoef[School][CV(v)];
		if (currSch < Spline1)
			ln_zeta0 += splines[SevenToTen]*currSch;
    	else if ( currSch < Spline2 ) //changed order
			ln_zeta0 += splines[currSch-Spline1]*currSch;
    	else
			ln_zeta0 += splines[SeventeenMore]*currSch;
        if (CV(Irupt)) return ;

	    ln_w0 =  phi1 +  vcoef[Wage][CV(v)];
        ln_e0 = -exp(pars[Employ][:Sch]*(One|currSch));
        Earn = CV(leave)*(ln_w0+ln_e0*exp(0.5*sqr(stdevs[Employ])));   //expected earnings 1st year NOT actual
		return ;

	}  // will return so else not needed

	decl time, xper;
    #ifdef LTERM	
		for (time =0,xper=1,Earn=0.0; time<(maxT- I::t); ++time,++xper) {
			Earn += beta^time *( phi1 + ExpectedEarn(One|currSch|xper|sqr(xper)) );
            }
    #else
        xper = CV(Xper)+One;
        Earn = ExpectedEarn(  One|currSch|xper|sqr(xper) ) + phi1;
	#endif
}
