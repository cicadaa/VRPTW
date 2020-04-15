#use init_solution() to generate initial solution

function init_vehicle()
    route = [1]
    load = 0
    next = 1
    cur_time = 0
    return route, load, next, cur_time
end

function init_setting(dim)
    visited = zeros(Int32, dim)
    visited[1] = 1
    Map = []
    count_c = 1 #count customers
    count_v = 0 #count used vehicles

    return visited, Map, count_c, count_v
end

function route_generator(data)
    V, Q = data["V"], data["Q"]
    dim, dist = data["dim"], data["dist"]
    time_window, demand = data["time"], data["demand"]

    visited, Map, count_c, count_v = init_setting(dim)
    while count_c < dim - 1 && count_v < V
        route, load, next, cur_time = init_vehicle()
        while load < Q
            cur = next
            next = find_next(data, load, cur, dist[cur, :], cur_time, visited)
            if next == 1
                push!(route, next)
                push!(Map, route)
                count_v += 1
                load = Q
            else
                push!(route, next)
                visited[next] = 1
                load += demand[next]
                count_c += 1
                travel_time = dist[cur, next]
                service_time = time_window[next][3]
                start_time = time_window[next][1]
                cur_time =
                    max((cur_time + travel_time), start_time) + service_time
            end
        end
    end
    return Map
end


function find_next(data, load, cur, curList, cur_time, visited)
    demand = data["demand"]
    Q = data["Q"]

    custNum = length(curList)
    idxedList = []
    for i = 1:custNum
        append!(idxedList, [(curList[i], i)]) #store cust No. + distance
    end

    sortedList = sort(idxedList, by = first)
    for j = 2:custNum
        idx = sortedList[j][2]
        if visited[idx] == 0 &&
           load + demand[idx] < Q &&
           is_feasible_time(data, cur_time, cur, idx)
            return idx
        end
    end
    return 1 #if all customer visited
end

function is_feasible_time(data, cur_time, cur, nxt)
    time_window = data["time"]
    dist = data["dist"]

    if cur == 1
        return true
    end
    nxtEnd = time_window[nxt][2]
    travel_time = dist[cur, nxt]
    if (cur_time + travel_time) <= nxtEnd
        return true
    end
    return false
end

function get_cost(data, Map)
    dist = data["dist"]
    totalDist = 0
    for i = 1:length(Map)
        routeDist = 0
        route = Map[i]
        for j = 1:length(route)-1
            routeDist += dist[route[j], route[j+1]]
        end
        totalDist += routeDist
    end
    return totalDist
end

function init_solution(data)
    Map = route_generator(data)
    return Map
end
