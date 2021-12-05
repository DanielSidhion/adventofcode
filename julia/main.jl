include("Day5.jl")

using .Day5

submarine = Submarine()

while (true)
    if eof(stdin)
        break
    end

    curr_line = readline()

    on_input!(submarine, curr_line)
end

output(submarine)