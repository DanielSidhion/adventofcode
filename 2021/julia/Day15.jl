module Day15

export Submarine, on_input!, output

using DataStructures
using Printf

mutable struct Submarine
    risk_map_template::Matrix{UInt32}

    Submarine() = new(Matrix(undef, 0, 0))
end

function on_input!(s::Submarine, a::AbstractString)
    risk_levels = parse.(UInt32, split(a, ""))

    if size(s.risk_map_template) == (0, 0)
        s.risk_map_template = Matrix(undef, 0, length(risk_levels))
    end

    s.risk_map_template = [s.risk_map_template; risk_levels']
end

function wrap(v)
    if v >= 10
        v % 9
    else
        v
    end
end

function full_risk_level_map(s::Submarine)
    row = Matrix(undef, size(s.risk_map_template)[1], 0)
    full_risk_map = Matrix(undef, 0, size(s.risk_map_template)[2] * 5)

    for x = 0:4
        row = [row (x .+ s.risk_map_template)]
    end

    for y = 0:4
        full_risk_map = [full_risk_map; (y .+ row)]
    end

    wrap.(full_risk_map)
end

function smallest_risk_level(risk_level_map)
    (height, width) = size(risk_level_map)

    smallest_risk_level_map = fill(typemax(UInt32), height, width)
    final_position = (width, height)

    heap = PriorityQueue()
    enqueue!(heap, (1, 1), 0)
    smallest_risk_level_map[1, 1] = 0

    while length(heap) > 0
        position, risk_level = dequeue_pair!(heap)

        if position == final_position
            return risk_level
        end

        current_risk_level = smallest_risk_level_map[reverse(position)...] # Converts from (x, y) to (y, x) for proper indexing.

        for neighbor in neighbors(position, final_position)
            new_risk_level = current_risk_level + risk_level_map[reverse(neighbor)...]

            if new_risk_level < smallest_risk_level_map[reverse(neighbor)...]
                smallest_risk_level_map[reverse(neighbor)...] = new_risk_level

                enqueue!(heap, neighbor, new_risk_level)
            end
        end
    end
end

function print_risk_level_map(map)
    (height, width) = size(map)

    for y = 1:height
        for x = 1:width
            if map[y, x] == typemax(UInt32)
                print("  ∞")
            else
                @printf("%3d", map[y, x])
            end
        end

        println()
    end
end

function neighbors((x, y), (max_x, max_y))
    result = []

    if x > 1
        push!(result, (x - 1, y))
    end

    if x < max_x
        push!(result, (x + 1, y))
    end

    if y > 1
        push!(result, (x, y - 1))
    end

    if y < max_y
        push!(result, (x, y + 1))
    end

    result
end

function output(s::Submarine)
    println("Part 1: $(smallest_risk_level(s.risk_map_template))")
    println("Part 2: $(smallest_risk_level(full_risk_level_map(s)))")
end

end