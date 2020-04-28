function is_valid_solution(data, solution)
    dim = data["dim"]

    customer_list = zeros(Int32, dim)
    customer_list[1] = 1
    validity = true
    for i = 1:length(solution)
        route = solution[i]
        if !(is_valid_route(data, route))
            println("not valid route")
            validity = false
            @goto escape2
        end
        for c in route
            customer_list[c] = 1
        end
    end

    if sum(customer_list) != dim
        println("unvisited cust")

        validity = false
    end
    c_ls = []
    for c = 1:length(customer_list)
        if customer_list[c] != 1
            append!(c_ls, c)

        end
    end
    # println(c_ls)



    @label escape2
    return validity
end

function is_valid_route(data, route)
    return valid_route_time(data, route) && valid_route_cap(data, route)
end

function valid_route_time(data, route)
    time_window = data["time"]
    dist = data["dist"]

    time = 0
    validity = true
    for i = 2:length(route)
        travel_time = copy(dist[route[i-1], route[i]])
        end_time = time_window[route[i]][2]
        if time + travel_time > end_time
            validity = false
            @goto escape
        end
        start_time = max(time_window[route[i]][1], time + travel_time)
        service_time = time_window[route[i]][3]
        time = start_time + service_time
    end
    @label escape
    return validity
end

function valid_route_cap(data, route)
    Q = data["Q"]
    demand = data["demand"]
    if length(route) < 1
        println("empty route")
    end
    validity = true
    load = sum(demand[x] for x in route)
    if load > Q
        validity = false
    end
    return validity
end
