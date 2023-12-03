const std = @import("std");

const EMPTY_SPACE = ".!@#$%&*-+=/";
const SYMBOLS = EMPTY_SPACE[1..];

fn hasAdjacentSymbol(grid: [][]const u8, line_position: usize, start_position: usize, end_position: usize) bool {
    var start_line_pos = if (line_position > 0) line_position - 1 else 0;
    var end_line_pos = if (line_position == grid.len - 1) line_position + 1 else line_position + 2;
    var start_pos = if (start_position > 0) start_position - 1 else 0;
    var end_pos = if (end_position == grid[0].len) end_position else end_position + 1;

    for (start_line_pos..end_line_pos) |y| {
        for (start_pos..end_pos) |x| {
            if (x < 0 or x >= grid[0].len) {
                continue;
            }

            const curr_space = grid[y][x .. x + 1];
            if (std.mem.indexOf(u8, SYMBOLS, curr_space) != null) {
                return true;
            }
        }
    }

    return false;
}

pub fn day03_1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var grid = std.ArrayList([]const u8).init(arena.allocator());

    var result: u32 = 0;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        try grid.append(line);
    }

    for (grid.items, 0..) |line, i| {
        var numbers = std.mem.splitAny(u8, line, EMPTY_SPACE);

        while (numbers.next()) |number| {
            if (number.len == 0) {
                continue;
            }

            // This is the index right after the last digit of the number.
            const end_position = if (numbers.index != null) numbers.index.? - 1 else line.len;
            // This is the index of the first digit of the number.
            const start_position = end_position - number.len;
            if (hasAdjacentSymbol(grid.items, i, start_position, end_position)) {
                const parsed_number = try std.fmt.parseInt(u32, number, 10);
                result += parsed_number;
            }
        }
    }

    return result;
}

test "example 1" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
        \\
    ;

    const output = try day03_1(input);
    try std.testing.expectEqual(@as(u32, 4361), output);
}

test "input 1" {
    const input = @embedFile("./input03");
    const output = try day03_1(input);
    try std.testing.expectEqual(@as(u32, 544664), output);
}
