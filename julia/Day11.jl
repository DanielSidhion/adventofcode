module Day11

export Submarine, on_input!, output

mutable struct Submarine
    energy_levels::Matrix{UInt32}
    flashed::Matrix{Bool}
    total_flashes::UInt32

    Submarine() = new(Matrix(undef, 0, 0), Matrix(undef, 0, 0), 0)
end

function on_input!(s::Submarine, a::AbstractString)
    energies = parse.(UInt32, split(a, ""))

    if size(s.energy_levels) == (0, 0)
        s.energy_levels = Matrix(undef, 0, length(energies))
        s.flashed = Matrix(undef, 0, length(energies))
    end

    s.energy_levels = [s.energy_levels; energies']
    s.flashed = [s.flashed; falses(length(energies))']
end

function simulate_step!(s::Submarine)
    (ysize, xsize) = size(s.energy_levels)

    for y = 1:ysize
        for x = 1:xsize
            increase_energy_level!(s, x, y)
        end
    end

    all_flashed_this_turn = true

    for y = 1:ysize
        for x = 1:xsize
            if s.flashed[y, x]
                s.flashed[y, x] = false
                s.energy_levels[y, x] = 0
            else
                all_flashed_this_turn = false
            end
        end
    end

    all_flashed_this_turn
end

function increase_energy_level!(s::Submarine, x, y)
    (ysize, xsize) = size(s.energy_levels)

    if x < 1 || x > xsize || y < 1 || y > ysize
        return
    end

    s.energy_levels[y, x] += 1

    if s.energy_levels[y, x] > 9
        flash!(s, x, y)
    end
end

function flash!(s::Submarine, x, y)
    if s.flashed[y, x]
        return
    end

    s.flashed[y, x] = true;
    s.total_flashes += 1

    for j in -1:1
        for i in -1:1
            increase_energy_level!(s, x + i, y + j)
        end
    end
end

function output(s::Submarine)
    i = 0
    total_flashes_after_100_steps = 0
    first_synchronized_flash = 0

    while total_flashes_after_100_steps == 0 || first_synchronized_flash == 0
        i += 1

        all_flashed = simulate_step!(s)

        if i == 100
            total_flashes_after_100_steps = s.total_flashes
        end

        if all_flashed
            first_synchronized_flash = i
        end
    end

    println("Part 1: $(total_flashes_after_100_steps)")
    println("Part 2: $(first_synchronized_flash)")
end

end