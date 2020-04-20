using Luxor
using Colors
include("Init_Solution.jl")
include("Prepare_Data.jl")

s = init_solution()
vehicle_num, capacity, customers, coord, demand, time_window =  read_instance("C1_2_1.TXT")
dim, dist = get_distance_matrix(coord)

function draw_customers(s, coord)
    Drawing(4000,4000)
    background("white")
    cols = collect(Colors.color_names)
    origin()

    scale = 20
    for c in coord
        sethue("skyblue")
        circle((c[1]-70)*scale,(c[2]-70)*scale,20,:fill)
    end
    setline(8)
    for i in 1:length(s)
        randomcolor()
        # k = rand(1:length(s))
        # sethue(cols[k][1])
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

    sethue("blue")
    circle(0,0,60,:fill)

    finish()

    preview()
end

draw_customers(s, coord)
# function draw(s)
#
#     Drawing(400,400)
#     background("white")
#
#     #The point (0,0) is in the top left corner
#     #this fuction moves it to the center of the canvas
#     origin()
#
#     #Before drawing make sure to set the color to use
#     sethue("red")
#     #A rectangle can be drawn pasing the left top corner corrdinate
#     #plus the width and height. The last parameters means drawing the outline
#     #if you want a filled rectange use :fill
#     rect(0,0,30,40,:stroke)
#
#     sethue("blue")
#     #a circle can be drawn passing the center coordinate and the radius
#     #this time we decided to fill the circle useing :fill
#     circle(-50,10,5,:fill)
#
#     sethue("black")
#     #Lines need to have two points passed as Point data structures
#     line(Point(-80,0),Point(80,30),:stroke)
#
#     #Writes the giving line of text starting from the given point
#     text("Hello drawing",Point(100,100))
#
#     #terminates and commits the drawing
#     finish()
#
#     #makes a preview in e.g. Atom plot pannel
#     preview()
# end
#
# draw(1)
# for d in coord
#     draw_customers(d)
# end
# preview()
# println(size(coord))


# Graph of weight changes
# remove_random_route = zeros(Float32, l)
# remove_kexpensive_route = zeros(Float32, l)
# remove_knn = zeros(Float32, l)
# remove_ran_cust = zeros(Float32, l)
#
# for i in 1:l
#     # println(y[i])
#     remove_random_route[i] = y[i][1]
#     remove_kexpensive_route[i] = y[i][2]
#     remove_knn[i] = y[i][3]
#     remove_knn[i] = y[i][4]
# end
# x = 1:l
# println("here")
# plot(1:l, [remove_random_route, remove_kexpensive_route, remove_knn, remove_ran_cust])
