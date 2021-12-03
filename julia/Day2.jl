module Day2

export Submarine, on_input!, output

mutable struct Submarine
    first_part_depth::UInt32
    horizontal_position::UInt32
    depth::UInt32
    aim::UInt32

    Submarine() = new(0, 0, 0, 0)
end

# Apparently type values with strings aren't possible, so I'm using symbols instead. Each action has its own symbol, and whenever some code needs to work with the action, they first construct the symbol by using `Symbol(action)`, and then construct the type value of that symbol: `Val(Symbol(action))`.
forward = "forward"
up = "up"
down = "down"

function on_input!(s::Submarine, a::AbstractString)
    movement, amount = split(a, " ")
    amount = parse(UInt32, amount)

    on_input!(s, Val(Symbol(movement)), amount)
end

function on_input!(s::Submarine, ::Val{:forward}, a::UInt32)
    s.horizontal_position += a
    s.depth += s.aim * a
end

function on_input!(s::Submarine, ::Val{:up}, a::UInt32)
    s.first_part_depth -= a
    s.aim -= a
end

function on_input!(s::Submarine, ::Val{:down}, a::UInt32)
    s.first_part_depth += a
    s.aim += a
end

function output(s::Submarine)
    println("Part 1: $(s.first_part_depth * s.horizontal_position)")
    println("Part 2: $(s.depth * s.horizontal_position)")
end

end