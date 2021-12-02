include("Day2.jl")

using .Day2

submarine = Submarine()

while (true)
    curr_line = readline()

    if curr_line == ""
        break
    end

    on_action!(submarine, curr_line)
end

print("$(submarine.first_part_depth * submarine.horizontal_position)\n")
print("$(submarine.depth * submarine.horizontal_position)\n")