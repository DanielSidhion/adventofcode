module Day17

export Submarine, on_input!, output

mutable struct Submarine
    target_area_x::Tuple{Int32, Int32}
    target_area_y::Tuple{Int32, Int32}

    Submarine() = new((0, 0), (0, 0))
end

function on_input!(s::Submarine, a::AbstractString)
    target_area = collect(split(chop(a, head = length("target area: x="), tail = 0), ", y="))

    x_area = collect(parse.(Int32, split(target_area[1], "..")))
    y_area = collect(parse.(Int32, split(target_area[2], "..")))

    # The entire solution assumes that `0 <= x_area[1] <= x_area[2]` and that `y_area[1] <= y_area[2] <= 0`.
    s.target_area_x = (x_area[1], x_area[2])
    s.target_area_y = (y_area[1], y_area[2])
end

function highest_y(s::Submarine)::Int32
    vy_max::Int32 = maximum(abs.(s.target_area_y))

    (vy_max * (vy_max - 1)) / 2
end

function within_bounds(s::Submarine, vx::Int32, vy::Int32)::Bool
    x_pos::Int32 = 0
    y_pos::Int32 = 0

    while x_pos < s.target_area_x[2] && y_pos > s.target_area_y[1]
        x_pos += vx
        y_pos += vy

        if x_pos >= s.target_area_x[1] && x_pos <= s.target_area_x[2] && y_pos >= s.target_area_y[1] && y_pos <= s.target_area_y[2]
            return true
        end

        vx -= 1;
        vx = max(0, vx);
        vy -= 1;
    end

    false
end

function distinct_velocity_values(s::Submarine)::Int32
    vx_max::Int32 = s.target_area_x[2];
    vy_max::Int32 = maximum(abs.(s.target_area_y))
    vy_min = s.target_area_y[1];

    possibilities::Int32 = 0;

    for vx::Int32 in 0:vx_max
        for vy in vy_min:vy_max
            if within_bounds(s, vx, vy)
                possibilities += 1
            end
        end
    end

    possibilities
end

function output(s::Submarine)
    println("Part 1: $(highest_y(s))")
    println("Part 2: $(distinct_velocity_values(s))")
end

end