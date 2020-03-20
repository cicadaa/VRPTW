#initial solution
include("prepareData.jl")
V, Q, customers, coord, demand, time_window = readInstance("C1_2_1 .TXT")
dim, dist = getDistanceMatrix(coord)

function initVehicle()
    route = [1]
    load = 0
    next = 1
    curTime = 0
    return route, load, next, curTime
end

function initSetting()
    visited = zeros(Int32,dim)
    visited[1] = 1
    Map = []
    countC = 1 #count visted customers
    countV = 0 #count used vehicles

    return visited, Map, countC, countV
end

function routeGenerator()
    visited, Map, countC, countV = initSetting()

    while countC < dim-1  && countV < V
        route, load, next, curTime = initVehicle()
        while load < Q
            cur = next
            next = findNext(load, cur, dist[cur, : ], curTime, visited)

            if next == 1
                push!(route, next)
                push!(Map, route)
                countV += 1
                load = Q
            else
                push!(route, next)
                visited[next] = 1
                load += demand[next]
                countC += 1
                travel_time = dist[cur, next]
                curTime = curTime + travel_time + time_window[next][3]
            end
        end

    end
    # println("visited customer"*string(sum(visited)))
    # println("total customer"*string(i))
    # println("count customer"*string(countC))
    for j in 1:dim
        if visited[j] != 1
            # println("left: "*string(j)* "  time: "*string(time_window[j]) * "  travel_ time:"*string(dist[1, j]))
        end
    end

    return Map
end



function findNext(load, cur, curList, curTime, visited)
    custNum = length(curList)
    idxedList = []
    for i in 1:custNum
        append!(idxedList, [(curList[i],i)]) #store cust No. + distance
    end

    sortedList = sort(idxedList, by = first)
    for j in 2:custNum
        idx = sortedList[j][2]

        if visited[idx] == 0 && load + demand[idx] < Q  && isFeasibleTime(curTime, cur, idx)
            return idx
        end
    end
    return 1 #if all customer visited
end

function isFeasibleTime(curTime, cur, nxt)
    if cur == 1
        return true
    end
    nxtStart = time_window[nxt][1]
    nxtEnd = time_window[nxt][2]

    travel_time = dist[cur, nxt]
    if nxtStart <= (curTime + travel_time) <= nxtEnd
        return true
    end
    return false
end

function getCost(Map)
    totalDist = 0
    for i in 1:length(Map)
        routeDist = 0
        route = Map[i]
        for j in 1:length(route)-1
            routeDist += dist[route[j], route[j+1]]
        end
        totalDist += routeDist
    end
    return totalDist
end

function initSolution()
    Map = routeGenerator()
    cost = getCost(Map)
    println(length(Map))
    println(cost)
    println(Map)
    return ans
end

initSolution()
