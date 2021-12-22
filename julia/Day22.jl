module Day22

export Submarine, on_input!, output

struct Cuboid
    x::Vector{Int64}
    y::Vector{Int64}
    z::Vector{Int64}

    Cuboid(coords::Vector{Vector{Int64}}) = new(coords...)
    Cuboid(x, y, z) = new(x, y, z)
end

function is_valid(c::Cuboid)::Bool
    c.x[1] <= c.x[2] && c.y[1] <= c.y[2] && c.z[1] <= c.z[2]
end

function in_initialization_area(c::Cuboid)::Bool
    all(
        (c.x .>= -50) .& (c.x .<= 50) .&
        (c.y .>= -50) .& (c.y .<= 50) .&
        (c.z .>= -50) .& (c.z .<= 50)
    )
end

function num_cubes(c::Cuboid)::UInt64
    (c.x[2] - c.x[1] + 1) * (c.y[2] - c.y[1] + 1) * (c.z[2] - c.z[1] + 1)
end

function intersects(a::Cuboid, b::Cuboid)::Bool
    a.x[1] <= b.x[2] && a.x[2] >= b.x[1] &&
    a.y[1] <= b.y[2] && a.y[2] >= b.y[1] &&
    a.z[1] <= b.z[2] && a.z[2] >= b.z[1]
end

function clamped(coords::Vector{Int64}, clamp::Vector{Int64})::Vector{Int64}
    [max(coords[1], clamp[1]), min(coords[2], clamp[2])]
end

function break_apart(c::Cuboid, o::Cuboid)::Vector{Cuboid}
    if !intersects(c, o)
        return [c]
    end

    result = [
        Cuboid(c.x, c.y, [c.z[1], o.z[1] - 1]),
        Cuboid(c.x, c.y, [o.z[2] + 1, c.z[2]]),
        Cuboid([c.x[1], o.x[1] - 1], c.y, clamped(o.z, c.z)),
        Cuboid([o.x[2] + 1, c.x[2]], c.y, clamped(o.z, c.z)),
        Cuboid(clamped(o.x, c.x), [c.y[1], o.y[1] - 1], clamped(o.z, c.z)),
        Cuboid(clamped(o.x, c.x), [o.y[2] + 1, c.y[2]], clamped(o.z, c.z)),
    ]

    collect(filter(is_valid, result))
end

mutable struct Submarine
    on_cuboids_initialization::Vector{Cuboid}
    on_cuboids::Vector{Cuboid}

    Submarine() = new([], [])
end

function on_input!(s::Submarine, a::AbstractString)
    action, all_coords = split(a, " ")

    coords::Vector{Vector{Int64}} = collect(map(d -> parse.(Int64, split(chop(d, head = 2, tail = 0), "..")), split(all_coords, ",")))

    reboot(s, action, coords)
end

function reboot(s::Submarine, action, coords::Vector{Vector{Int64}})
    action_cuboid = Cuboid(coords)

    if in_initialization_area(action_cuboid)
        s.on_cuboids_initialization = collect(Iterators.flatten(map(c -> break_apart(c, action_cuboid), s.on_cuboids_initialization)))

        if action == "on"
            push!(s.on_cuboids_initialization, deepcopy(action_cuboid))
        end
    end

    s.on_cuboids = collect(Iterators.flatten(map(c -> break_apart(c, action_cuboid), s.on_cuboids)))

    if action == "on"
        push!(s.on_cuboids, action_cuboid)
    end
end

function cubes_initialization_on(s::Submarine)::UInt64
    sum(map(num_cubes, s.on_cuboids_initialization))
end

function cubes_on(s::Submarine)::UInt64
    sum(map(num_cubes, s.on_cuboids))
end

function output(s::Submarine)
    println("Part 1: $(cubes_initialization_on(s))")
    println("Part 2: $(cubes_on(s))")
end

end