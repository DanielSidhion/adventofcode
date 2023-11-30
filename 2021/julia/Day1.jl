module Day1

export Submarine, on_input!, output

mutable struct Submarine
    latest_measurements::Vector{UInt32}
    num_increments::UInt32
    num_three_measurement_increments::UInt32

    Submarine() = new([], 0, 0)
end

function on_input!(s::Submarine, m::AbstractString)
    m = parse(UInt32, m)

    if length(s.latest_measurements) > 0
        if m > s.latest_measurements[end]
            s.num_increments += 1
        end
    end

    if length(s.latest_measurements) == 3
        first = popfirst!(s.latest_measurements)

        if m > first
            s.num_three_measurement_increments += 1
        end
    end

    push!(s.latest_measurements, m)
end

function output(s::Submarine)
    println("Part 1: $(s.num_increments)")
    println("Part 2: $(s.num_three_measurement_increments)")
end

end