//#define LTERM
#import "Belzil_and_Hansen_2002_edits"

main(){
	Schooling::Create();
	//VISolve(); ComputePredictions();
    decl vmax = new ValueIteration();
//    DPDebug :: outAllV ( TRUE, 0 , FALSE,TRUE, TRUE);	//trimmed
	DPDebug :: outAllV ( TRUE, 0); //non-trimmed - includes terminal states
    decl lc = new PanelPrediction("lc",vmax,Schooling::Irupt->Transit());
	lc -> Predict(Schooling::maxT,1);
	
	Bellman::Delete;
	
}
