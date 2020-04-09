#initial solution
include("prepareData.jl")
vehicle_num, capacity, customers, coord, demand, time_window =  read_instance("C1_2_2.TXT")
dim, dist = get_distance_matrix(coord)


function init_vehicle()
    route = [1]
    load = 0
    next = 1
    curTime = 0
    return route, load, next, curTime
end

function init_setting()
    visited = zeros(Int32,dim)
    visited[1] = 1
    Map = []
    countC = 1 #count customers
    countV = 0 #count used vehicles

    return visited, Map, countC, countV
end

function route_generator()
    visited, Map, countC, countV = init_setting()
    while countC < dim-1  && countV < vehicle_num
        route, load, next, curTime = init_vehicle()
        while load < capacity
            cur = next
            next = find_next(load, cur, dist[cur, : ], curTime, visited)

            if next == 1
                push!(route, next)
                push!(Map, route)
                countV += 1
                load = capacity
            else
                push!(route, next)
                visited[next] = 1
                load += demand[next]
                countC += 1
                travel_time = dist[cur, next]
                service_time = time_window[next][3]
                start_time = time_window[next][1]
                curTime = max((curTime + travel_time), start_time) + service_time
            end
        end
    end
    return Map
end



function find_next(load, cur, curList, curTime, visited)
    custNum = length(curList)
    idxedList = []
    for i in 1:custNum
        append!(idxedList, [(curList[i],i)]) #store cust No. + distance
    end

    sortedList = sort(idxedList, by = first)
    for j in 2:custNum
        idx = sortedList[j][2]
        if visited[idx] == 0 && load + demand[idx] < capacity  && is_feasible_time(curTime, cur, idx)
            return idx
        end
    end
    return 1 #if all customer visited
end

function is_feasible_time(curTime, cur, nxt)
    if cur == 1
        return true
    end
    nxtEnd = time_window[nxt][2]
    travel_time = dist[cur, nxt]
    if (curTime + travel_time) <= nxtEnd
        return true
    end
    return false
end

function get_cost(Map)
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
    Map = route_generator()
    cost = get_cost(Map)
    # println(length(Map))
    # println(cost)
    # println(Map)
    return Map
end

# solution = initSolution()

# function solution_checker(solution)
#     customer_list = zeros(Int32, dim)
#     customer_list[1] = 1
#     for i in 1:length(solution)
#         load = 0
#         time = 0
#
#         for j in 2:length(solution[i])-1
#             customer = solution[i][j]
#             cust_pre = solution[i][j-1]
#             # println(string(customer)*" | "*string(time_window[cust_pre][2]))
#
#             time += dist[cust_pre, customer]
#             load += demand[customer]
#             customer_list[customer] = 1
#
#             if time > time_window[customer][2]
#                 println("invalid time")
#                 println(string(customer)*" | "*string(cust_pre))
#
#                 println(solution[i])
#                 return
#             end
#
#             time = max(time, time_window[customer][1]) + time_window[customer][3]
#
#         end
#         if load > capacity
#             println("invalid capacity")
#             return
#
#         end
#     end
#     if sum(customer_list) != dim
#         # println(customer_list)
#         # println(sum(customer_list))
#         println("has unvisit customer")
#         return false
#     end
#     # println("true")
# end

# solution_checker(solution)
