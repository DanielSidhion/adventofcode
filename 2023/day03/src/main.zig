const std = @import("std");

const EMPTY_SPACE = ".!@#$%&*-+=/";
const SYMBOLS = EMPTY_SPACE[1..];

fn hasAdjacentSymbol(grid: [][]const u8, line_position: usize, start_position: usize, end_position: usize) bool {
    const start_line_pos = if (line_position > 0) line_position - 1 else 0;
    const end_line_pos = if (line_position == grid.len - 1) line_position + 1 else line_position + 2;
    const start_pos = if (start_position > 0) start_position - 1 else 0;
    const end_pos = if (end_position == grid[0].len) end_position else end_position + 1;

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

const Number = struct { x: usize, y: usize };

fn gearPower(grid: [][]const u8, x: usize, y: usize, number_map: anytype, allocator: std.mem.Allocator) !?u32 {
    const start_x = if (x > 0) x - 1 else x;
    const end_x = if (x == grid[0].len - 1) x + 1 else x + 2;
    const start_y = if (y > 0) y - 1 else y;
    const end_y = if (y == grid.len - 1) y + 1 else y + 2;

    var numbers_set = std.AutoHashMap(usize, u32).init(allocator);

    for (start_y..end_y) |curr_y| {
        for (start_x..end_x) |curr_x| {
            const grid_val = grid[curr_y][curr_x];
            if (grid_val >= '0' and grid_val <= '9') {
                const grid_number = Number{ .x = curr_x, .y = curr_y };
                const number_ptr = number_map.get(grid_number).?;
                try numbers_set.put(@intFromPtr(number_ptr), number_ptr.*);
            }
        }
    }

    if (numbers_set.count() == 2) {
        var result: u32 = 1;
        var numbers = numbers_set.iterator();

        while (numbers.next()) |v| {
            result *= v.value_ptr.*;
        }

        return result;
    }

    return null;
}

pub fn day03_2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var grid = std.ArrayList([]const u8).init(arena.allocator());

    var number_map = std.AutoHashMap(Number, *u32).init(arena.allocator());

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

            var new_number = try arena.allocator().create(u32);
            new_number.* = try std.fmt.parseInt(u32, number, 10);

            // Populating the position of all digits of this number with a pointer to the number.
            for (0..number.len) |offset| {
                try number_map.put(Number{ .x = start_position + offset, .y = i }, new_number);
            }
        }
    }

    for (grid.items, 0..) |line, y| {
        for (line, 0..) |val, x| {
            if (val != '*') {
                continue;
            }

            const gear_power = try gearPower(grid.items, x, y, number_map, arena.allocator());
            result += gear_power orelse 0;
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

test "example 2" {
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

    const output = try day03_2(input);
    try std.testing.expectEqual(@as(u32, 467835), output);
}

test "input 2" {
    const input = @embedFile("./input03");
    const output = try day03_2(input);
    try std.testing.expectEqual(@as(u32, 84495585), output);
}
