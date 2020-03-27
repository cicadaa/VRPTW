
function read_instance(filename)
    file = open(filename)

    name = readline(file)
    # println(name)
    readline(file);readline(file);readline(file)

    vehicle = parse.(Int32,split(readline(file)))
    # println(vehicle)
    vehicle_num, capacity = vehicle[1], vehicle[2] #V no. of vehicle, Q capacity of vehicle

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
    return vehicle_num, capacity, customers, coord, demand, time_window
end

function get_distance_matrix(coord)
    dim = size(coord)[1]
    dist = zeros(Float32,dim,dim)
    # println(dim)
    for i in 1:dim
       for j in 1:dim
            if i != j
                dist[i, j]= round(sqrt((coord[i][1]-coord[j][1])^2+(coord[i][2]-coord[j][2])^2),digits=2)
            end
        end
    end
    return dim, dist
end
#
