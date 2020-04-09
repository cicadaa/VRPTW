include("initialSolution.jl")

function destruct(s_cur, k)
    len = size(s_cur)[1]
    idx_set = rand(1:len, k)
    s_child = merge_mtx(s_cur, idx_set)
    s_main = concatenate_mtx(s_cur, idx_set)
    return s_main, s_child
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
    # println(length(mtx_new))
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

#==============================================================================#

function construct(s_main, s_child)
    s_cur = copy(s_main)

    for customer in s_child
        s_cur = insert_customer(s_cur, customer)
    end
    # println(size(s_cur))
    return s_cur
end

function insert_customer(s_main, customer)
    loc_x, loc_y = get_insert_loc(s_main, customer)
    if loc_x == 0 && loc_y == 0 # when insert location not found
        route = [1, customer]
        push!(s_main, route)
    else
        route = copy(s_main[loc_x])
        s_main[loc_x] = insert!(route, loc_y, customer)
    end
    return s_main
end

function get_insert_loc(s_main, customer)
    insertcost_min = 0
    loc_x, loc_y = 0, 0

    for i = 1:size(s_main)[1]
        for j = 2:size(s_main[i])[1]
            route = copy(s_main[i])
            route_new = insert!(route, j, customer)
            if is_valid_route(route_new)
                insertcost = get_insert_cost(route, j, customer)
                if insertcost_min == 0 || insertcost <= insertcost_min
                    loc_x, loc_y = i, j
                    insertcost_min = insertcost
                end
            end
        end
    end

    return loc_x, loc_y
end

function get_insert_cost(route, insert_loc, customer)
    cust_pre = route[insert_loc-1]
    cust_nxt = route[insert_loc]
    insert_cost =
        dist[cust_pre, customer] + dist[customer, cust_nxt] -
        dist[cust_pre, cust_nxt]
    return insert_cost
end

#==============================================================================#

function lns_solver(runtime, k)
    s_init = initSolution()
    s_best = s_cur = copy(s_init)
    cost_cur = cost_best = get_cost(s_init)

    start_time = time_ns()
    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime
        if length(s_cur) < 29
            k = 2
        end
        if length(s_cur) < 24
            k = 3
        end

        s_main, s_child = destruct(s_cur, k)
        s_cur = construct(s_main, s_child)
        cost_cur = get_cost(s_cur)

        if cost_cur <= cost_best && size(s_cur)[1] <= size(s_best)[1]*1.05
            s_best, cost_best = s_cur, cost_cur
            println("best cost:" *string(cost_cur) *" | best v:" * string(size(s_cur)[1]))
        else
            s_cur = s_best
        end
    end
    return s_best
end


function check_solution(solution)
    customer_list = zeros(Int32, dim)
    customer_list[1] = 1

    for i in 1:length(solution)
        route = solution[i]
        for j in 1:length(solution[i])
            customer_list[solution[i][j]] = 1
        end
        if !(is_valid_route(route))
            println("not valid")
            @goto escape2
            return false
        end
    end
    @label escape2

    if sum(customer_list) != dim
        println("has unvisit customer")
        return false
    else
        println("is valid")
        return true
    end

end

function is_valid_route(route)
    load = 0
    time = 0
    valid = true
    for i in 2:length(route)
        cust_pre, customer = route[i-1], route[i]
        load += demand[customer]
        if time + dist[cust_pre, customer] > time_window[customer][2]
            valid = false
            @goto escape

        end
        arrive_time = max(time + dist[cust_pre, customer], time_window[customer][1])
        service_time = time_window[customer][3]
        time = arrive_time + service_time
    end

    @label escape
    if load > capacity || valid == false
        return false
    else
        return true
    end
end
solution = lns_solver(60, 1)

check_solution(solution)
