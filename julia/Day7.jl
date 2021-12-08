module Day7

export Submarine, on_input!, output

mutable struct Submarine
    crab_positions::Vector{Int32}

    Submarine() = new([])
end

function on_input!(s::Submarine, a::AbstractString)
    s.crab_positions = sort(parse.(Int32, split(a, ",")))
end

function min_assumed_fuel(s::Submarine)
    optimal_position = s.crab_positions[1 + length(s.crab_positions) ÷ 2]

    sum(map(pos -> abs(optimal_position - pos), s.crab_positions))
end

function min_real_fuel(s::Submarine)
    optimal_position = 1 + sum(s.crab_positions) ÷ length(s.crab_positions)

    minimum(map(pos -> real_fuel_for_pos(s, pos), (optimal_position - 1):(optimal_position + 1)))
end

function real_fuel_between_pos(pos1, pos2)::Int32
    diff = abs(pos1 - pos2)

    (diff * (diff + 1)) / 2
end

function real_fuel_for_pos(s::Submarine, pos)
    sum(map(x -> real_fuel_between_pos(pos, x), s.crab_positions))
end

function output(s::Submarine)
    println("Part 1: $(min_assumed_fuel(s))")
    println("Part 2: $(min_real_fuel(s))")
end

end