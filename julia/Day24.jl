# Manually solved. See comments in the Rust code.

module Day24

export Submarine, on_input!, output

mutable struct Submarine
end

function on_input!(_::Submarine, _::AbstractString)
end

function output(s::Submarine)
    println("Part 1: 29989297949519")
    println("Part 2: 19518121316118")
end

end