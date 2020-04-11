function is_valid_solution(solution)
    customer_list = zeros(Int32, dim)
    customer_list[1] = 1
    validity = true
    for i in 1:length(solution)
        route = solution[i]
        if !(is_valid_route(route))
            validity = false
            @goto escape2
        end
        for c in route
            customer_list[c] = 1
        end
    end

    if sum(customer_list) != dim
        validity = false
    end

    @label escape2
    return validity
end

function is_valid_route(route)
    return valid_route_time(route) && valid_route_cap(route)
end

function valid_route_time(route)
    time = 0
    validity = true
    for i=2:length(route)
        travel_time = dist[route[i-1], route[i]]
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

function valid_route_cap(route)
    validity = true
    load = sum(demand[x] for x in route)
    if load > capacity
        validity = false
    end
    return validity
end
