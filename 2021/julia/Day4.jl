module Day4

export Submarine, on_input!, output

@enum ReadState ReadingChosenNumbers ReadingBoards

mutable struct BingoBoard
    nums::Vector{Int32}
    won::Bool
    win_score::Int32

    BingoBoard() = new([], false, 0)
end

mutable struct Submarine
    input_read_state::ReadState
    current_read_board::Union{BingoBoard, Nothing}

    chosen_bingo_numbers::Vector{Int32}
    bingo_boards::Vector{BingoBoard}

    Submarine() = new(ReadingChosenNumbers, nothing, [], [])
end

function on_input!(s::Submarine, a::AbstractString)
    on_input!(s::Submarine, Val(s.input_read_state), a)
end

function on_input!(s::Submarine, ::Val{ReadingChosenNumbers}, a::AbstractString)
    if a == ""
        s.input_read_state = ReadingBoards
        s.current_read_board = BingoBoard()
    else
        s.chosen_bingo_numbers = split(a, ",") .|> (x) -> parse(Int32, x)
    end
end

function on_input!(s::Submarine, ::Val{ReadingBoards}, a::AbstractString)
    if a == ""
        push!(s.bingo_boards, something(s.current_read_board))
        s.current_read_board = BingoBoard()
    else
        nums = filter(!isempty, split(a, " ")) .|> (x) -> parse(Int32, x)
        s.current_read_board.nums = vcat(s.current_read_board.nums, nums)
    end
end

function mark_number(val::Int32, num::Int32)
    val == num ? -val : val
end

function mark_board!(b::BingoBoard, num::Int32)
    b.nums = b.nums .|> (x) -> mark_number(x, num)
end

function has_board_won(b::BingoBoard)::Bool
    for i in 1:5
        row_win = all(signbit, Iterators.take(Iterators.drop(b.nums, (i - 1) * 5), 5))
        column_win = all(signbit, Iterators.flatten(Iterators.partition(b.nums, 5) .|> (r) -> first(Iterators.drop(r, i - 1))))

        if row_win || column_win
            return true
        end
    end

    false
end

function sum_unmarked(b::BingoBoard)::Int32
    sum(+, filter(!signbit, b.nums))
end

# This should've been named output! because for this particular situation, running through the code will mutate `s`. If I did this, I'd have to go back and rename the previous days' `output` functions as well, but that would've meant that they're now incorrectly named, because they don't mutate `s`. I'm too lazy to figure out a solution for this right now, so `output` it is.
function output(s::Submarine)
    first_board_score = 0
    last_board_score = 0

    for num in s.chosen_bingo_numbers
        foreach(mark_board!, s.bingo_boards, Iterators.repeated(num))

        won_boards = filter(has_board_won, s.bingo_boards)

        if first_board_score == 0 && length(won_boards) > 0
            first_board_score = num * sum_unmarked(won_boards[1])
        end

        if length(won_boards) == 1 && length(s.bingo_boards) == 1
            last_board_score = num * sum_unmarked(won_boards[1])
            break
        end

        s.bingo_boards = filter(!has_board_won, s.bingo_boards)
    end

    println("Part 1: $(first_board_score)")
    println("Part 2: $(last_board_score)")
end

end