module Day20

export Submarine, on_input!, output

mutable struct Submarine
    enhancement_algorithm::BitVector
    input_image::BitMatrix

    Submarine() = new(BitVector(undef, 0), BitMatrix(undef, 0, 0))
end

function on_input!(s::Submarine, a::AbstractString)
    curr_line = BitVector(map(x -> x == "#" ? 1 : 0, split(a, "")))

    if length(s.enhancement_algorithm) == 0
        s.enhancement_algorithm = curr_line
        return
    end

    isempty(a) && return

    prepend!(curr_line, [0, 0])
    append!(curr_line, [0, 0])

    if size(s.input_image) == (0, 0)
        # Padding on top.
        s.input_image = falses(length(curr_line), 2)
    end

    s.input_image = [s.input_image curr_line]
end

function finish_padding!(s::Submarine)
    width, _ = size(s.input_image)

    s.input_image = [s.input_image falses(width, 2)]
end

function extend_padding!(s::Submarine)
    padding_value = s.input_image[1, 1]
    width, height = size(s.input_image)

    padding_h = padding_value ? trues(1, height) : falses(1, height)
    padding_w = padding_value ? trues(width + 2, 1) : falses(width + 2, 1)

    s.input_image = [padding_h; s.input_image; padding_h]
    s.input_image = [padding_w s.input_image padding_w]
end

function interpret_num(s::Submarine, x::UInt, y::UInt)::UInt
    s.input_image[x - 1, y - 1] << 8 |
    s.input_image[x, y - 1] << 7 |
    s.input_image[x + 1, y - 1] << 6 |
    s.input_image[x - 1, y] << 5 |
    s.input_image[x, y] << 4 |
    s.input_image[x + 1, y] << 3 |
    s.input_image[x - 1, y + 1] << 2 |
    s.input_image[x, y + 1] << 1 |
    s.input_image[x + 1, y + 1]
end

function enhance!(s::Submarine)
    width, height = size(s.input_image)

    new_padding_value = s.input_image[1, 1] ? s.enhancement_algorithm[512] : s.enhancement_algorithm[1]

    result = new_padding_value ? trues(width, height) : falses(width, height)
    padding_changed = false

    for x::UInt in 2:width - 1
        for y::UInt in 2:height - 1
            num = interpret_num(s, x, y)
            result[x, y] = s.enhancement_algorithm[num + 1]

            if x == 2 || x == width - 1 || y == 2 || y == height - 1
                padding_changed = padding_changed || result[x, y] != new_padding_value
            end
        end
    end

    s.input_image = result

    padding_changed && extend_padding!(s)
end

function lit_pixels(s::Submarine)::UInt
    sum(s.input_image)
end

function print_image(s::Submarine)
    width, height = size(s.input_image)

    for x in 1:width
        for y in 1:height
            print(s.input_image[x, y] ? '#' : '.')
        end

        println()
    end
end

function output(s::Submarine)
    finish_padding!(s)

    for _ in 1:2
        enhance!(s)
    end

    println("Part 1: $(lit_pixels(s))")

    for _ in 1:48
        enhance!(s)
    end

    println("Part 2: $(lit_pixels(s))")
end

end