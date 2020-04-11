
#Greedy constructor =========================================================================#

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
