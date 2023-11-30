module Day19

export Submarine, on_input!, output

using LinearAlgebra

const forward_directions = [
    [1, 0, 0],
    [-1, 0, 0],
    [0, 1, 0],
    [0, -1, 0],
    [0, 0, 1],
    [0, 0, -1]
]

function build_possible_rotation_matrices()::Array{Int32}
    result = Array{Int32}(undef, (3, 3, 0))

    for forward_i = 1:6
        x = forward_directions[forward_i]

        y_possibilities = [
            [x[3], x[1], x[2]],
            [-x[3], -x[1], -x[2]],
            [x[2], x[3], x[1]],
            [-x[2], -x[3], -x[1]],
        ]

        for y in y_possibilities
            z = x × y

            rot_mat = [x y z]
            result = [result;;; rot_mat]
        end
    end

    result
end

mutable struct Submarine
    scanner_reports::Vector{Matrix{Int32}}
    beacons_relative_to_0::Set{Vector{Int32}}
    scanner_position_relative_to_0::Matrix{Int32}

    scanner_possible_rotations::Array{Int32}

    Submarine() = new(Vector{Matrix{Int32}}(), Set{Vector{Int32}}(), Matrix(undef, 3, 0), build_possible_rotation_matrices())
end

function on_input!(s::Submarine, a::AbstractString)
    if startswith(a, "---")
        push!(s.scanner_reports, Matrix(undef, 3, 0))
        s.scanner_position_relative_to_0 = [s.scanner_position_relative_to_0 [0, 0, 0]]
        return
    end

    if isempty(a)
        return
    end

    coords = parse.(Int32, split(a, ","))
    s.scanner_reports[end] = [s.scanner_reports[end] coords]
end

function output(s::Submarine)
    triangulate(s)

    total_beacons = length(s.beacons_relative_to_0)

    println("Part 1: $(total_beacons)")
    println("Part 2: $(max_manhattan_between_scanners(s))")
end

function manhattan(p1::Vector{Int32}, p2::Vector{Int32})::Int32
    sum(abs.(p1 - p2))
end

function max_manhattan_between_scanners(s::Submarine)::Int32
    result::Int32 = 0
    total_scanners = length(s.scanner_reports)

    for i in 1:total_scanners
        for j in i + 1:total_scanners
            result = max(result, manhattan(s.scanner_position_relative_to_0[:, i], s.scanner_position_relative_to_0[:, j]))
        end
    end

    result
end

function invert_tuple(t::Tuple{Int32,Int32})::Tuple{Int32,Int32}
    (t[2], t[1])
end

function triangulate_scanners(s::Submarine, i, j)::Bool
    if !iszero(s.scanner_position_relative_to_0[:, i]) && !iszero(s.scanner_position_relative_to_0[:, j])
        return false
    end

    common = common_beacons(s.scanner_reports[i], s.scanner_reports[j])

    if length(common) < 12
        return false
    end

    from = i
    to = j

    if !iszero(s.scanner_position_relative_to_0[:, to])
        from, to = to, from

        common = map(invert_tuple, common)
    end

    total_possible_rotations = size(s.scanner_possible_rotations)[3]

    for rotation = 1:total_possible_rotations
        adjusted_points = s.scanner_possible_rotations[:, :, rotation] * s.scanner_reports[to]

        dists = collect(map(x -> s.scanner_reports[from][:, x[1]] - adjusted_points[:, x[2]], common))
        if all(x -> x == dists[1], dists)
            s.scanner_reports[to] = adjusted_points
            s.scanner_position_relative_to_0[:, to] = s.scanner_position_relative_to_0[:, from] + dists[1]

            for p in eachcol(adjusted_points)
                push!(s.beacons_relative_to_0, p + s.scanner_position_relative_to_0[:, to])
            end

            return true
        end
    end

    return false
end

function triangulate(s::Submarine)
    total_scanners = length(s.scanner_reports)

    for p in eachcol(s.scanner_reports[1])
        push!(s.beacons_relative_to_0, p)
    end

    visited = falses(total_scanners)
    visited[1] = true

    for i = 2:total_scanners
        if triangulate_scanners(s, 1, i)
            visited[i] = true
        end
    end

    while !all(visited)
        for i = 2:total_scanners
            if !visited[i]
                continue
            end

            for j = 2:total_scanners
                if visited[j]
                    continue
                end

                if triangulate_scanners(s, i, j)
                    visited[j] = true
                end
            end
        end
    end
end

function squared_dist(p1::Vector{Int32}, p2::Vector{Int32})::Int32
    sum((p1 - p2) .^ 2)
end

# The following will allow us to compare tuples only looking at the first element, which is what we want for the code below.
import Base
# Sets in julia are backed by dictionaries, so we need to override the `==` and `isequal` behaviors for some set operations, as well as override the `hash` behavior for the dictionary.
Base.:(==)(lhs::Tuple{Int32,Int32}, rhs::Tuple{Int32,Int32}) = (lhs[1] == rhs[1])
Base.isequal(x::Tuple{Int32,Int32}, y::Tuple{Int32,Int32}) = x == y
Base.hash(x::Tuple{Int32,Int32}, h::UInt) = hash(x[1], h)

function squared_distance_sets(beacons::Matrix{Int32})::Vector{Set{Tuple{Int32,Int32}}}
    n = size(beacons)[2]

    result = [Set{Tuple{Int32,Int32}}() for _ = 1:n]

    for i::Int32 in 1:n
        for j::Int32 in i+1:n
            dist = squared_dist(beacons[:, i], beacons[:, j])
            push!(result[i], (dist, j))
            push!(result[j], (dist, i))
        end
    end

    result
end

function common_beacons(beacons1::Matrix{Int32}, beacons2::Matrix{Int32})::Vector{Tuple{Int32,Int32}}
    result = Vector{Tuple{Int32,Int32}}()

    dist1 = squared_distance_sets(beacons1)
    dist2 = squared_distance_sets(beacons2)

    for i = 1:length(dist1)
        for j = 1:length(dist2)
            common_dists = dist1[i] ∩ dist2[j]

            if length(common_dists) < 11
                continue
            end

            push!(result, (i, j))

            # We'll use this to get the actual tuple in each set because we can't do that directly in sets.
            collected_dist1 = collect(dist1[i])
            collected_dist2 = collect(dist2[j])

            for d in common_dists
                pos1 = collected_dist1[findfirst(isequal(d), collected_dist1)]
                pos2 = collected_dist2[findfirst(isequal(d), collected_dist2)]

                push!(result, (pos1[2], pos2[2]))
            end
        end
    end

    result
end

end