include("Init_Solution.jl")
using StatsBase

#01 Random destructor =========================================================================#
# destroy random k routes

function destruct_random(s, k)
    len = length(s)
    idx_set = rand(1:len, k)
    s_child = merge_mtx(s, idx_set)
    s_main = concatenate_mtx(s, idx_set)

    return s_main, s_child, 1
end


function merge_mtx(mtx_origin, idx_set)
    mtx_new = []
    for i in idx_set
        for customer in mtx_origin[i]
            if customer != 1
                append!(mtx_new, customer)
            end
        end
    end
    return mtx_new
end


function concatenate_mtx(mtx_origin, idx_set)
    len = length(mtx_origin)
    mtx_new = []
    for i = 1:len
        if !(i in idx_set)
            append!(mtx_new, mtx_origin[i, :])
        end
    end
    return mtx_new
end


#02 Expensive destructor =========================================================================#
# destroy the most expensive route with random range

function destruct_expensive(s, k)

    routes_costs = get_multiroutes_cost(s)
    idx_set = get_expensive_routes(routes_costs, 1)

    s_child = merge_mtx(s, idx_set)
    s_main = concatenate_mtx(s, idx_set)
    return s_main, s_child, 2
end


function get_expensive_routes(routes_costs, k)
    len = length(routes_costs)
    ave_cost = sum(routes_costs)/len
    idx_set = zeros(Int64, k)
    i = 1
    while i <= k
        idx = rand(1:len)
        if !(idx in idx_set) && routes_costs[idx] >= ave_cost
            idx_set[i] = idx
            i += 1
        end
    end

    return idx_set
end


function get_multiroutes_cost(s)
    len = length(s)
    routes_costs = zeros(Float32, len)
    for i in 1:len
        routes_costs[i] = get_route_cost(s[i])
    end
    return routes_costs
end

function get_route_cost(route)
    cost = 0
    for i in 1:length(route)-1
        cost += dist[route[i], route[i+1]]
    end
    return cost
end


#KNN destructor =========================================================================#
#randomly choose an element destroy the k nearest neighbors
function destruct_knn(s, k)
end

#picker =========================================================================#

function destruct_factory(s, k, w)
    opt = get_operator(w)
    if opt == "destruct_expensive"
        # println("destruct_expensive")
        return destruct_expensive(s, k)
    elseif opt == "destruct_random"
        # println("destruct_random")
        return destruct_random(s, k)
    end
end

function get_operator(w)
    operators = ["destruct_random", "destruct_expensive"]
    opt = sample(operators, Weights(w))
    return opt
end
#
# s = init_solution()
# k = 2
# w = [0.6, 0.5]
# c, m, opt = destruct_factory(s, k, w)
#
