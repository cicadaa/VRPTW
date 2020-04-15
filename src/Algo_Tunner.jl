import AlgoTuner
using AlgoTuner

include("ALNS_Solver.jl")

function getBestKnown()
    instanceSet = ["berlin52_7542.tsp","ch150_6528.tsp"]
    bestKnown = Dict()
    for inst in instanceSet
        bestKnown[inst] = SA_Solver(123, 2, inst, 0.999, 300)
    end
    return instanceSet, bestKnown
end


benchMark, bestKnown = getBestKnown()

tunnerSA(seed, instance, alpha, T) = (SA_Solver(seed, 3, instance, alpha, T) - bestKnown[instance])/bestKnown[instance]


cmd = AlgoTuner.createRuntimeCommand(tunnerSA)


AlgoTuner.addFloatParam(cmd, "T", 50.00, 200.0)


AlgoTuner.addFloatParam(cmd, "alpha", 0.5, 0.9999)


AlgoTuner.addInitialValues(cmd, [100.00, 0.999])
AlgoTuner.tune(cmd, benchMark, 300, 2, [1234,1244], AlgoTuner.ShowAll)
#sampleSize = instanceSet Size
