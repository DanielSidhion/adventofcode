include("Day4.jl")

using .Day4

submarine = Submarine()

while (true)
    curr_line = readline()

    if eof(stdin)
        break
    end

    on_input!(submarine, curr_line)
end

output(submarine)