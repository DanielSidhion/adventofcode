module Day12

export Submarine, on_input!, output

function is_big_cave(name)
    isuppercase(name[1])
end

mutable struct Cave
    is_big::Bool
    connections::Vector{UInt32}

    Cave(name) = new(is_big_cave(name), [])
end

mutable struct Submarine
    caves::Vector{Cave}
    cave_name_map::Dict{AbstractString, UInt32}

    Submarine() = new([], Dict())
end

function on_input!(s::Submarine, a::AbstractString)
    from, to = collect(split(a, "-"))

    add_cave_if_unknown!(s, from)
    add_cave_if_unknown!(s, to)

    from_index = s.cave_name_map[from]
    to_index = s.cave_name_map[to]

    push!(s.caves[from_index].connections, to_index)
    push!(s.caves[to_index].connections, from_index)
end

function add_cave_if_unknown!(s::Submarine, name)
    if !haskey(s.cave_name_map, name)
        push!(s.caves, Cave(name))
        s.cave_name_map[name] = length(s.caves)
    end
end

function total_valid_paths_from_to(s::Submarine, from, to, double_small_cave_allowed)::UInt32
    from_index = s.cave_name_map[from]
    to_index = s.cave_name_map[to]

    dive(s, from_index, to_index, [], double_small_cave_allowed, false, from_index)
end

function dive(
    s::Submarine,
    from_index,
    to_index,
    small_caves_visited,
    double_small_cave_allowed,
    has_double_small_cave,
    start_index
)
    if from_index == to_index
        return 1
    end

    if !s.caves[from_index].is_big
        if from_index ∉ small_caves_visited
            push!(small_caves_visited, from_index)
        else
            if double_small_cave_allowed && !has_double_small_cave && from_index != start_index
                has_double_small_cave = true
            else
                return 0
            end
        end
    end

    paths_from_here = 0

    for connection in s.caves[from_index].connections
        paths_from_here += dive(
            s,
            connection,
            to_index,
            copy(small_caves_visited),
            double_small_cave_allowed,
            has_double_small_cave,
            start_index
        )
    end

    paths_from_here
end

function output(s::Submarine)
    total_paths_single_small_cave = total_valid_paths_from_to(s, "start", "end", false)
    total_paths_double_small_cave = total_valid_paths_from_to(s, "start", "end", true)

    println("Part 1: $(total_paths_single_small_cave)")
    println("Part 2: $(total_paths_double_small_cave)")
end

end