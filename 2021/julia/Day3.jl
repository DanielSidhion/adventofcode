module Day3

export Submarine, on_input!, output

mutable struct Submarine
    diagnostic_report::Vector{UInt32}

    Submarine() = new([])
end

function on_input!(s::Submarine, a::AbstractString)
    num = parse(UInt32, a; base=2)

    push!(s.diagnostic_report, num)
end

function compute_report(s::Submarine)
    gamma = 0

    oxygen_nums = copy(s.diagnostic_report)
    co2_nums = copy(s.diagnostic_report)

    for digit_position = 11:-1:0
        if length(oxygen_nums) != 1
            oxygen_digit = most_popular_digit(oxygen_nums, digit_position)
            oxygen_nums = filter(digit_at_position_equal_to(digit_position, oxygen_digit), oxygen_nums)
        end

        if length(co2_nums) != 1
            co2_digit = !most_popular_digit(co2_nums, digit_position)
            co2_nums = filter(digit_at_position_equal_to(digit_position, co2_digit), co2_nums)
        end

        gamma_digit = most_popular_digit(s.diagnostic_report, digit_position)
        gamma += gamma_digit << digit_position
    end

    epsilon = ~gamma & 0b111111111111
    oxygen_generator = oxygen_nums[1]
    co2_scrubber = co2_nums[1]

    (gamma * epsilon, oxygen_generator * co2_scrubber)
end

function digit_at_position_equal_to(digit_position::Integer, value::Bool)
    (val) -> val & (1 << digit_position) == value << digit_position
end

function add_digit_to_tally(digit_position::Integer)
    (tally, val) -> tally + ((val & (1 << digit_position)) >> digit_position) * 2 - 1
end

function most_popular_digit(nums::Vector{<:Unsigned}, digit_position::Integer)::Bool
    reduce(add_digit_to_tally(digit_position), nums; init = 0) >= 0
end

function output(s::Submarine)
    power_consumption, life_support = compute_report(s)
    println("Part 1: $(power_consumption)")
    println("Part 2: $(life_support)")
end

end