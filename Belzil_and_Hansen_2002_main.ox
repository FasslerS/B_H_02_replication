#import "Belzil_and_Hansen_2002_edits"

main(){
	Schooling::Create();
//	VISolve();
decl vmax = new ValueIteration();
	vmax.Volume = LOUD;               //V(θ) printed when computed
	vmax -> Solve();




	Bellman::Delete;
	
}