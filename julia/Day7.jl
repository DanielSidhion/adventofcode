module Day7

export Submarine, on_input!, output

mutable struct Submarine
    crab_positions::Dict{Int32, Int32}
    min_crab_position::Int32
    max_crab_position::Int32

    Submarine() = new(Dict(), typemax(Int32), 0)
end

function on_input!(s::Submarine, a::AbstractString)
    split(a, ",") .|> (x) -> parse(Int32, x) .|> (x) -> add_crab_position(s, x)
end

function add_crab_position(s::Submarine, pos)
    if pos < s.min_crab_position
        s.min_crab_position = pos
    end

    if pos > s.max_crab_position
        s.max_crab_position = pos
    end

    if haskey(s.crab_positions, pos)
        s.crab_positions[pos] += 1
    else
        s.crab_positions[pos] = 1
    end
end

function assumed_fuel_for_crab_pos(pos, (crab_pos, num_crabs))::Int32
    diff = abs(pos - crab_pos)

    num_crabs * diff
end

function real_fuel_for_crab_pos(pos, (crab_pos, num_crabs))::Int32
    diff = abs(pos - crab_pos)

    num_crabs * (diff * (diff + 1)) / 2
end

function total_fuel_spent(s::Submarine, fuel_calculation)
    # To make it more readable, I'd have used `sum(map(...))`, but `map` isn't defined on dicts (and indirectly on `pairs(dict)`), so `foldl` it is.
    pos -> foldl((fuel, entry) -> fuel + fuel_calculation(pos, entry), pairs(s.crab_positions); init=0)
end

function min_fuel_for_positioning(s::Submarine, fuel_calculation)
    (minimum ∘ map)(total_fuel_spent(s, fuel_calculation), s.min_crab_position:s.max_crab_position)
end

function output(s::Submarine)
    min_assumed_fuel = min_fuel_for_positioning(s, assumed_fuel_for_crab_pos)
    min_real_fuel = min_fuel_for_positioning(s, real_fuel_for_crab_pos)

    println("Part 1: $(min_assumed_fuel)")
    println("Part 2: $(min_real_fuel)")
end

end