mutable struct DepthIncrementScanner
    latest_measurements::Vector{UInt32}
    num_increments::UInt32
    num_three_measurement_increments::UInt32
end

function add_measurement!(s::DepthIncrementScanner, m::UInt32)
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

scanner = DepthIncrementScanner([], 0, 0)

while (true)
    depth = readline()

    if depth == ""
        break
    end

    depth = parse(UInt32, depth)

    add_measurement!(scanner, depth)
end

print("$(scanner.num_increments)\n")
print("$(scanner.num_three_measurement_increments)\n")