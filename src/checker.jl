##Function to read the data file
function readInstance(filename)
    #open file for reading
    file = open(filename)
    #read the name of the instance
    name = split(readline(file))[1]
    #The next three lines are not interesting for us. Skip them
    readline(file);readline(file);readline(file)
    #Read the size of the instance (the number of cities)
    data = parse.(Float32,split(readline(file)))
    nb_vehicules, capacity = data[1], data[2]
    #The next four lines are not interesting for us. Skip them
    readline(file);readline(file);readline(file);readline(file)
    #Create a Matrix (dim ⋅ 2) to hold the coordinates
    coord = zeros(Float32,201,2)
    demand = zeros(Float32,201)
    ready_time = zeros(Float32,201)
    due_dates = zeros(Float32,201)
    service_time = zeros(Float32,201)

    for city in 1:201
        data = parse.(Float32,split(readline(file)))
        for i in 1:2
            coord[city,i] = data[i+1]
        end
        demand[city] = data[4]
        ready_time[city] = data[5]
        due_dates[city] = data[6]
        service_time[city] = data[7]
    end

    #Close the file
    close(file)
    #return the data we need
    return name, nb_vehicules, capacity, coord, demand, ready_time, due_dates, service_time
end

##function to convert the array 201x2 of the coords into a matrix 201x201 of distances
function getDistanceMatrix(coord, dim)
    dist = zeros(Float32,dim,dim)
    for i in 1:dim
       for j in 1:dim
            if i!=j
                dist[i,j]=round(sqrt((coord[i,1]-coord[j,1])^2+(coord[i,2]-coord[j,2])^2),digits=2)
            end
        end
    end
    return dist
end

##find the nearest unvisited city that can be accessed without breaking the constraints of time
function nearestUnvisitedAttainableCustomer(prevCity, isVisited, distance, ready_time, due_dates, service_time, time, demand, consumed)
    minDist = 1000000
    minCity = 0
    I = length(demand)
    for i=1:I
        #We can visit a customer if :
        #1) It never has been visited
        #2) The truck still contains enough resources to satisfy the demand
        #3) The truck has enough time to reach the customer before the due date
        #4) The truck has enough time to come back to the depot after the delivery
        if !isVisited[i] && demand[i]+consumed <= 200 && time + distance[prevCity, i] <= due_dates[i] && time + distance[prevCity, i] + service_time[i] + distance[i, 1] <= due_dates[1]
            if distance[prevCity, i] < minDist
                minDist = distance[prevCity, i]
                minCity = i
            end
        end
    end
    if minDist == 1000000
        return 1
    else
        return minCity
    end
end

##find an initial solution
function initialSolution(instance)
    name, nb_vehicules, capacity, coord, demand, ready_time, due_dates, service_time = instance
    I = length(demand)
    distance = getDistanceMatrix(coord, I)
    isVisited = falses(I)
    isVisited[1] = true
    solution = []
    while sum(isVisited) < I #While there is at least one city that we didn't visit, we continue
        road = [1] #We build an array which contains all the different places of the truck. The driver always starts its delivery from the depot.
        consumed = 0 #The quantity of resources consumed
        time = 0 #The time
        while length(road) <=1 || road[end] != 1  #While the truck has not returned to the depot, we continue
            prevCity = road[end]
            nextCity = nearestUnvisitedAttainableCustomer(prevCity, isVisited, distance, ready_time, due_dates, service_time, time, demand, consumed)
            push!(road, nextCity) #We found the next unvisited and attainable city, and we add it to the path
            isVisited[nextCity] = true #This city has been visited
            consumed += demand[nextCity] #The quantity of delivered resources is updated
            time = max(ready_time[nextCity], time + distance[prevCity, nextCity]) + service_time[nextCity]
            #The time is updated. If the truck arrives before the ready_date, it has to wait until the customer is ready.
            #If not, it means the trucks arrives during the time window. We just need to add the service time after that.
        end
        push!(solution, road)
    end
    println(solution)
    println("number of trucks : ", length(solution))
    println("cost : ", cost(solution, distance))
    return solution, cost(solution, distance)
end

## calculate the cost of our solution
function cost(solution, distance)
    totalCost = 0
    I = length(solution)
    for i=1:I
        J = length(solution[i])
        for j=2:J
            totalCost += distance[solution[i][j-1], solution[i][j]]
        end
    end
    return totalCost
end

function timeConstraints(solution, instance)
    name, nb_vehicules, capacity, coord, demand, ready_time, due_dates, service_time = instance
    C = length(demand)
    distances = getDistanceMatrix(coord, C)
    nbUsedTrucks = length(solution)
    CHECK = true
    for u=1:nbUsedTrucks
        time = 0
        for i=2:length(solution[u])
            if time + distances[solution[u][i-1], solution[u][i]] > due_dates[solution[u][i]]
                println(solution[u])
                CHECK = false
            end
            time = max(ready_time[solution[u][i]], time + distances[solution[u][i-1], solution[u][i]]) + service_time[solution[u][i]]
        end
    end
    return CHECK
end

function capacityConstraint(solution, instance)
    name, nb_vehicules, capacity, coord, demand, ready_time, due_dates, service_time = instance
    capacity = 200
    nbUsedTrucks = length(solution)
    CHECK = true
    for u=1:nbUsedTrucks
        quantity = 0
        if sum(demand[i] for i in solution[u]) > capacity
            println(solution[u])
            println(sum(demand[i] for i in solution[u]))
            CHECK = false
        end
    end
    return CHECK
end
include("ALNS_Solver.jl")
solution, y = alns_solver(60, 1, 3, 0.004, 20, 1, 0.7)


function testVRPTW(solution, instance)
    test1 = timeConstraints(solution, instance)
    test2 = capacityConstraint(solution, instance)
    println("Time window test : ", test1)
    println("Capacity test : ", test2)
end

Instance = readInstance("C1_2_1.TXT")
name, nb_vehicules, capacity, coord, demand, ready_time, due_dates, service_time = Instance
# println(length(solution))
# println(get_cost(solution))
# solution = initialSolution(Instance)
testVRPTW(solution, Instance)
