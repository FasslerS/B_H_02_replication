#import "Belzil_and_Hansen_2002_edits"

main(){
	Schooling::Create();
	VISolve();
	ComputePredictions();
//decl vmax = new ValueIteration();
//	vmax.Volume = LOUD;               //V(θ) printed when computed
//	DPDebug::outAllV();
//	vmax -> Solve(); */
  //   decl lc = new PanelPrediction("lc",vmax);
	// lc -> Predict(	20, 2);
	 



	Bellman::Delete;
	
}