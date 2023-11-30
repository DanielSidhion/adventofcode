module Day13

export Submarine, on_input!, output

@enum ReadState ReadingDots ReadingFoldingInstructions

mutable struct Submarine
    input_read_state::ReadState
    dots::Vector{Tuple{UInt32, UInt32}}
    num_points_after_first_fold::UInt32

    Submarine() = new(ReadingDots, [], 0)
end

function on_input!(s::Submarine, a::AbstractString)
    on_input!(s::Submarine, Val(s.input_read_state), a)
end

function on_input!(s::Submarine, ::Val{ReadingDots}, a::AbstractString)
    if a == ""
        s.input_read_state = ReadingFoldingInstructions
        return
    end

    x, y = collect(parse.(UInt32, split(a, ",")))
    push!(s.dots, (x, y))
end

function on_input!(s::Submarine, ::Val{ReadingFoldingInstructions}, a::AbstractString)
    axis, coord = collect(split(chop(a, head = length("fold along "), tail = 0), "="))
    coord = parse(UInt32, coord)

    fold!(s, axis, coord)
end

function fold!(s::Submarine, axis, coord)
    if axis == "x"
        folded_points = collect(map(p -> (coord - (p[1] - coord), p[2]), filter(p -> p[1] > coord, s.dots)))
        filter!(p -> p[1] < coord, s.dots)
        s.dots = [s.dots; folded_points]
    else
        folded_points = collect(map(p -> (p[1], coord - (p[2] - coord)), filter(p -> p[2] > coord, s.dots)))
        filter!(p -> p[2] < coord, s.dots)
        s.dots = [s.dots; folded_points]
    end

    unique!(s.dots)

    if s.num_points_after_first_fold == 0
        s.num_points_after_first_fold = length(s.dots)
    end
end

function transpose_tuple((x, y))
    (y, x)
end

function print_dots(s::Submarine)
    max_x = maximum(map(p -> p[1], s.dots))
    max_y = maximum(map(p -> p[2], s.dots))

    sorted_dots = sort(s.dots, by = transpose_tuple)
    # next is a tuple `(val, state)` or `nothing`.
    next = iterate(sorted_dots)

    for y = 0:max_y
        for x = 0:max_x
            if next !== nothing && (x, y) == next[1]
                print("#")
                next = iterate(sorted_dots, next[2])
            else
                print(" ")
            end
        end

        println()
    end
end

function output(s::Submarine)
    println("Part 1: $(s.num_points_after_first_fold)")
    println("Part 2:")
    print_dots(s)
end

end