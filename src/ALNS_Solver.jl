import Random
using Plots

include("Prepare_Data.jl")
include("Init_Solution.jl")
include("Local_Search.jl")
include("Solution_Checker.jl")
include("Destroy_Operators.jl")
include("Repair_Operators.jl")
# include("Visualisation.jl")


#criteria manage ===============================================================

function is_acceptable(cost, cost_best, s, s_best, T)
    bar = exp(-abs(cost - cost_best) / T)
    rand_set = rand(Float32, 1)
    acpt_prob = rand_set[1]
    if (cost < cost_best && length(s) <= length(s_best)) || acpt_prob < bar
        return true
    else
        return false
    end
end

#weight manage  ===============================================================

function init_weight(d_num, r_num)
    w_d = ones(Float32, d_num)
    w_r = ones(Float32, r_num)
    return w_d, w_r
end

function update_weight(w, opt, score_idx, lambda)
    w0 = copy(w)
    score_set = [10, 5, 0.5]
    score = score_set[score_idx]
    w0[opt] = round(lambda * w0[opt] + (1 - lambda) * score, digits = 2)
    return w0
end

#operator manage  ===============================================================
function opt_kit()
    d_opts = [
        "destruct_random",
        "destruct_expensive",
        "destruct_knn",
        "destruct_randcust",
    ]
    r_opts = ["construct_greedy", "construct_pertubation"]
    return d_opts, r_opts
end

#ALNS solver ===============================================================


function alns_solver(file,g_runtime,l_runtime,d_ran_routes,d_ratio,d_knn,k,lambda,alpha,T)
    data = prepare_data(file)
    d_opts, r_opts = opt_kit()
    w_d, w_r = init_weight(length(d_opts), length(r_opts))

    s_best = init_solution(data)
    s_c = deepcopy(s_best)
    cost_best = get_cost(data, s_best)


    start_time = time_ns()
    l = 0
    while round((time_ns() - start_time) / 1e9, digits = 3) < g_runtime
        score_idx = 3
        s_main, s_child, opt_d =
            destroy_factory(data, s_best, w_d, d_ran_routes, d_ratio, d_knn, k)
        s, opt_r = repair_factory(data, s_main, s_child, w_r)
        cost = get_cost(data, s)

        if is_acceptable(cost, cost_best, s, s_best, T)

            score_idx = 2
            # s_local = local_search_2opt(s, l_runtime)
            # cost_local = get_cost(s_local)
            if cost < cost_best
                score_idx = 1
                s_best, cost_best = deepcopy(s), cost
                # println(
                #     "best cost:" *
                #     string(cost) *
                #     " | best v:" *
                #     string(length(s)),
                # )
            end
        end
        T = T * alpha
        w_r = update_weight(w_r, opt_r, score_idx, lambda)
        w_d = update_weight(w_d, opt_d, score_idx, lambda)
    end
    # println(w_d)
    # println(w_r)
    # println(is_valid_solution(data, s_best))
    return s_best

end

solution = alns_solver("C1_2_1.TXT", 5, 1, 3, 0.004, 20, 1, 0.7, 0.99, 100)
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
