import AlgoTuner
using AlgoTuner

include("ALNS_Solver.jl")

function getBestKnown()
    instanceSet = ["C1_2_1.TXT","C1_2_10.TXT"]
    bestKnown = Dict()
    for inst in instanceSet
        # alns_solver(file, g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn,dk_expensive, lambda, alpha, T)
        bestKnown[inst] = alns_solver(123, inst, 50, 1, 3, 0.004, 20, 1, 0.9, 0.999, 100)
        # bestKnown[inst] = SA_Solver(123, 2, inst, 0.999, 300)
    end
    return instanceSet, bestKnown
end


benchMark, bestKnown = getBestKnown()

tunnerALNS(seed, instance, d_ran_routes, d_ratio, d_knn, d_exp_routes, lambda, alpha, T)=
(alns_solver(seed, instance, 50, 1, d_ran_routes, d_ratio, d_knn, d_exp_routes, lambda, alpha, T)
- bestKnown[instance])/bestKnown[instance]
# tunnerALNS(seed, instance, alpha, T) = (SA_Solver(seed, 3, instance, alpha, T) - bestKnown[instance])/bestKnown[instance]
# alns_solver(file, g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn, d_exp_routes, lambda, alpha, T)


cmd = AlgoTuner.createRuntimeCommand(tunnerALNS)

AlgoTuner.addIntParam(cmd, "d_ran_routes", 1, 6)
AlgoTuner.addFloatParam(cmd, "d_ratio", 0.003, 0.1)
AlgoTuner.addIntParam(cmd, "d_knn", 3, 40)
AlgoTuner.addIntParam(cmd, "d_exp_routes", 1, 6)

AlgoTuner.addFloatParam(cmd, "lambda", 0.5, 0.9999)
AlgoTuner.addFloatParam(cmd, "T", 50.00, 1000.0)
AlgoTuner.addFloatParam(cmd, "alpha", 0.5, 0.9999)



AlgoTuner.addInitialValues(cmd, [5, 0.08, 20, 5, 0.8, 300.0, 0.9999])
AlgoTuner.tune(cmd, benchMark, 1000, 2, [1234,1244], AlgoTuner.ShowAll)
#sampleSize = instanceSet Size
