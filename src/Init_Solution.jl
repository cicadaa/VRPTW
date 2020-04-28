#use init_solution() to generate initial solution

function init_solution(data)
    V = data["V"]
    Q = data["Q"]
    demand = data["demand"]
    time_window = data["time"]
    dim = data["dim"]
    dist= data["dist"]
    visited = zeros(Int32, dim)
    visited[1] = 1
    solution = []
    while sum(visited) < dim
        road = [1]
        consumed = 0
        time = 0
        while length(road) <=1 || road[end] != 1
            pre = road[end]
            nxt = find_next_city(data, pre, visited, time, consumed)
            push!(road, nxt)
            visited[nxt] = true
            consumed += demand[nxt]
            time = max(time_window[nxt][1], time + dist[pre, nxt]) + time_window[nxt][3]
        end

        push!(solution, road)
    end
    return solution
end

function find_next_city(data, pre_city, visited, time, consumed)
    V = data["V"]
    Q = data["Q"]
    demand = data["demand"]
    time_window = data["time"]
    dim = data["dim"]
    dist= data["dist"]

    min_dist = nothing
    min_city = 0

    for i=1:dim
        load = demand[i]+consumed
        if visited[i] == 0 && load <= Q && time + dist[pre_city, i] <= time_window[i][2] && time + dist[pre_city, i] + time_window[i][3] + dist[i, 1] <= time_window[1][2]
            if min_dist == nothing || dist[pre_city, i] < min_dist
                min_dist = dist[pre_city, i]
                min_city = i
            end
        end
    end
    if min_dist == nothing
        return 1
    else
        return min_city
    end
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
