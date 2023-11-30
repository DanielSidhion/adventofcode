module Day21

export Submarine, on_input!, output

mutable struct Universe
    positions::Vector{UInt8}
    scores::Vector{UInt16}
    next_player::UInt8

    Universe(positions) = new(positions, [0, 0], 1)
end

mutable struct Submarine
    starting_positions::Vector{UInt8}
    d100_rolls::UInt32
    universe_scores::Vector{UInt64}

    Submarine() = new([0, 0], 0, [0, 0])
end

function on_input!(s::Submarine, a::AbstractString)
    if s.starting_positions[1] == 0
        s.starting_positions[1] = parse(UInt8, chop(a, head = length("Player 1 starting position: "), tail = 0)) - 1
    else
        s.starting_positions[2] = parse(UInt8, chop(a, head = length("Player 2 starting position: "), tail = 0)) - 1
    end
end

function d100_sum!(s::Submarine)::UInt8
    res::UInt8 = (6 + 3 * s.d100_rolls) % 100
    s.d100_rolls += 3
    res
end

function practice_game!(s::Submarine)::Universe
    u = Universe(copy(s.starting_positions))

    while true
        u.positions[u.next_player] += d100_sum!(s)
        u.positions[u.next_player] %= 10
        u.scores[u.next_player] += 1 + u.positions[u.next_player]

        if u.scores[u.next_player] >= 1000
            return u
        end

        u.next_player = u.next_player == 1 ? 2 : 1
    end
end

function dirac_game!(s::Submarine)
    dirac_possibilities = dirac_universes(3 % UInt)

    universes = Dict{NTuple{5,UInt},UInt64}()
    p1, p2 = s.starting_positions
    universes[(p1, 0, p2, 0, 1)] = 1

    while true
        new_universes = Dict{NTuple{5,UInt},UInt64}()

        for (dice_sum, possibilities) in enumerate(dirac_possibilities)
            for (u, amount) in universes
                p1, p1_s, p2, p2_s, np = u

                curr_pos = np == 1 ? p1 : p2
                curr_score = np == 1 ? p1_s : p2_s

                new_position = (curr_pos + dice_sum + 2) % 10
                new_score = curr_score + new_position + 1

                if new_score >= 21
                    s.universe_scores[np] += amount * possibilities
                    continue
                end

                if np == 1
                    p1 = new_position
                    p1_s = new_score
                    np = 2
                else
                    p2 = new_position
                    p2_s = new_score
                    np = 1
                end

                new_u = (p1, p1_s, p2, p2_s, np)

                if haskey(new_universes, new_u)
                    new_universes[new_u] += amount * possibilities
                else
                    new_universes[new_u] = amount * possibilities
                end
            end
        end

        if isempty(new_universes)
            return
        end

        universes = new_universes
    end
end

function output(s::Submarine)
    practice_universe = practice_game!(s)

    loser_score = minimum(practice_universe.scores)

    println("Part 1: $(loser_score * s.d100_rolls)")

    dirac_game!(s)

    println("Part 2: $(maximum(s.universe_scores))")
end

function dirac_universes(num_rolls::UInt)::Vector{UInt64}
    total_sum_possibilities = num_rolls * 2 + 1
    result = zeros(UInt64, total_sum_possibilities)

    add_dirac_possibility!(result, num_rolls, num_rolls, 0%UInt64)

    result
end

function add_dirac_possibility!(result::Vector{UInt64}, min_score::UInt, rolls_remaining::UInt, curr_score::UInt64)
    if rolls_remaining == 0
        result[curr_score-min_score+1] += 1
        return
    end

    add_dirac_possibility!(result, min_score, rolls_remaining - 1, curr_score + 1)
    add_dirac_possibility!(result, min_score, rolls_remaining - 1, curr_score + 2)
    add_dirac_possibility!(result, min_score, rolls_remaining - 1, curr_score + 3)
end

end