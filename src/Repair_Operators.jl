
#01 Pure Greedy constructor =========================================================================#

# function construct_greedy(s_main, s_child)
#     s = deepcopy(s_main)
#     for cust in s_child
#         s = insert_cust(s, cust)
#     end
#     # println(length(s))
#     return s, 1
# end
#
# function insert_cust(s, cust)
#     x, y = get_insert_loc(s, cust)
#     if x == 0 && y == 0 # when insert location not found
#         route = copy([1, cust, 1])
#         append!(s, route)
#     else
#         route = deepcopy(s[x])
#         s[x] = insert!(route, y, cust)
#     end
#     return s
# end
#
# function get_insert_loc(s, cust)
#     min = nothing
#     x, y = 0, 0
#
#     for i = 1:length(s)
#         route = deepcopy(s[i])
#         for j = 2:length(s[i])
#             route_new = insert!(route, j, cust)
#             if is_valid_route(route_new)
#                 ist_cost = get_insert_cost(route, j, cust)
#                 if min == nothing || ist_cost <= min
#                     x, y = i, j
#                     min = ist_cost
#                 end
#             end
#         end
#     end
#
#     return x, y
# end
#
#
# function get_insert_loc(s, cust)
#     min = 0
#     x, y = 0, 0
#
#     for i = 1:length(s)
#         route = deepcopy(s[i])
#         for j = 2:length(s[i])
#             route_new = insert!(route, j, cust)
#             if is_valid_route(route_new)
#                 rand_idx = get_rand_inrange(0.8, 1.2)
#                 ist_cost = get_insert_cost(route, j, cust) * rand_idx
#                 if min == 0 || ist_cost <= min
#                     x, y = i, j
#                     min = ist_cost
#                 end
#             end
#         end
#     end
#     return x, y
# end
#
function get_insert_cost(route, insert_loc, cust)
    cust_pre = route[insert_loc-1]
    cust_nxt = route[insert_loc]
    insert_cost =
        dist[cust_pre, cust] + dist[cust, cust_nxt] -
        dist[cust_pre, cust_nxt]
    return insert_cost
end

function construct_greedy(s_main, s_child)
    s = deepcopy(s_main)
    for cust in s_child
        s = insert_greedy_cust(s, cust)
    end
    return s, 2
end

function insert_greedy_cust(s_main, cust)
    x, y = get_greedy_insert_loc(s_main, cust)
    if x == 0 && y == 0 # when insert location not found
        route = [1, cust, 1]
        push!(s_main, route)
    else
        route = deepcopy(s_main[x])
        s_main[x] = insert!(route, y, cust)
    end
    return s_main
end


function get_greedy_insert_loc(s_main, cust)
    min = nothing
    x, y = 0, 0
    for i = 1:length(s_main)
        for j = 2:length(s_main[i])
            route = deepcopy(s_main[i])
            route_new = insert!(route, j, cust)
            if is_valid_route(route_new)
                rand_idx = get_rand_inrange(0.8, 1.2)
                ist_cost = get_insert_cost(route, j, cust) * rand_idx
                if min == nothing || ist_cost <= min
                    x, y = i, j
                    min = ist_cost
                end
            end
        end
    end
    return x, y
end




#02 Greedy Pertubation constructor==============================================================================#
function construct_pertubation(s_main, s_child)
    s = deepcopy(s_main)
    for cust in s_child
        s = insert_pertubated_cust(s, cust)
    end
    return s, 2
end

function insert_pertubated_cust(s_main, cust)
    x, y = get_pertubated_insert_loc(s_main, cust)
    if x == 0 && y == 0 # when insert location not found
        route = [1, cust, 1]
        push!(s_main, route)
    else
        route = deepcopy(s_main[x])
        s_main[x] = insert!(route, y, cust)
    end
    return s_main
end


function get_pertubated_insert_loc(s_main, cust)
    min = nothing
    x, y = 0, 0
    for i = 1:length(s_main)
        for j = 2:length(s_main[i])
            route = deepcopy(s_main[i])
            route_new = insert!(route, j, cust)
            if is_valid_route(route_new)
                rand_idx = get_rand_inrange(0.8, 1.2)
                ist_cost = get_insert_cost(route, j, cust) * rand_idx
                if min == nothing || ist_cost <= min
                    x, y = i, j
                    min = ist_cost
                end
            end
        end
    end
    return x, y
end


function get_rand_inrange(a::Float64, b::Float64)
    scale = 1 / (b - a)
    mid = (a+b)/2
    init = rand(1)[1]
    randnum = (init-0.5)/scale  + mid
    return randnum
end




#**picker==============================================================================#

function repair_factory(s_main, s_child, w)
    opt = get_repair_operator(w)
    if opt == "construct_greedy"
        return construct_greedy(s_main, s_child)
    elseif opt == "construct_pertubation"
        return construct_pertubation(s_main, s_child)
    end
end

function get_repair_operator(w)
    r_operators = ["construct_greedy", "construct_pertubation"]
    opt = sample(r_operators, Weights(w))
    return opt
end
