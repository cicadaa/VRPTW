using Luxor
using Colors
include("Init_Solution.jl")
include("Prepare_Data.jl")

data = prepare_data("C1_2_1.TXT")

s = init_solution(data)
vehicle_num, capacity, customers, coord, demand, time_window =  read_instance("C1_2_1.TXT")
dim, dist = get_distance_matrix(coord)

function draw_customers(s, coord)
    Drawing(6000,3000)
    background("white")
    cols = collect(Colors.color_names)
    origin()

    scale = 20
    for c in coord
        sethue("black")

        circle((c[1]-70)*scale,(c[2]-70)*scale,15,:fill)
    end
    setline(8)
    for i in 1:length(s)
        # randomcolor()
        sethue("grey")
        for j in 1:length(s[i])-1
            p1 = s[i][j]
            p2 = s[i][j+1]
            x1 = (coord[p1][1]-70)*scale
            y1 = (coord[p1][2]-70)*scale

            x2 = (coord[p2][1]-70)*scale
            y2 = (coord[p2][2]-70)*scale
            line(Point(x1, y1),Point(x2, y2),:stroke)
        end
    end

    sethue("black")
    circle(0,0,60,:fill)

    finish()

    preview()
end

draw_customers(s, coord)
