import Random
using Plots

include("Prepare_Data.jl")
include("Init_Solution.jl")
include("Local_Search.jl")
include("Solution_Checker.jl")
include("Destroy_Operators.jl")
include("Repair_Operators.jl")
# include("Visualisation.jl")

vehicle_num, capacity, customers, coord, demand, time_window =  read_instance("C1_2_1.TXT")
dim, dist = get_distance_matrix(coord)
sorted_dist = get_sorted_dist(dist)
d_operators = ["destruct_random", "destruct_expensive", "destruct_knn", "destruct_randcust"]
r_operators = ["construct_greedy", "construct_pertubation"]


#criteria manage ===============================================================

function is_acceptable(s_cur, s_best, cost_best)
    cost_cur = get_cost(s_cur)
    rand_num = 1#get_rand_inrange(0.98, 1.2)
    if cost_cur < cost_best*rand_num && length(s_cur) <= length(s_best)
        return true
    else
        return false
    end
end

#weight manage ===============================================================

function update_weight(w, opt, score_idx, lambda)
    w0 = copy(w)
    score_set = [10,5,0.5]
    score = score_set[score_idx]
    w0[opt] = round(lambda * w0[opt] + (1 - lambda)*score, digits=2)
    return w0
end


# function decrease_weight(w, opt::Int64)
#     w_min = minimum(w)
#     w[opt] = 0.25*w[opt] +0.75 *w_min
#     return w
# end


#ALNS solver ===============================================================


function alns_solver(g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn, k, lambda)
    s_best = init_solution()
    s_c = deepcopy(s_best)
    cost_best = get_cost(s_best)
    We = []
    w_d = ones(Float32, length(d_operators))
    # w_d = [1,2,1,3]
    w_r = ones(Float32, length(r_operators))

    start_time = time_ns()
    l = 0
    while round((time_ns() - start_time) / 1e9, digits = 3) < g_runtime
        score_idx = 3
        s_main, s_child, opt_d = destroy_factory(s_best, w_d, d_ran_routes, d_ratio, d_knn, k)
        s, opt_r = repair_factory(s_main, s_child, w_r)
        cost = get_cost(s)

        if is_acceptable(s, s_best, cost_best)
            score_idx = 2
            # s_local = local_search_2opt(s, l_runtime)

            # cost_local = get_cost(s_local)
            if cost < cost_best
                score_idx = 1
                s_best, cost_best = deepcopy(s), cost
                println("best cost:" *string(cost) *" | best v:" * string(length(s)))
            end
        end
        w_r = update_weight(w_r, opt_r, score_idx, lambda)
        w_d = update_weight(w_d, opt_d, score_idx, lambda)
        l += 1
        push!(We, w_d)

    end
    println(w_d)
    println(w_r)
    println("end:)")
    return s_best, We, l

end


solution, y, l = alns_solver(300, 1, 3, 0.004, 20, 1, 0.7)
# solution = alns_solver(g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn,  d_exp_routes, lambda)
#=
records

*06
best cost:2760.5696 | best v:20
solution, y = alns_solver(300, 1, 3, 0.004, 20, 1, 0.7)
g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn,  d_exp_routes, lambda)

*07
solution, y, l = alns_solver(300, 1, 3, 0.015, 30, 2, 0.95)
g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn,  d_exp_routes, lambda)
w0[opt] = round(((lambda+1) * w0[opt] + (1 - lambda)*score)/2, digits=2)

=#


println(is_valid_solution(solution))
# println(solution)
# print
# remove_random_route = zeros(Float32, l)
# remove_kexpensive_route = zeros(Float32, l)
# remove_knn = zeros(Float32, l)
# remove_ran_cust = zeros(Float32, l)
#
# for i in 1:l
#     # println(y[i])
#     remove_random_route[i] = y[i][1]
#     remove_kexpensive_route[i] = y[i][2]
#     remove_knn[i] = y[i][3]
#     remove_knn[i] = y[i][4]
# end
# x = 1:l
# println("here")
# plot(1:l, [remove_random_route, remove_kexpensive_route, remove_knn, remove_ran_cust])
