import AlgoTuner
using AlgoTuner

include("ALNS_Solver.jl")

function getBestKnown()
    instanceSet = ["C1_2_1.TXT","C2_2_7.TXT","R1_2_7.TXT"]#,"R2_2_5.TXT"]
    bestKnown = Dict()
    for inst in instanceSet
        bestKnown[inst] = alns_solver(123, inst, 30, 1, 3, 0.005, 20, 1)
    end
    return instanceSet, bestKnown
end


benchMark, bestKnown = getBestKnown()

tunnerALNS(seed, instance, d_ran_routes, d_ratio, d_knn, d_exp_routes)=
(alns_solver(seed, instance, 30, 1, d_ran_routes, d_ratio, d_knn, d_exp_routes)
- bestKnown[instance])/bestKnown[instance]


cmd = AlgoTuner.createRuntimeCommand(tunnerALNS)

AlgoTuner.addIntParam(cmd, "d_ran_routes", 1, 4)
AlgoTuner.addFloatParam(cmd, "d_ratio", 0.003, 0.02)
AlgoTuner.addIntParam(cmd, "d_knn", 10, 40)
AlgoTuner.addIntParam(cmd, "d_exp_routes", 1, 5)



AlgoTuner.addInitialValues(cmd, [2, 0.01, 12, 2])
AlgoTuner.tune(cmd, benchMark, 1000, 3, [1234,1244,1221], AlgoTuner.ShowAll)
