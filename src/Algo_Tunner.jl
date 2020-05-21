import AlgoTuner
using AlgoTuner

include("ALNS_Solver.jl")

function getBestKnown()
    instanceSet = ["C1_2_1.TXT","C2_2_7.TXT"]
    bestKnown = Dict()
    for inst in instanceSet
        bestKnown[inst] = alns_solver(1532, inst, 30, 2, 3, 0.01, 40, 1)
    end
    return instanceSet, bestKnown
end


benchMark, bestKnown = getBestKnown()

tunnerALNS(seed, instance, d_ran_routes, d_ratio, d_knn, d_exp_routes)=
(alns_solver(seed, instance, 30, 1, d_ran_routes, d_ratio, d_knn, d_exp_routes)
- bestKnown[instance])/bestKnown[instance]


cmd = AlgoTuner.createRuntimeCommand(tunnerALNS)

AlgoTuner.addIntParam(cmd, "d_ran_routes", 1, 10)
AlgoTuner.addFloatParam(cmd, "d_ratio", 0.005, 0.01)
AlgoTuner.addIntParam(cmd, "d_knn", 10, 60)
AlgoTuner.addIntParam(cmd, "d_exp_routes", 1, 10)



AlgoTuner.addInitialValues(cmd, [1, 0.008, 40, 2])
AlgoTuner.tune(cmd, benchMark, 800, 2, [1232,1342], AlgoTuner.ShowAll)
