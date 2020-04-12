
#01 Pure Greedy constructor =========================================================================#

function construct_greedy(s_main, s_child)
    s_cur = copy(s_main)
    for customer in s_child
        s_cur = insert_customer(s_cur, customer)
    end
    return s_cur, 1
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


#02 Greedy Pertubation constructor==============================================================================#
function construct_pertubation(s_main, s_child)
    s_cur = copy(s_main)

    for customer in s_child
        s_cur = insert_pertubated_customer(s_cur, customer)
    end
    return s_cur, 2
end

function insert_pertubated_customer(s_main, customer)
    loc_x, loc_y = get_pertubated_insert_loc(s_main, customer)
    if loc_x == 0 && loc_y == 0 # when insert location not found
        route = [1, customer, 1]
        push!(s_main, route)
    else
        route = copy(s_main[loc_x])
        s_main[loc_x] = insert!(route, loc_y, customer)
    end
    return s_main
end


function get_pertubated_insert_loc(s_main, customer)
    insertcost_min = 0
    loc_x, loc_y = 0, 0

    for i = 1:size(s_main)[1]
        for j = 2:size(s_main[i])[1]
            route = copy(s_main[i])
            route_new = insert!(route, j, customer)
            if is_valid_route(route_new)

                rand_idx = get_randnum_inrange(0.8, 1.2)
                insertcost = get_insert_cost(route, j, customer) * rand_idx
                if insertcost_min == 0 || insertcost <= insertcost_min
                    loc_x, loc_y = i, j
                    insertcost_min = insertcost
                end
            end
        end
    end

    return loc_x, loc_y
end


function get_randnum_inrange(a::Float64, b::Float64)
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
