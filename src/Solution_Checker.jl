function is_valid_solution(solution)
    customer_list = zeros(Int32, dim)
    customer_list[1] = 1
    validity = true
    for i in 1:length(solution)
        route = solution[i]
        if length(route) < 1
            println("eroute |"*string(i))
            println("eroute len |"*string(solution[2]))
            println("eroute len |"*string(solution[3]))

        end
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
    c_ls = []
    for c in 1:length(customer_list)
        if customer_list[c] != 1
            append!(c_ls, c)
        end
    end
    # println("empty item : "*string(c_ls))


    @label escape2
    println(validity)
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
    if length(route) < 1

        println("empty route")
    end
    validity = true
    load = sum(demand[x] for x in route)
    if load > capacity
        validity = false
    end
    return validity
end
