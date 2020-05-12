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

function is_acceptable(cost, cost_best, s, s_best, T)
    bar = exp(-abs(cost - cost_best) / T)
    rand_set = rand(Float32, 1)
    acpt_prob = rand_set[1]
    if cost < cost_best || length(s) < length(s_best) || acpt_prob < bar
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
    # score_set = [10, 2, 0.5]
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

function get_amp_idx(data)
    Q = data["Q"]
    demands = sum(data["demand"])
    idx = false
    if demands/Q < 16
        idx = true
    end
    return idx
end

#ALNS solver ===============================================================

function alns_solver(seed, instance, g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn, d_exp_routes)
    data = prepare_data(instance)

    amp_idx = get_amp_idx(data)
    d_opts, r_opts = opt_kit()
    w_d, w_r = init_weight(length(d_opts), length(r_opts))
    # lambda, alpha, T = 0.95, 0.8, 100
    lambda, alpha, T = 0.95, 0.95, 200
    s_best = init_solution(data)
    cost_best = get_cost(data, s_best)


    start_time = time_ns()
    l = 0
    W = []
    while round((time_ns() - start_time) / 1e9, digits = 3) < g_runtime
        score_idx = 3
        s_main, s_child, opt_d =
            destroy_factory(data, s_best, w_d, d_ran_routes, d_ratio, d_knn, d_exp_routes)
        s, opt_r = repair_factory(data, s_main, s_child, w_r)
        cost = get_cost(data, s)

        if is_acceptable(cost, cost_best, s, s_best, T)

            score_idx = 2
            if amp_idx
                s = local_search_2opt(data, s, l_runtime)
                cost = get_cost(data, s)
            end
            if cost < cost_best
                score_idx = 1
                s_best, cost_best = deepcopy(s), cost
                println(
                    "best cost:" *
                    string(cost) *
                    " | best v:" *
                    string(length(s)),
                )
            end
        end
        l += 1
        T = T * alpha
        w_r = update_weight(w_r, opt_r, score_idx, lambda)
        w_d = update_weight(w_d, opt_d, score_idx, lambda)
        push!(W, w_d)
    end

    println(w_d)
    println(is_valid_solution(data, s_best))
    return W, l
    return 0.001*cost_best + length(s_best)
    return cost_best, length(s_best)

end

# solution = alns_solver(3012,"R1_2_1.TXT", 500, 1, 3, 0.0005, 20, 2)
# c, s = alns_solver(123, "C1_2_1.TXT", 500, 1, 3, 0.005, 20, 1) #3133.8298 | best v:21
# c, s = alns_solver(123, "C1_2_1.TXT", 200, 0.5, 3, 0.005, 40, 1) #
# c, s = alns_solver(123, "R1_2_7.TXT", 200, 0.5, 3, 0.005, 40, 1)#5083.3003 | best v:19
c, s = alns_solver(123, "R2_2_5.TXT", 200, 1, 3, 0.005, 40, 1)#4944.89 | best v:5

function batch_planner(t, d1, d2, d3, d4,note)
    instan = ["C1_2_1.TXT", "C1_2_8.TXT","R1_2_7.TXT", "R2_2_5.TXT"]
    ans =[]
    for ist in instan
        distan = zeros(Float32, 3)
        vehi = zeros(Float32, 3)
        for i in 1:3
            c, s = alns_solver(123, ist, t, 1, d1, d2, d3, d4)
            distan[i] = c
            vehi[i] = s
        end
        av_d = sum(distan)/3
        av_s = sum(vehi)/3
        append!(ans, (av_d, av_s))
        # println(ist*"--"*string(1))
    end
    println("Note: "*string(note))
    println(ans)
end

# batch_planner(100, 1, 0.15, 20, 2, "before tuning")
# batch_planner(100, 1, 0.007, 34, 4, "After tuning")

#=Records

*01
best cost:2760.5696 | best v:20
solution, y = alns_solver(300, 1, 3, 0.004, 20, 1, 0.7)
g_runtime, l_runtime, d_ran_routes, d_ratio, d_knn,  d_exp_routes, lambda)

*02
best cost:2765.5293 | best v:20
# solution = alns_solver(123,"C1_2_1.TXT", 300, 2, 3, 0.015, 20, 2)

Any[3394.8774f0, 21.2f0, 4188.108f0, 21.8f0, 5309.678f0, 20.4f0, 5433.2183f0, 12.8f0]
Any[3403.6282f0, 21.6f0, 4147.4f0, 21.4f0, 5360.098f0, 19.0f0, 5494.3945f0, 13.8f0]
=#
#visual
# function draw_weghts(W, l)
#     w1 = zeros(Float32, l)
#     w2 = zeros(Float32, l)
#     w3 = zeros(Float32, l)
#     w4 = zeros(Float32, l)
#     for i in 5:l
#         w1[i], w2[i], w3[i], w4[i] = (W[i][1]+sum(w1[i-4:i-1]))/5,  (W[i][2]+sum(w2[i-4:i-1]))/5,  (W[i][3]+sum(w3[i-4:i-1]))/5, (W[i][4]+sum(w4[i-4:i-1]))/5
#     end
#     plot(1:l,[w1,w2,w3,w4], label = ["Random routes removal" "Above average removal" "Geographic removal" "Random customer removal"])#, legend=:topleft)
#     ylabel!("Weight of destructor")
#     xlabel!("Iteration")
# end
# W, l = alns_solver(123, "C1_2_1.TXT", 30, 1, 1, 0.06, 20, 3)
# draw_weghts(W, l)

#Note: before tuning
#Any[3743.8564f0, 21.666666f0, 5066.61f0, 23.0f0, 5696.3496f0, 19.666666f0, 5569.5063f0, 12.333333f0]

#=

alns_solver(123, "C1_2_1.TXT", 200, 1, 1, 0.005, 20, 1)
2957.2295 | best v:20

alns_solver(123, "R1_2_7.TXT", 200, 1, 2, 0.005, 20, 2)
best cost:5239.269 | best v:18


=#
