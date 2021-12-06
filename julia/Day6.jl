module Day6

export Submarine, on_input!, output

mutable struct Submarine
    fish_timers::Vector{UInt64}

    Submarine() = new(zeros(UInt64, 9))
end

function on_input!(s::Submarine, a::AbstractString)
    split(a, ",") .|> (x) -> parse(Int64, x) .|> (x) -> s.fish_timers[x + 1] += 1
end

function simulate_one_day!(s::Submarine)
    new_timers = zeros(UInt64, 9)

    new_timers[9] = s.fish_timers[1]
    new_timers[7] = s.fish_timers[1]

    for i in 2:9
        new_timers[i - 1] += s.fish_timers[i]
    end

    s.fish_timers = new_timers
end

function output(s::Submarine)
    for _ = 1:80
        simulate_one_day!(s)
    end

    total_fish_after_80_days = sum(+, s.fish_timers)

    for _ = 1:(256-80)
        simulate_one_day!(s)
    end

    total_fish_after_256_days = sum(+, s.fish_timers)

    println("Part 1: $(total_fish_after_80_days)")
    println("Part 2: $(total_fish_after_256_days)")
end

end