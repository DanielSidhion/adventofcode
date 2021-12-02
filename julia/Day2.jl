module Day2

export Submarine, on_action!

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

function on_action!(s::Submarine, a::AbstractString)
    movement, amount = split(a, " ")
    amount = parse(UInt32, amount)

    on_action!(s, Val(Symbol(movement)), amount)
end

function on_action!(s::Submarine, ::Val{:forward}, a::UInt32)
    s.horizontal_position += a
    s.depth += s.aim * a
end

function on_action!(s::Submarine, ::Val{:up}, a::UInt32)
    s.first_part_depth -= a
    s.aim -= a
end

function on_action!(s::Submarine, ::Val{:down}, a::UInt32)
    s.first_part_depth += a
    s.aim += a
end

end