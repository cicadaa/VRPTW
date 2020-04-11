# include("initialSolution.jl")
s0 = initSolution()

function local_search2(s, runtime, k)
    s_local = copy(s)
    start_time = time_ns()
    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime
        customer_a, loc_a = get_random_customer(s_local)
        neighbors = get_neighbors(sorted_dist, customer_a, k)
        best_loc = nothing
        candidate = nothing

        for i in 1:length(neighbors)
            n = neighbors[i]
            loc_n = get_location(n, s_local)
            if loc_n[1] == nothing
                println(string(customer_a)*" a loc -----")
                println(string(n)*" n loc nothing")

            end
            route_a = copy(s_local[loc_a[1]])
            route_n = copy(s_local[loc_n[1]])
            new_route_a = get_swap_route(route_a, n, loc_a[2])
            new_route_n = get_swap_route(route_n, customer_a, loc_n[2])
            if is_feasible_swap(new_route_n, new_route_a)
                new_cost = get_route_cost(new_route_a) + get_route_cost(new_route_n)
                cost = get_route_cost(route_a) + get_route_cost(route_n)
                if new_cost < cost
                    candidate = n
                    best_loc = loc_n
                end
            end
        end
        if best_loc != nothing && candidate != nothing
            s_local[loc_a[1]][loc_a[2]] = candidate
            s_local[best_loc[1]][best_loc[2]] = customer_a
        end
    end
    @label escp
    # println("local check: "*string(check_solution(s_local)))
    return s_local
end

function local_search3(s, runtime, k)
    s_local = copy(s)
    start_time = time_ns()
    # a = 0
    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime
        customer_a, loc_a = get_random_customer(s_local)
        neighbors = get_neighbors(sorted_dist, customer_a, k)
        best_loc = nothing
        candidate = nothing
        i = 1
        while i < 20
            n = neighbors[rand(1:length(neighbors))]
            loc_n = get_location(n, s_local)
            if loc_n == nothing
                println("find "*string(n))
                checklen(s_local)
                # @goto es
            end

            route_a = copy(s_local[loc_a[1]])
            route_n = copy(s_local[loc_n[1]])
            new_route_a = get_swap_route(route_a, n, loc_a[2])
            new_route_n = get_swap_route(route_n, customer_a, loc_n[2])
            if is_feasible_swap(new_route_n, new_route_a)
                new_cost = get_route_cost(new_route_a) + get_route_cost(new_route_n)
                cost = get_route_cost(route_a) + get_route_cost(route_n)
                if new_cost < 0.95*cost
                    candidate = n
                    best_loc = loc_n
                    # @goto es
                end
            end
            i+= 1
        end
        if best_loc != nothing && candidate != nothing
            # println("before :"*string(s_local[loc_a[1]][loc_a[2]])*" | "*string(s_local[best_loc[1]][best_loc[2]]))
            # println("after :"*string(s_local[loc_a[1]])*" | "*string(s_local[best_loc[1]]))
            s_local[loc_a[1]][loc_a[2]] = candidate
            s_local[best_loc[1]][best_loc[2]] = customer_a
            # println(string(loc_a)*" | "*string(best_loc))
            # println("after :"*string(s_local[loc_a[1]])*" | "*string(s_local[best_loc[1]]))
            # println("after :"*string(s_local[loc_a[1]][loc_a[2]])*" | "*string(s_local[best_loc[1]][best_loc[2]]))
        end
    end
    # println("-------------")
    # println("-------------")
    # println("-------------")
    # checklen(s_local)
    # println("local check: "*string(check_solution(s_local)))
    # @label es
    return s_local

end

function get_route_cost(route)
    cost = 0
    for i in 1:length(route)-1
        cost += dist[route[i], route[i+1]]
    end
    return cost
end

function get_location(n, s)
    for i in 1:length(s)
        for j in 1:length(s[i])
            if s[i][j] == n
                return (i, j)
            end
        end
    end
end


function get_neighbors(sorted_dist, customer, k)
    idxed_route = sorted_dist[customer]
    neighbors = zeros(Int32, k)
    i = 1
    j = 1
    while i <= k
        if idxed_route[j][2] != 1
            neighbors[i] = idxed_route[j][2]
            i += 1
        end
        j+=1
    end
    return neighbors
end


#==============================================================================#


# function local_search(s, runtime)
#     s_local = s
#     start_time = time_ns()
#     while round((time_ns() - start_time) / 1e9, digits = 3) < runtime
#         customer_a, loc_a = get_random_customer(s_local)
#         customer_b, loc_b = get_random_customer(s_local)
#
#         new_route_a = get_swap_route(s_local, customer_b, loc_a)
#         new_route_b = get_swap_route(s_local, customer_a, loc_b)
#
#         if is_feasible_swap(new_route_a, new_route_b)
#             new_cost = get_cost(new_route_a) + get_cost(new_route_b)
#             cost = get_cost(s_local[loc_a[1]]) + get_cost(s_local[loc_b[1]])
#
#             if cost > new_cost
#                 s_local[loc_a[1]][loc_a[2]] = customer_a
#                 s_local[loc_b[1]][loc_b[2]] = customer_b
#                 println("cost:" *string(get_cost(s_local)) *" | best v:" * string(size(s_local)[1]))
#
#             end
#         end
#     end
#     return s_local
# end
# function get_swap_cost(s, loc_a, loc_b, customer_a, customer_b)
#     new_route_a = copy(s[loc_a[1]])
#     new_route_b = copy(s[loc_b[1]])
#
#     new_route_a[loc_a[2]] = customer_b
#     new_route_b[loc_b[2]] = customer_a
#
#     new_cost_a = get_cost(new_route_a)
#     new_cost_b = get_cost(new_route_b)
#
#     return new_cost_a + new_cost_b
# end

function get_swap_route(route, new_customer, loc)
    new_route = copy(route)
    new_route[loc] = new_customer
    return new_route
end

function is_feasible_swap(route_1, route_2)
    valid = false
    if is_valid_route(route_1) && is_valid_route(route_2)
        valid = true
    end
    return valid
end

function get_random_customer(s)
    i = rand(1:length(s))
    j = rand(2:length(s[i])-1)
    customer = s[i][j]
    return customer, (i,j)
end

function checklen(s)
    for i in 1:length(s)
        println(string(s[i]))
    end
end
