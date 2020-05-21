include("Init_Solution.jl")
using StatsBase
#01 Random destructor ==========================================================
#destroy random k routes

function destruct_random(data, s, d_ran_routes)
    len = length(s)
    idx_set = rand(1:len, d_ran_routes)
    s_child = merge_mtx(s, idx_set)
    s_main = concatenate_mtx(s, idx_set)

    return s_main, s_child, 1
end


function merge_mtx(s, idx_set)
    s_new = []
    for i in idx_set
        for customer in s[i]
            if customer != 1
                append!(s_new, customer)
            end
        end
    end
    return s_new
end


function concatenate_mtx(s, idx_set)
    len = length(s)
    s_new = []
    for i = 1:len
        if !(i in idx_set)
            append!(s_new, s[i, :])
        end
    end
    return s_new
end


#=02 Expensive destructor ======================================================
destroy the most expensive route with random range=#

function destruct_expensive(data, s, d_exp_routes)

    routes_costs = get_multiroutes_cost(data, s)
    idx_set = get_expensive_routes(routes_costs, d_exp_routes)

    s_child = merge_mtx(s, idx_set)
    s_main = concatenate_mtx(s, idx_set)
    return s_main, s_child, 2
end


function get_expensive_routes(routes_costs, d_exp_routes)
    len = length(routes_costs)
    ave_cost = sum(routes_costs) / len
    idx_set = zeros(Int64, d_exp_routes)
    i = 1
    while i <= d_exp_routes
        idx = rand(1:len)
        if !(idx in idx_set) && routes_costs[idx] >= ave_cost
            idx_set[i] = idx
            i += 1
        end
    end

    return idx_set
end


function get_multiroutes_cost(data, s)
    len = length(s)
    routes_costs = zeros(Float32, len)
    for i = 1:len
        routes_costs[i] = get_route_cost(data, s[i])
    end
    return routes_costs
end


function get_route_cost(data, route)
    dist = data["dist"]
    cost = 0
    for i = 1:length(route)-1
        cost += dist[route[i], route[i+1]]
    end
    return cost
end


#03 KNN destructor =========================================================================#
#randomly choose an element destroy the k nearest neighbors


function destruct_knn(data, s, d_knn)
    s_child = get_knn_child(data, d_knn)
    s_main = get_knn_main(s, s_child)
    return s_main, s_child, 3
end


function get_knn_main(s, s_child)
    s0 = deepcopy(s)
    s_main = []
    for i = 1:length(s0)
        r = []
        for j = 1:length(s0[i])
            c = s0[i][j]
            if !(c in s_child)
                append!(r, c)
            end
        end
        if length(r) > 2
            push!(s_main, r)
        end
    end
    return s_main
end

function get_knn_child(data, d_knn)
    dim = data["dim"]
    sorted_dist = data["sorted_dist"]

    centroid = rand(2:dim)
    s_child = []
    ls = sorted_dist[centroid]
    for i = 1:d_knn
        n = ls[i][2]
        if n != 1
            append!(s_child, n)
        end
    end
    return s_child
end

#04 Pure Random destructor =========================================================================#
#randomly choose an 15% customers

function destruct_randcust(data, s, d_ratio)
    s_child = get_randcust_child(data, d_ratio)
    s_main = get_randcust_main(s, s_child)
    return s_main, s_child, 4
end

function get_randcust_child(data, d_ratio)
    dim = data["dim"]
    size = floor(Int, dim * d_ratio)
    s_child = []
    while size > 0
        c = rand(2:dim)
        if c != 1 && !(c in s_child)
            append!(s_child, c)
            size -= 1
        end
    end
    return s_child
end

function get_randcust_main(s, s_child)
    s0 = deepcopy(s)
    s_main = []
    for i = 1:length(s0)
        r = []
        for j = 1:length(s0[i])
            c = s0[i][j]
            if !(c in s_child)
                append!(r, c)
            end
        end
        if length(r) > 2
            push!(s_main, r)
        end
    end
    return s_main
end

#picker =========================================================================#

function destroy_factory(data, s, w)
    d_ran_routes, d_ratio, d_knn, d_exp_routes = 3, 0.005, 20, 1
    Q = data["Q"]
    amp_factor = 1
    if Q > 200
        amp_factor = 30
        d_knn = 40
    end
    opt = get_destroy_operator(w)
    if opt == "destruct_expensive"
        return destruct_expensive(data, s, d_exp_routes)
        @goto es
    elseif opt == "destruct_random"
        return destruct_random(data, s, d_ran_routes)
        @goto es
    elseif opt == "destruct_knn"
        return destruct_knn(data, s, d_knn)
        @goto es
    elseif opt == "destruct_randcust"
        return destruct_randcust(data, s, d_ratio*amp_factor)
        @goto es

    end
    @label es
end

function get_destroy_operator(w)
    d_operators = [
        "destruct_random",
        "destruct_expensive",
        "destruct_knn",
        "destruct_randcust",
    ]
    opt = sample(d_operators, Weights(w))
    return opt
end
