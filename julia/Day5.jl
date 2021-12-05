module Day5

export Submarine, on_input!, output

const FIELD_SIZE = 1000

mutable struct Submarine
    vents_field_no_diagonal::Matrix{Int32}
    vents_field::Matrix{Int32}

    Submarine() = new(zeros(Int32, FIELD_SIZE, FIELD_SIZE), zeros(Int32, FIELD_SIZE, FIELD_SIZE))
end

function on_input!(s::Submarine, a::AbstractString)
    x0, y0, x1, y1 = Iterators.flatten(split(a, " -> ") .|> (x) -> split(x, ",")) .|> (x) -> 1 + parse(Int32, x)

    mark_vents!(s, x0, y0, x1, y1)
end

function mark_vents!(s::Submarine, x0::Integer, y0::Integer, x1::Integer, y1::Integer)
    xrange = build_range(x0, x1)
    yrange = build_range(y0, y1)

    # If x0 == x1 or y0 == y1, we can cycle forever the range that will only yield x0 or y0 to be able to zip() both ranges.
    if x0 == x1
        xrange = Iterators.cycle(xrange)
    end

    if y0 == y1
        yrange = Iterators.cycle(yrange)
    end

    is_diagonal = x0 != x1 && y0 != y1

    for (x, y) in Iterators.zip(xrange, yrange)
        s.vents_field[x, y] += 1

        if !is_diagonal
            s.vents_field_no_diagonal[x, y] += 1
        end
    end
end

function build_range(a::Integer, b::Integer)
    if a > b
        a:-1:b
    else
        a:b
    end
end

function output(s::Submarine)
    dangerous_areas_no_diagonal = length(filter((x) -> x > 1, s.vents_field_no_diagonal))
    dangerous_areas = length(filter((x) -> x > 1, s.vents_field))

    println("Part 1: $(dangerous_areas_no_diagonal)")
    println("Part 2: $(dangerous_areas)")
end

end