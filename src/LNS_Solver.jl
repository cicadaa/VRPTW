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
d_operators = ["destruct_random", "destruct_expensive"]#, "destruct_knn"]
r_operators = ["construct_greedy", "construct_pertubation"]


function is_acceptable(s_cur, s_best, cost_best)
    cost_cur = get_cost(s_cur)
    if cost_cur < cost_best && length(s_cur) <= length(s_best)
        return true
    else
        return false
    end
end


function increase_weight(w, opt)
    w_max = maximum(w)
    w[opt] = w[opt] + (0.07*w_max)
    return w
end


function decrease_weight(w, opt)
    w_min = minimum(w)
    w[opt] = w[opt] - (0.0005*w_min)
    return w
end

#==============================================================================#

# function lns_solver(runtime1, runtime2, des_k, search_k)
#     s_init = init_solution()
#     s_best = copy(s_init)
#     s_cur = copy(s_init)
#
#     cost_cur = cost_best = get_cost(s_init)
#     start_time = time_ns()
#
#     while round((time_ns() - start_time) / 1e9, digits = 3) < runtime1
#
#         s_main, s_child = destruct_expensive(s_cur, des_k)
#         s = construct(s_main, s_child)
#         s_cur = copy(s)
#         if is_acceptable(s_cur, s_best, cost_best)#cost_cur <= cost_best && size(s_cur)[1] <= size(s_best)[1]
#             s_cur = local_search3(s, runtime2, search_k)
#             cost_cur = get_cost(s_cur)
#             if cost_cur < cost_best
#                 s_best, cost_best = copy(s_cur), cost_cur
#                 println("best cost:" *string(cost_cur) *" | best v:" * string(size(s_cur)[1]))
#             end
#         else
#             s_cur = copy(s_best)
#         end
#     end
#     println("end:)")
#     return s_best
# end

function alns_solver(runtime1, runtime2, des_k, search_k)

    s_best = init_solution()
    cost_best = get_cost(s_best)

    w_d = ones(Float32, length(d_operators))
    w_r = ones(Float32, length(r_operators))
    start_time = time_ns()

    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime1

        s_main, s_child, opt_d = destroy_factory(s_best, des_k, w_d) #destruct_expensive(s_cur, des_k)
        s, opt_r = repair_factory(s_main, s_child, w_r)

        if is_acceptable(s, s_best, cost_best)
            s = local_search3(s, runtime2, search_k)
            cost = get_cost(s)
            if cost < cost_best
                s_best, cost_best = copy(s), cost
                println("best cost:" *string(cost) *" | best v:" * string(length(s)))
            end
            w_d = increase_weight(w_d, opt_d)
            w_r = increase_weight(w_r, opt_r)

        else
            # s_cur = copy(s_best)
            w_d = decrease_weight(w_d, opt_d)
            w_r = decrease_weight(w_r, opt_r)

        end
    end
    println(w_d)
    println(w_r)

    println("end:)")
    return s_best

end


solution = alns_solver(240, 2, 3, 30)

#runtime1, runtime2, des_k, search_k | 300, 1, 3, 20
println(is_valid_solution(solution))
