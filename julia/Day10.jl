module Day10

export Submarine, on_input!, output

using Statistics

mutable struct Submarine
    syntax_error_score::UInt64
    autocomplete_scores::Vector{UInt64}

    Submarine() = new(0, [])
end

function on_input!(s::Submarine, a::AbstractString)
    line_stack = []

    for c in split(a, "")
        if !apply_character_to_stack!(line_stack, c)
            s.syntax_error_score += syntax_error_score(c)
            return
        end
    end

    autocomplete = foldl((score, c) -> score * 5 + autocomplete_score(c), closing_equivalent.(reverse(line_stack)); init=0)
    push!(s.autocomplete_scores, autocomplete)
end

function closing_equivalent(c::AbstractString)
    c == "(" && return ")"
    c == "[" && return "]"
    c == "{" && return "}"
    c == "<" && return ">"
end

function syntax_error_score(c::AbstractString)
    c == ")" && return 3
    c == "]" && return 57
    c == "}" && return 1197
    c == ">" && return 25137
end

function autocomplete_score(c::AbstractString)
    c == ")" && return 1
    c == "]" && return 2
    c == "}" && return 3
    c == ">" && return 4
end

function apply_character_to_stack!(s, c)
    if c in [")" "]" "}" ">"]
        if isempty(s)
            return false
        end

        o = pop!(s)
        return closing_equivalent(o) == c
    end

    push!(s, c)
    true
end

function output(s::Submarine)
    println("Part 1: $(s.syntax_error_score)")

    median_score::UInt64 = Statistics.median(filter(!iszero, s.autocomplete_scores))

    println("Part 2: $(median_score)")
end

end