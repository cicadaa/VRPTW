import Random
# using Plots

include("Prepare_Data.jl")
include("Init_Solution.jl")
include("Local_Search.jl")
include("Solution_Checker.jl")
include("Destroy_Operators.jl")
include("Repair_Operators.jl")
# include("Visualisation.jl")


#criteria manage ===============================================================
#
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


#operator manage  ==============================================================

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

function alns_solver(seed, instance, g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn, d_exp_routes)
    data = prepare_data(instance)
    d_opts, r_opts = opt_kit()
    w_d, w_r = init_weight(length(d_opts), length(r_opts))
    lambda, alpha, T = 0.9, 0.98, 300
    s_best = init_solution(data)
    cost_best = get_cost(data, s_best)


    start_time = time_ns()
    l = 0
    while round((time_ns() - start_time) / 1e9, digits = 3) < g_runtime
        score_idx = 3
        s_main, s_child, opt_d =
            destroy_factory(data, s_best, w_d, d_ran_routes, d_ratio, d_knn, d_exp_routes)
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
        # l += 1
        T = T * alpha
        w_r = update_weight(w_r, opt_r, score_idx, lambda)
        w_d = update_weight(w_d, opt_d, score_idx, lambda)
    end

    # println(l)
    # println(is_valid_solution(data, s_best))
    return cost_best

end

# solution = alns_solver(50,"R1_2_6.TXT", 10, 2, 3, 0.015, 20, 2)

#=Records

*01
best cost:2760.5696 | best v:20
solution, y = alns_solver(300, 1, 3, 0.004, 20, 1, 0.7)
g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn,  d_exp_routes, lambda)

*02
best cost:2765.5293 | best v:20
solution = alns_solver(123,"C1_2_1.TXT", 300, 2, 3, 0.015, 20, 2)

=#
