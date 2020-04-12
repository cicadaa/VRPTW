import Random

include("Prepare_Data.jl")
include("Init_Solution.jl")
include("Local_Search.jl")
include("Solution_Checker.jl")
include("Destroy_Operators.jl")
include("Repair_Operators.jl")

vehicle_num, capacity, customers, coord, demand, time_window =  read_instance("C1_2_1.TXT")
dim, dist = get_distance_matrix(coord)
sorted_dist = get_sorted_dist(dist)
d_operators = ["destruct_random", "destruct_expensive", "destruct_knn","destruct_randcust"]
r_operators = ["construct_greedy", "construct_pertubation"]


function is_acceptable(s_cur, s_best, cost_best)
    cost_cur = get_cost(s_cur)
    rand_num = 1#get_rand_inrange(0.98, 1.2)
    if cost_cur < cost_best*rand_num && length(s_cur) <= length(s_best)
        return true
    else
        return false
    end
end


function increase_weight(w, opt)
    w_max = maximum(w)
    w[opt] = w[opt] + (0.08*w_max)
    return w
end


function decrease_weight(w, opt)
    w_min = minimum(w)
    w[opt] = w[opt] - (0.0001*w_min)
    return w
end

#==============================================================================#

# function lns_solver(runtime1, runtime2, des_k, search_k)
#     s_init = init_solution()
#     s_best = deepcopy(s_init)
#     s_cur = deepcopy(s_init)
#
#     cost_cur = cost_best = get_cost(s_init)
#     start_time = time_ns()
#
#     while round((time_ns() - start_time) / 1e9, digits = 3) < runtime1
#
#         s_main, s_child = destruct_expensive(s_cur, des_k)
#         s = construct(s_main, s_child)
#         s_cur = deepcopy(s)
#         if is_acceptable(s_cur, s_best, cost_best)#cost_cur <= cost_best && size(s_cur)[1] <= size(s_best)[1]
#             s_cur = local_search3(s, runtime2, search_k)
#             cost_cur = get_cost(s_cur)
#             if cost_cur < cost_best
#                 s_best, cost_best = deepcopy(s_cur), cost_cur
#                 println("best cost:" *string(cost_cur) *" | best v:" * string(size(s_cur)[1]))
#             end
#         else
#             s_cur = deepcopy(s_best)
#         end
#     end
#     println("end:)")
#     return s_best
# end

function alns_solver(runtime1, runtime2, des_k, search_k)
    s_best = init_solution()
    s_c = deepcopy(s_best)
    cost_best = get_cost(s_best)

    w_d = ones(Float32, length(d_operators))
    w_r = ones(Float32, length(r_operators))

    start_time = time_ns()
    l = 0
    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime1
        s_main, s_child, opt_d = destroy_factory(s_c, des_k, w_d)
        s, opt_r = repair_factory(s_main, s_child, w_r)
        cost = get_cost(s)
        # println("best cost:" *string(cost) *" | best v:" * string(length(s)))

        # println("s:" *string(s) )

        if is_acceptable(s, s_best, cost_best)
            s = local_search3(s, runtime2, search_k)
            s_c = deepcopy(s)

            if cost < cost_best
                s_best, cost_best = deepcopy(s), cost
                println("best cost:" *string(cost) *" | best v:" * string(length(s)))
            end
            w_d = increase_weight(w_d, opt_d)
            w_r = increase_weight(w_r, opt_r)
        else
            w_d = decrease_weight(w_d, opt_d)
            w_r = decrease_weight(w_r, opt_r)

        end
        l += 1
    end
    println(w_d)
    println(w_r)
    println("end:)")
    return s_best

end


solution = alns_solver(600, 2, 3, 10)

#runtime1, runtime2, des_k, search_k | 160, 2, 3, 30
#record
#01
#500, 6, 3, 30
#best cost:4269.46 | best v:22
#3
println(is_valid_solution(solution))
