# include("Init_Solution.jl")
#
# s0 = init_solution()


#local search 2-opt ==============================================================================#
function local_search_2opt(s, runtime)
    s_best = deepcopy(s)
    start_time = time_ns()
    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime
        cust_a = rand(2:dim)
        cust_b = rand(2:dim)
        s_new, validity, loc_a, loc_b= swap_customer(s_best, cust_a, cust_b)
        if validity == true
            origin_cost = get_route_cost(s_best[loc_a]) + get_route_cost(s_best[loc_b])
            new_cost = get_route_cost(s_new[loc_a]) + get_route_cost(s_new[loc_b])
            if new_cost < origin_cost
                s_best = deepcopy(s_new)
            end
        end
    end
    return s_best
end


function swap_customer(s, a, b)
    s_tmp = deepcopy(s)
    validity = true
    loc_a = loc_b = nothing
    for i in 1:length(s_tmp)
        for j in 2:length(s_tmp[i])-1
            if s[i][j] == a
                s_tmp[i][j] = b
                loc_a = i

                if !is_valid_route(s_tmp[i])
                    validity = false
                    @goto es
                end
            end
            if s[i][j] == b
                s_tmp[i][j] = a
                loc_b = i

                if !is_valid_route(s_tmp[i])
                    validity = false
                    @goto es
                end
            end
        end
    end
    @label es
    return s_tmp, validity, loc_a, loc_b
end


# local_search_2opt(s0, 2)
