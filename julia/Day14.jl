module Day14

export Submarine, on_input!, output

function upsert!(dict, key, val)
    if !haskey(dict, key)
        dict[key] = val
    else
        dict[key] += val
    end
end

mutable struct Submarine
    polymer_template::String
    insertion_templates::Dict{String, Vector{String}}
    pair_frequencies::Dict{String, UInt64}

    Submarine() = new("", Dict(), Dict())
end

function on_input!(s::Submarine, a::AbstractString)
    if isempty(s.polymer_template)
        s.polymer_template = a
        seed_frequencies!(s)
        return
    end

    if isempty(a)
        return
    end

    pattern, new_element = split(a, " -> ")
    add_insertion_templates!(s, pattern, new_element)
end

function seed_frequencies!(s::Submarine)
    pairs = zip(s.polymer_template, s.polymer_template[2:end])

    for (a, b) in pairs
        pair_str = a * b

        upsert!(s.pair_frequencies, pair_str, 1)
    end
end

function add_insertion_templates!(s::Submarine, pattern, new_element)
    a, b = pattern

    s.insertion_templates[pattern] = [a * new_element, new_element * b]
end

function polymerize!(s::Submarine)
    new_frequency_map = Dict()

    for (pair, frequency) in pairs(s.pair_frequencies)
        new_pairs = get(s.insertion_templates, pair, [pair])

        for new_pair in new_pairs
            upsert!(new_frequency_map, new_pair, frequency)
        end
    end

    s.pair_frequencies = new_frequency_map
end

function count_min_max_frequencies(s::Submarine)
    element_frequencies = Dict()

    for (pair, frequency) in s.pair_frequencies
        a, b = pair

        upsert!(element_frequencies, a, frequency)
        upsert!(element_frequencies, b, frequency)
    end

    for (element, frequency) in element_frequencies
        if startswith(s.polymer_template, element) || endswith(s.polymer_template, element)
            frequency += 1
        end

        element_frequencies[element] = frequency ÷ 2
    end

    (maximum(values(element_frequencies)), minimum(values(element_frequencies)))
end

function output(s::Submarine)
    for _ = 1:10
        polymerize!(s)
    end

    (a, b) = count_min_max_frequencies(s)

    println("Part 1: $(a - b)")

    for _ = 1:30
        polymerize!(s)
    end

    (a, b) = count_min_max_frequencies(s)

    println("Part 2: $(a - b)")
end

end