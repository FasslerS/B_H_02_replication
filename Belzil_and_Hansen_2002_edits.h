#import "DDP"

/*	 Belzil and Hansen 2002 model */
struct Schooling : Bellman {
			  enum{DadEduc,MomEduc,FamiInc,NuclearFam,Siblings,Rural,South}
			  enum{Intercept,Sch,Exp,SqrdExp}
			  enum{SchlUtil,Employ,LogWage}
			  enum{wageExp,wageExpSqrd}
			  enum{School, Wage, Employment, Mcomp}
			  enum{F_educ,M_educ,FamInc,NucFam,Sib,Rur,Sou}
			  enum{SevenToTen,Eleven,Twelve,Thirteen,Fourteen,Fifteen,Sixteen,SeventeenMore}

	/*CF: My suggested style is to make integer constants enums. Keep const for real/matrix values */

			  enum{ArbDraws = 15 , //15 Arbitrary number of draws for each type of epsilon shock
				   maxT=50,// 50?  Start at 16? 65 max Life
				   Sch0 = 6,
				   maxS=16, //22-5 max Schooling
				   Types = 6 //6 K types of individuals, each endowed with (v^w,v^zeta) (work,school) ability endowments
				   }

	static const decl
                             /*MOVED THESE BECAUSE THEY ARE CONSTANT */
						maxCounts=<maxS,maxT>,
						vectMaxT=<maxT;maxT>,
   						Environment = {"sch","wrk"},
						//uncorrelated shocks
						pars = {
						<.0094,.0070,.0204,-.0071,-.0058,-.0176>,// Parameters of School Utility
						<-2.8173,-.1309,-0.0158,.0001>,	//Employment params (Table 4)
						<.0884,-.0029>// Wage params (Table 4)
						},
					/* CF: moved these so they are treated like other parameters */
   	  					Zeta = 0.0749, // Probability of experiencing school disruption (from Table 2)
					    discrate = 0.0299, //Discount Rate (from Table 2)
						beta = ( 1/ (1+discrate)),
						splines = {-0.0743,-0.0494,-1.1676,0.2486,1.4286,-0.1151,0.3001,-0.7227},
						splinesWages = {0.0040,0.0080,0.0252,0.0227, 0.0670,-0.0195,0.0148,-0.0345},

						stdevs = < //std of shocks
									0.2251;	 //fam contribution	shock
									1.4858; //employment shock
									0.2881 //wage shock
									>,
								//   0		  1		   2	   3		4		 5
						vcoef = < -.7318, -1.1021, -.8785, -1.3206,	-1.1815, -1.4904;  //School ability
								  2.1395,  1.6797, 1.9136,  1.3774,	 1.5488,  1.0816;  //Market ability
								  -.7318,   .8329,	.3551,	1.0127,	  .1291,  0.0000   //Intercept
								  >,
					    vprob = <  .0541;   .2525;	.1566;	 .3022;   .1249;   .1098 >; //Type pobabilities

						
						
	static decl
				X, //Vector of initial family human capital endowment (need data for this)
				v, // vector of individual heterogeneity (unobserved)
				school, //control variable (if d = 1 continue school, if d = 0 then leave school for work)
				shocks, //epsilon shocks
				WorkUtil,//Work Utility
				attend,
				leave,
				L,
				Irupt,
				S;
				
	static Replicate();
	static Create();
		   Utility();
		   FeasibleActions();
				
}
