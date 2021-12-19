module Day18

export Submarine, on_input!, output

mutable struct Node
    val::UInt32
    directions::Vector{UInt32}
end

function depth(n::Node)
    sum(n.directions)
end

mutable struct Submarine
    all_snail_numbers::Vector{Vector{Node}}
    final_sum::Vector{Node}

    Submarine() = new([], [])
end

function on_input!(s::Submarine, a::AbstractString)
    snail_number = parse_snail_number(a)

    push!(s.all_snail_numbers, deepcopy(snail_number))
    if length(s.final_sum) == 0
        s.final_sum = snail_number
    else
        s.final_sum = add!(s.final_sum, snail_number)
    end
end

function parse_snail_number(a::AbstractString)::Vector{Node}
    result::Vector{Node} = []

    i = 1
    directions = [0, 0]

    while i <= lastindex(a)
        if a[i] == '['
            directions += [1, 0]
        elseif a[i] == ']'
            directions += [0, -1]
        elseif a[i] == ','
            directions += [-1, 1]
        else
            num_end = findnext(c -> c == ']' || c == ',', a, i) - 1
            val = parse(UInt32, a[i:num_end])

            push!(result, Node(val, copy(directions)))
            i = num_end
        end

        i += 1
    end

    result
end

function add!(s::Vector{Node}, t::Vector{Node})::Vector{Node}
    foreach(n -> n.directions += [1, 0], s)
    foreach(n -> n.directions += [0, 1], t)

    reduce!([s; t])
end

function reduce!(s::Vector{Node})::Vector{Node}
    while explode!(s) || split!(s)
    end

    s
end

function explode!(s::Vector{Node})::Bool
    for i in 1:(length(s) - 1)
        if depth(s[i]) == depth(s[i + 1]) && depth(s[i]) >= 5
            if i > 1
                s[i - 1].val += s[i].val
            end
            if i < length(s) - 1
                s[i + 2].val += s[i + 1].val
            end

            splice!(s, i:i+1, [Node(0, s[i].directions + [-1, 0])])
            return true
        end
    end

    false
end

function split!(s::Vector{Node})::Bool
    for i in 1:length(s)
        if s[i].val >= 10
            left = Node(s[i].val ÷ 2, s[i].directions + [1, 0])
            right = Node((s[i].val + 1) ÷ 2, s[i].directions + [0, 1])

            splice!(s, i:i, [left, right])
            return true
        end
    end

    return false
end

function magnitude(s::Vector{Node})::UInt64
    sum(map(n -> n.val * prod([3, 2] .^ n.directions), s))
end

function max_magnitude(as::Vector{Vector{Node}})::UInt64
    max_mag::UInt64 = 0

    for i in 1:length(as)
        for j = 1:length(as)
            if i == j
                continue
            end

            max_mag = max(max_mag, magnitude(add!(deepcopy(as[i]), deepcopy(as[j]))))
        end
    end

    max_mag
end

function output(s::Submarine)
    println("Part 1: $(magnitude(s.final_sum))")
    println("Part 2: $(max_magnitude(s.all_snail_numbers))")
end

end