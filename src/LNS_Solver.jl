include("initialSolution.jl")

function destruct(s_cur, k)
    len = size(s_cur)[1]
    # println(size(s_cur))

    idx_set = rand(1:len, k)
    # println("set :"*string(idx_set))
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
    return mtx_new
end

function concatenate_mtx(mtx_origin, idx_set)
    len = length(mtx_origin)
    mtx_new = []
    for i in 1:len
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
    if loc_x  == 0 && loc_y == 0 # when insert location not found
        route = [1, customer]
        push!(s_main, route)
    else
        route = copy(s_main[loc_x])
        route_a = push!(route[1:loc_y-1], customer)
        route_b = route[loc_y:length(route)]
        s_main[loc_x] = vcat(route_a, route_b)
    end

    return s_main
end

function get_insert_loc(s_main, customer)
    insertcost_min = 0
    loc_x = 0
    loc_y = 0

    for i in 1:size(s_main)[1]
        # println(" size "*string(size(s_main)[1]))
        for j in 2:size(s_main[i])[1] #TODO: add situation when j == 1
            route = s_main[i]
            if has_time_slot(route, j, customer) && has_free_space(route, customer)
                insertcost = get_insert_cost(route, j, customer)
                if insertcost_min == 0 || insertcost <= insertcost_min
                    # println("cur: "*string(insertcost)*" min :"*string(insertcost_min))
                    loc_x = i
                    loc_y = j
                    insertcost_min = insertcost
                end
            end
        end
    end
    # println("---------------")

    return loc_x, loc_y
end


function has_time_slot(route, insert_loc, customer)
    cust_pre = route[insert_loc-1]
    cust_nxt = route[insert_loc]


    start_point = get_curtime(route, insert_loc)
    end_point = time_window[cust_nxt][2]

    travel_time = dist[customer, cust_nxt]
    service_time = time_window[customer][3]

    if start_point + service_time + travel_time <= end_point
        return true
    end

    return false
end

function get_curtime(route, insert_loc)
    time_cur = 0
    for i in 2:insert_loc
        time_expect = time_cur + dist[route[i], route[i-1]]
        time_agenda = time_window[route[i]][1]
        time_cur = max(time_expect, time_agenda)
    end
    return time_cur
end

function get_insert_cost(route, insert_loc, customer)
    cust_pre = route[insert_loc-1]
    cust_nxt = route[insert_loc]
    insert_cost = dist[cust_pre, customer] + dist[customer, cust_nxt] - dist[cust_pre, cust_nxt]
    return insert_cost
end

function has_free_space(route, customer)
    curload = get_curload(route)
    addon = demand[customer]
    if curload + addon > capacity
        return false
    end
    return true
end

function get_curload(route)
    load = 0
    for customer in route
        load += demand[customer]
    end
    return load
end

#==============================================================================#

function lns_solver(runtime)
    s_init = initSolution()
    s_best = copy(s_init)
    s_cur = copy(s_init)

    cost_cur = cost_best = get_cost(s_init)
    start_time = time_ns()
    # s_main, s_child = destruct(s_cur,2)
    # # println(size(s_cur))
    #
    # s_cur = construct(s_main, s_child)
    # println(size(s_cur))
    # println("------")
    while round( (time_ns()-start_time)/1e9,digits=3) < runtime
        s_main, s_child = destruct(s_cur,3)
        s_cur = construct(s_main, s_child)

        cost_cur = get_cost(s_cur)
        # println("size :"*string(size(s_cur)))

        if  cost_cur < cost_best || size(s_cur)[1] < size(s_best)[1]
            s_best, cost_best = s_cur, cost_cur
            println("best cost:"*string(cost_cur)*" | best v:"*string(size(s_cur)[1]))
        else
            s_cur = s_best
        end
    end
    println("hi!")
end
lns_solver(60)
