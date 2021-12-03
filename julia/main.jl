include("Day3.jl")

using .Day3

submarine = Submarine()

while (true)
    curr_line = readline()

    if curr_line == ""
        break
    end

    on_input!(submarine, curr_line)
end

output(submarine)