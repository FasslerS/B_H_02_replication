#include "Belzil_and_Hansen_2002_edits.h"

Schooling::Replicate() {
	  decl S, T, Zeta, disc, Omega, chol, ArbDraws, Exper;


	 decl sig = unit(Mcomp);
	  T=65;
	  Omega = stdevs.*sig.*stdevs';
	  chol = choleski(Omega);

	  Zeta = 0.0749; // Probability of experiencing school disruption (from Table 2)
	  disc = 0.0299; //Discount Rate (from Table 2)
	  ArbDraws = 15;//Arbitrary number of draws for each type of epsilon shock

	/* DP Model Setup */
	Initialize(new Schooling());
	
		SetClock(NormalAging,T);
		Actions			(school = new BinaryChoice("Continue"));//d in the paper-- remember this choice will be conditional on entering on a state variable I, if I = 0 then d = 1, else if I = 1 then d = 1 or 0
		ExogenousStates (shocks = new MVNvectorized("eps", ArbDraws,Mcomp,{zeros(Mcomp,1),vech(chol)}));
		EndogenousStates(S = new ActionCounter("totSch",maxS,school,1));
		GroupVariables	(v = new RandomEffect("v",Types, vprob) );
		SetDelta(0.95);
	    
		



		//I'm not sure whether we should calculate all possible experience if individual left with some school S, or we calculate experience for each t (T - S)

    /* CREATE SPACES!!! */

    }

/*  IF YOU DEFINE THIS IT HAS TO RETURN VECTOR OF 0s ... CAN"T LEAVE IT BLANK */
/*BHE2002::FeasibleActions(){	 //here I think will go the I condition, with prob. zeta


}
 */
Schooling::Create() {
	//Initialize(new Schooling());	
	Replicate();
	CreateSpaces();		
	
}

Schooling::Utility(){
	decl Exper,currSch;
	currSch = CV(S);
	Exper = 1;
	print("This is current vcoef: ",vcoef*CV(v));
	print("This is AV(shocks): ", AV(shocks) );
	print("This is pars[lwage]*exper: ", pars[LogWage]*(Exper|Exper^2) );
	print("thing I'm currently trying to multiply: ",(1|currSch[6]|Exper|Exper^2));
	 /*YOU CAN'T SET EXPER ONCE .... S is a variable.  You have to compute Exper inside Utility and use CV(S)!!! */
	print(currSch);
 /* Work Utility */	 //I need to fix these utilities...	
    ln_w = pars[LogWage] * (Exper|Exper^2) + vcoef*CV(v) + AV(shocks)';
    ln_e = pars[Employ] * (1|currSch|Exper|Exper^2) + AV(shocks)';
    WorkUtil = ln_w + ln_e;

/* School Utility */  //need to add in heterogenous ability v
    ln_zeta = pars[SchlUtil]'*X[F_educ:Sou] +  shocks[0];

	if (S < 10) {
		ln_zeta += splines[SevenToTen]*S;
		}
    else if ( S>16 && S<22 ){
		ln_zeta += splines[SeventeenMore]*S;
	}
   
    else
		ln_zeta += splines[S-10]*S;
	print(ln_zeta);

	return ln_zeta .|| WorkUtil;
    /* MUST RETURN SOMETHING */
    
}


