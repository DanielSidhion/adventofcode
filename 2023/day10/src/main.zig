const std = @import("std");

pub fn day10_1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var grid = std.ArrayList([]const u8).init(arena.allocator());
    var starting_pos: [2]usize = [_]usize{ 0, 0 };

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        if (std.mem.indexOf(u8, line, "S")) |x| {
            starting_pos[1] = grid.items.len;
            starting_pos[0] = x;
        }

        try grid.append(line);
    }

    var size = loopSize(grid.items, starting_pos[0], starting_pos[1]);
    return size / 2;
}

fn loopSize(grid: [][]const u8, x: usize, y: usize) u32 {
    if (x > 0 and (grid[y][x - 1] == '-' or grid[y][x - 1] == 'F' or grid[y][x - 1] == 'L')) {
        return countSteps(grid, x, y, x - 1, y, 0);
    } else if (x < grid[0].len - 1 and (grid[y][x + 1] == '-' or grid[y][x + 1] == '7' or grid[y][x + 1] == 'J')) {
        return countSteps(grid, x, y, x + 1, y, 0);
    } else if (y > 0 and (grid[y - 1][x] == '|' or grid[y - 1][x] == '7' or grid[y - 1][x] == 'F')) {
        return countSteps(grid, x, y, x, y - 1, 0);
    } else if (y < grid.len - 1 and (grid[y + 1][x] == '|' or grid[y + 1][x] == 'L' or grid[y + 1][x] == 'J')) {
        return countSteps(grid, x, y, x, y + 1, 0);
    } else {
        unreachable;
    }
}

fn countSteps(grid: [][]const u8, start_x: usize, start_y: usize, x: usize, y: usize, curr_steps: u32) u32 {
    var new_x = x;
    var new_y = y;

    switch (grid[y][x]) {
        'S' => {
            return curr_steps + 1;
        },
        '-' => {
            if (x > start_x) {
                new_x = x + 1;
            } else {
                new_x = x - 1;
            }
        },
        '7' => {
            if (x == start_x) {
                new_x = x - 1;
            } else {
                new_y = y + 1;
            }
        },
        'J' => {
            if (x == start_x) {
                new_x = x - 1;
            } else {
                new_y = y - 1;
            }
        },
        'F' => {
            if (x == start_x) {
                new_x = x + 1;
            } else {
                new_y = y + 1;
            }
        },
        'L' => {
            if (x == start_x) {
                new_x = x + 1;
            } else {
                new_y = y - 1;
            }
        },
        '|' => {
            if (y > start_y) {
                new_y = y + 1;
            } else {
                new_y = y - 1;
            }
        },
        else => unreachable,
    }

    return countSteps(grid, x, y, new_x, new_y, curr_steps + 1);
}

test "example 1" {
    const input =
        \\.....
        \\.S-7.
        \\.|.|.
        \\.L-J.
        \\.....
        \\
    ;

    const output = try day10_1(input);
    try std.testing.expectEqual(@as(u32, 4), output);
}

test "example 2" {
    const input =
        \\-L|F7
        \\7S-7|
        \\L|7||
        \\-L-J|
        \\L|-JF
        \\
    ;

    const output = try day10_1(input);
    try std.testing.expectEqual(@as(u32, 4), output);
}

test "example 3" {
    const input =
        \\..F7.
        \\.FJ|.
        \\SJ.L7
        \\|F--J
        \\LJ...
        \\L|-JF
        \\
    ;

    const output = try day10_1(input);
    try std.testing.expectEqual(@as(u32, 8), output);
}

test "example 4" {
    const input =
        \\7-F7-
        \\.FJ|7
        \\SJLL7
        \\|F--J
        \\LJ.LJ
        \\
    ;

    const output = try day10_1(input);
    try std.testing.expectEqual(@as(u32, 8), output);
}

test "input 1" {
    const input = @embedFile("./input10");
    const output = try day10_1(input);
    try std.testing.expectEqual(@as(u32, 6947), output);
}
