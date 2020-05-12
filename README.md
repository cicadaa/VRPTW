# VRPTW
##The Vehicle Routing Problem with Time Windows

Given a set of customers to be visited by a fleet of vehicles. All vehicles are identical and have limited capacity. Each customer has some product demand, which can only be delivered within a given time window. All vehicles depart, and return, to a central depot where the product is shipped from. Your task is to find a routing plan that visits all customers and delivers all products with minimal transport distance.


## Usage

First you need to include the 'ALNS_Solver.jl' file, the main slover function is under this file
```julia
include('ALNS_Solver.jl')
```
 
Then call the `alns_solver(seed, instance, global_runtime, local_runtime, show_process=true)` function, it will return the best solution and distance found in given time. The `show_process` parameter are used to 
```julia
alns_solver(123, "data/C2_2_7.TXT", 600, 0.5) 
```