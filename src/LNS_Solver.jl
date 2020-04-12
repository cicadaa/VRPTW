include("Prepare_Data.jl")
include("Init_Solution.jl")
include("Local_Search.jl")
include("Solution_Checker.jl")
include("Destroy_Operators.jl")
include("Repair_Operators.jl")

vehicle_num, capacity, customers, coord, demand, time_window =  read_instance("C1_2_1.TXT")
dim, dist = get_distance_matrix(coord)
sorted_dist = get_sorted_dist(dist)
d_operators = ["destruct_random", "destruct_expensive"]
r_operators = ["construct_greedy"]

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
    w[opt] = w[opt] + (0.05*w_max)
    return w
end

function decrease_weight(w, opt)
    w_min = minimum(w)
    w[opt] = w[opt] - (0.001*w_min)
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
#
#     println("end:)")
#     return s_best
#
# end

function alns_solver(runtime1, runtime2, des_k, search_k)
    s_init = init_solution()
    s_best = copy(s_init)
    s_cur = copy(s_init)
    cost_cur = cost_best = get_cost(s_init)
    w = ones(Float32, length(d_operators))
    start_time = time_ns()


    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime1

        s_main, s_child, opt = destruct_factory(s_cur, des_k, w) #destruct_expensive(s_cur, des_k)
        s = construct_pertubation(s_main, s_child)
        # s_cur = copy(s)
        if is_acceptable(s, s_best, cost_best)

            s_cur = local_search3(s, runtime2, search_k)
            cost_cur = get_cost(s_cur)
            if cost_cur < cost_best
                s_best, cost_best = copy(s_cur), cost_cur
                # println(w)
                println("best cost:" *string(cost_cur) *" | best v:" * string(size(s_cur)[1]))
            end
            w = increase_weight(w, opt)
        else
            s_cur = copy(s_best)
            w = decrease_weight(w, opt)
        end
    end
    println("end:)")
    return s_best

end


solution = alns_solver(800, 6, 2, 20)

#runtime1, runtime2, des_k, search_k | 300, 1, 3, 20
println(is_valid_solution(solution))
