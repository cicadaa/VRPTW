
function readInstance(filename)
    file = open(filename)
    name = readline(file)
    readline(file);readline(file);readline(file)

    Vehicle = parse.(Int32,split(readline(file)))
    V, Q = Vehicle[1], Vehicle[2] #V no. of vehicle, Q capacity of vehicle
    readline(file);readline(file);readline(file);readline(file);

    coord = []
    customers = []
    demand = []
    time_window = []

    while true
        data = parse.(Int32,split(readline(file)))
        if data == []
            break
        end
        push!(customers, data[1:1])
        push!(coord, data[2:3])
        push!(demand, data[4])
        push!(time_window, data[5:7])
    end
    close(file)
    return V, Q, customers, coord, demand, time_window
end

function getDistanceMatrix(coord)
    dim = length(coord)
    dist = zeros(Int32,dim,dim)
    for i in 1:dim
       for j in 1:dim
            if i!=j
                dist[i,j]=round(sqrt((coord[i][1]-coord[j][1])^2+(coord[i][2]-coord[j][2])^2),digits=0)
            end
        end
    end
    return dim, dist
end

V, Q, customers, coord, demand, time_window = readInstance("C1_2_1 .TXT")
dim, dist = getDistanceMatrix(coord)
