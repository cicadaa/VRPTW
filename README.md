# VRPTW
##The Vehicle Routing Problem with Time Windows

Given a set of customers to be visited by a fleet of vehicles. All vehicles are identical and have limited capacity. Each customer has some product demand, which can only be delivered within a given time window. All vehicles depart, and return, to a central depot where the product is shipped from. Your task is to find a routing plan that visits all customers and delivers all products with minimal transport distance.

## Requirement
Before we start, several packages are need to be installed.
Press `]`to enter the pkg mode from the Julia REPL. To get back to the Julia REPL press backspace or ^C.
```julia
add StatsBase
add Random
add Luxor 
add Colors
add AlgoTuner
```

## Usage
First you need to include the 'ALNS_Solver.jl' file, the main solver function is under this file. 
```julia
include("ALNS_s192239/ALNS_Solver.jl")
```

Call the `alns_solver(seed, instance, g_runtime, l_runtime, show_process=true)` function, it will return the best solution and minimal vehicle number and distance. `instance` should be the path of the data file. `g_runtime` is the total running time, `l_runtime` is the running time for each local search, the unit of time is seconds. The `how_process=true` is set to true by default to show the change of the best solutions.
```julia
alns_solver(123, "data/C1_2_1.TXT", 200, 0.5)
```
