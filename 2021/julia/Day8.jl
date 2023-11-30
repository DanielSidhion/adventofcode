module Day8

export Submarine, on_input!, output

# This maps to (1 + digit) because julia's indices start at 1.
const EASY_LEN_TO_DIGIT = Dict(2=>2, 3=>8, 4=>5, 7=>9)
const EASY_DIGITS = [1, 7, 4, 8]

mutable struct Submarine
    total_easy_digits::Int32
    sum_digits::Int32
    digits::Vector{Set{Char}}
    five_len_possibilities::Vector{Set{Char}}
    six_len_possibilities::Vector{Set{Char}}

    Submarine() = new(0, 0, [Set() for _ in 1:10], [], [])
end

function on_input!(s::Submarine, a::AbstractString)
    parts = collect(split(a, " | "))

    foreach(x -> add_unique_set!(s, x), split(parts[1], " "))

    figure_out_ambiguous_digits!(s)

    display_digits = map(x -> digit_from_set(s, x), Set.(split(parts[2], " ")))

    s.total_easy_digits += length(filter(x -> x in EASY_DIGITS, display_digits))

    display_number = 1000 * display_digits[1] + 100 * display_digits[2] + 10 * display_digits[3] + display_digits[4]
    s.sum_digits += display_number
end

function add_unique_set!(s::Submarine, a::AbstractString)
    a_len = length(a)

    if a_len in keys(EASY_LEN_TO_DIGIT)
        s.digits[EASY_LEN_TO_DIGIT[a_len]] = Set(a)
    elseif a_len == 5
        push!(s.five_len_possibilities, Set(a))
    elseif a_len == 6
        push!(s.six_len_possibilities, Set(a))
    end
end

function removeelement!(s, e)
    deleteat!(s, findfirst(x -> x == e, s))
end

function figure_out_ambiguous_digits!(s::Submarine)
    # The set that represents 3 is the 5-digit that contains 1.
    three = first(filter(x -> s.digits[2] ⊆ x, s.five_len_possibilities))
    s.digits[4] = three
    removeelement!(s.five_len_possibilities, three)

    # The set that represents 5 is the 5-digit except 3 that has 3 intersections with 4.
    five = first(filter(x -> length(intersect(s.digits[5], x)) == 3, s.five_len_possibilities))
    s.digits[6] = five
    removeelement!(s.five_len_possibilities, five)

    # The set that represents 2 is the remaining 5-digit.
    s.digits[3] = pop!(s.five_len_possibilities)

    # The set that represents 0 is the 6-digit that doesn't contain 5.
    zero = first(filter(x -> s.digits[6] ⊈ x, s.six_len_possibilities))
    s.digits[1] = zero
    removeelement!(s.six_len_possibilities, zero)

    # The set that represents 9 is the 6-digit that contains 3.
    nine = first(filter(x -> s.digits[4] ⊆ x, s.six_len_possibilities))
    s.digits[10] = nine
    removeelement!(s.six_len_possibilities, nine)

    # The set that represents 6 is the remaining 6-digit.
    s.digits[7] = pop!(s.six_len_possibilities)
end

function digit_from_set(s::Submarine, x)
    findfirst(y -> issetequal(x, y), s.digits) - 1
end

function print_digits(s::Submarine)
    for (i, set) in enumerate(s.digits)
        println("$(i - 1) -> $(set)")
    end
end

function output(s::Submarine)
    println("Part 1: $(s.total_easy_digits)")
    println("Part 2: $(s.sum_digits)")
end

end