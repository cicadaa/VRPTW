include("Init_Solution.jl")
include("Local_Search.jl")
include("Solution_Checker.jl")


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
    return s_cur
end

function insert_customer(s_main, customer)
    loc_x, loc_y = get_insert_loc(s_main, customer)
    if loc_x == 0 && loc_y == 0 # when insert location not found
        route = [1, customer, 1]
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



function lns_solver(runtime1, runtime2, des_k, search_k)
    s_init = initSolution()
    s_best = copy(s_init)
    s_cur = copy(s_init)

    cost_cur = cost_best = get_cost(s_init)
    start_time = time_ns()

    while round((time_ns() - start_time) / 1e9, digits = 3) < runtime1
        s_main, s_child = destruct(s_cur, des_k)
        s = construct(s_main, s_child)
        s_cur = s
        cost_cur = get_cost(s_cur)

        if cost_cur <= cost_best && size(s_cur)[1] <= size(s_best)[1]
            s_cur = local_search3(s, runtime2, search_k)
            cost_cur = get_cost(s_cur)
            if cost_cur < cost_best
                s_best, cost_best = copy(s_cur), cost_cur

                println("best cost:" *string(cost_cur) *" | best v:" * string(size(s_cur)[1]))
            end
        else
            s_cur = copy(s_best)
        end
    end

    println("end:)")
    return s_best

end

function checklen(s)
    for i in 1:length(s)
        println(string(s[i]))
    end
end


solution = lns_solver(120, 1, 2, 20)

println(check_solution(solution))
