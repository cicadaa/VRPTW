#initial solution
include("prepareData.jl")
V, Q, customers, coord, demand, time_window = readInstance("C1_2_1 .TXT")
dim, dist = getDistanceMatrix(coord)

function initVehicle()
    route = [1]
    load = 0
    next = 1
    curTime = 0
    return route, load, next
end

function initSetting()
    visited = zeros(Int32,dim)
    visited[1] = 1
    Map = []
    countC = 0 #count visted customers
    countV = 0 #count used vehicles

    return visited, Map, countC, countV
end

function routeGenerator()
    visited, Map, countC, countV = initSetting()
    while countC < dim-1  && countV < V
        route, load, next, curTime = initVehicle()
        while load < Q
            cur = next
            next = findNext(load, dist[cur, : ], curTime visited)
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
            end
        end
    end
    # println("visited customer"*string(sum(visited)))
    # println("total customer"*string(dim))
    # println("count customer"*string(countC))
    return Map
end



function findNext(load, curList, curTime visited)
    custNum = length(curList)
    idxedList = []
    for i in 1:custNum
        append!(idxedList, [(curList[i],i)]) #store cust No. + distance
    end

    sortedList = sort(idxedList, by = first)
    for j in 2:custNum
        idx = sortedList[j][2]

        if visited[idx] == 0 && load + demand[idx] < Q # && validTime(curTime, cur, idx)
            return idx
        end
    end
    return 1 #if all customer visited
end

function validTime(curTime, cur, nxt)
    curStart = time_window[cur][1]
    curEnd = time_window[cur][2]

    travel_time = dist[cur, nxt]
    println(travel_time)
end

function initSolution()
    ans = routeGenerator()
    validTime(2, 12)
    return ans

end

initSolution()
