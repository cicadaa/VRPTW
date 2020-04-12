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
        # if len <= 1
        #     println("rcosts:" * string(routes_costs))
        # end

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


#03 KNN destructor =========================================================================#
#randomly choose an element destroy the k nearest neighbors


function destruct_knn(s, k)
    s_child = get_knn_child(k)
    s_main = get_knn_main(s, s_child)
    return s_main, s_child, 3
end


function get_knn_main(s, s_child)
    s0 = deepcopy(s)
    s_main = []
    for i in 1:length(s0)
        r = []
        for j in 1:length(s0[i])
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

function get_knn_child(k)
    centroid = rand(2:dim)
    s_child = []
    ls = sorted_dist[centroid]
    limit = k * 10
    for i in 1:limit
        n = ls[i][2]
        if n != 1
            append!(s_child, n)
        end
    end
    return s_child
end

#04 Pure Random destructor =========================================================================#
#randomly choose an 15% customers

function destruct_randcust(s, k)
    s_child = get_knn_child(k)
    s_main = get_randcust_main(s, s_child)
    return s_main, s_child, 4
end

function get_knn_child(k)
    size = floor(Int, dim*0.15)
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
    for i in 1:length(s0)
        r = []
        for j in 1:length(s0[i])
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

function destroy_factory(s, k, w)
    opt = get_destroy_operator(w)
    if opt == "destruct_expensive"
        return destruct_expensive(s, k)
        @goto es
    elseif opt == "destruct_random"
        return destruct_random(s, k)
        @goto es

    elseif opt == "destruct_knn"
        return destruct_knn(s, k)
        @goto es
    elseif opt == "destruct_randcust"
        return destruct_randcust(s, k)
        @goto es

    end
    @label es
end

function get_destroy_operator(w)
    d_operators = ["destruct_random", "destruct_expensive","destruct_knn","destruct_randcust"]
    opt = sample(d_operators, Weights(w))
    return opt
end


# # #
# include("Solution_Checker.jl")
# s = init_solution()
# k = 2
# w = [0,0,1]
# w_r = [1,0]

# destruct_knn(s, k)

# destroy_factory(s, k, w)
# s3, opr = repair_factory(s1, s2, w_r)
# println(typeof(s2))
# println(s2)
# println(s1)
#
# println(is_valid_solution(s3))



# w = [1,0,0]
# s1, s2, opt = destroy_factory(s, k, w)
# println(typeof(s2))
# # println(s2)
# println(opt)
# for i in 1:length(s1)
#     for c in s1[i]
#         if c in s2
#             println("not vali")
#         end
#     end
# end
