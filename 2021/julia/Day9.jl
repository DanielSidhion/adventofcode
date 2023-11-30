module Day9

export Submarine, on_input!, output

mutable struct Submarine
    heightmap::Matrix{UInt32}
    visited::Matrix{Bool}

    Submarine() = new(Matrix(undef, 0, 0), Matrix(undef, 0, 0))
end

function on_input!(s::Submarine, a::AbstractString)
    heights = parse.(UInt32, split(a, ""))

    if size(s.heightmap) == (0, 0)
        s.heightmap = Matrix(undef, 0, length(heights))
        s.visited = Matrix(undef, 0, length(heights))
    end

    s.heightmap = [s.heightmap; heights']
    s.visited = [s.visited; falses(length(heights))']
end

function find_low_points(s::Submarine)
    result = []

    (ysize, xsize) = size(s.heightmap)

    for y in 1:ysize
        for x in 1:xsize
            height = s.heightmap[y, x]

            if x > 1 && s.heightmap[y, x - 1] <= height
                continue
            end
            if x < xsize && s.heightmap[y, x + 1] <= height
                continue
            end
            if y > 1 && s.heightmap[y - 1, x] <= height
                continue
            end
            if y < ysize && s.heightmap[y + 1, x] <= height
                continue
            end

            push!(result, (y, x, height))
        end
    end

    result
end

function find_basin_size!(s::Submarine, (y, x))
    if s.visited[y, x]
        return 0
    end

    if s.heightmap[y, x] == 9
        return 0
    end

    (ysize, xsize) = size(s.heightmap)

    s.visited[y, x] = true

    left = x == 1 ? 0 : find_basin_size!(s, (y, x - 1))
    right = x == xsize ? 0 : find_basin_size!(s, (y, x + 1))
    up = y == 1 ? 0 : find_basin_size!(s, (y - 1, x))
    down = y == ysize ? 0 : find_basin_size!(s, (y + 1, x))

    1 + left + right + up + down
end

function output(s::Submarine)
    low_points = find_low_points(s)
    low_point_risk_level = sum(map(x -> x[3] + 1, low_points))

    println("Part 1: $(low_point_risk_level)")

    basin_sizes = sort(map(x -> find_basin_size!(s, (x[1], x[2])), low_points), rev=true)
    top_3_basin_product = prod(Iterators.take(basin_sizes, 3))

    println("Part 2: $(top_3_basin_product)")
end

end