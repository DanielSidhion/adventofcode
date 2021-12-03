include("Day3.jl")

using .Day3

submarine = Submarine()

while (true)
    curr_line = readline()

    if curr_line == ""
        break
    end

    on_report!(submarine, curr_line)
end

power_consumption, life_support = compute_report(submarine)
print("$(power_consumption)\n")
print("$(life_support)\n")