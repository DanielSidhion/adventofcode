const std = @import("std");

pub fn day13_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    var grid = std.ArrayList([]const u8).init(arena.allocator());

    var columns_left: u64 = 0;
    var rows_up: u64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            // Reached end of a grid, so let's find reflections.
            const vertical_line = findVerticalReflection(grid.items);

            if (vertical_line) |vline| {
                columns_left += @intCast(vline.line);
            } else {
                const horizontal_line = findHorizontalReflection(grid.items);

                if (horizontal_line) |hline| {
                    rows_up += @intCast(hline.line);
                } else {
                    unreachable;
                }
            }

            grid.clearRetainingCapacity();
            continue;
        }

        try grid.append(line);
    }

    return columns_left + 100 * rows_up;
}

const Reflection = struct { line: usize, len: usize };

fn findVerticalReflection(grid: [][]const u8) ?Reflection {
    // Doesn't make sense to find reflections at the edge of the grid.
    for (1..grid[0].len) |x| {
        // We'll find a reflection using a vertical line between `x - 1` and `x`.
        const columns_left = x;
        const columns_right = grid[0].len - x;
        const reflection_len = @min(columns_left, columns_right);

        const valid_reflection = for (0..reflection_len) |offset| {
            const all_equal = for (0..grid.len) |y| {
                if (grid[y][x - 1 - offset] != grid[y][x + offset]) {
                    break false;
                }
            } else true;

            if (!all_equal) {
                break false;
            }
        } else true;

        if (valid_reflection) {
            return Reflection{ .line = x, .len = reflection_len };
        }
    }

    return null;
}

fn findHorizontalReflection(grid: [][]const u8) ?Reflection {
    // Doesn't make sense to find reflections at the edge of the grid.
    for (1..grid.len) |y| {
        // We'll find a reflection using a horizontal line between `y - 1` and `y`.
        const rows_up = y;
        const rows_down = grid.len - y;
        const reflection_len = @min(rows_up, rows_down);

        const valid_reflection = for (0..reflection_len) |offset| {
            const all_equal = for (0..grid[0].len) |x| {
                if (grid[y - 1 - offset][x] != grid[y + offset][x]) {
                    break false;
                }
            } else true;

            if (!all_equal) {
                break false;
            }
        } else true;

        if (valid_reflection) {
            return Reflection{ .line = y, .len = reflection_len };
        }
    }

    return null;
}

pub fn day13_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    var grid = std.ArrayList([]const u8).init(arena.allocator());

    var columns_left: u64 = 0;
    var rows_up: u64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            // Reached end of a grid, so let's find reflections.
            const vertical_line = findSmudgeVerticalReflection(grid.items);

            if (vertical_line) |vline| {
                columns_left += @intCast(vline.line);
            } else {
                const horizontal_line = findSmudgeHorizontalReflection(grid.items);

                if (horizontal_line) |hline| {
                    rows_up += @intCast(hline.line);
                } else {
                    unreachable;
                }
            }

            grid.clearRetainingCapacity();
            continue;
        }

        try grid.append(line);
    }

    return columns_left + 100 * rows_up;
}

fn findSmudgeVerticalReflection(grid: [][]const u8) ?Reflection {
    // Doesn't make sense to find reflections at the edge of the grid.
    for (1..grid[0].len) |x| {
        // We'll find a reflection using a vertical line between `x - 1` and `x`.
        const columns_left = x;
        const columns_right = grid[0].len - x;
        const reflection_len = @min(columns_left, columns_right);

        var differences: usize = 0;

        for (0..reflection_len) |offset| {
            for (0..grid.len) |y| {
                if (grid[y][x - 1 - offset] != grid[y][x + offset]) {
                    differences += 1;
                }
            }
        }

        if (differences == 1) {
            return Reflection{ .line = x, .len = reflection_len };
        }
    }

    return null;
}

fn findSmudgeHorizontalReflection(grid: [][]const u8) ?Reflection {
    // Doesn't make sense to find reflections at the edge of the grid.
    for (1..grid.len) |y| {
        // We'll find a reflection using a horizontal line between `y - 1` and `y`.
        const rows_up = y;
        const rows_down = grid.len - y;
        const reflection_len = @min(rows_up, rows_down);

        var differences: usize = 0;

        for (0..reflection_len) |offset| {
            for (0..grid[0].len) |x| {
                if (grid[y - 1 - offset][x] != grid[y + offset][x]) {
                    differences += 1;
                }
            }
        }

        if (differences == 1) {
            return Reflection{ .line = y, .len = reflection_len };
        }
    }

    return null;
}

test "example 1" {
    const input =
        \\#.##..##.
        \\..#.##.#.
        \\##......#
        \\##......#
        \\..#.##.#.
        \\..##..##.
        \\#.#.##.#.
        \\
        \\#...##..#
        \\#....#..#
        \\..##..###
        \\#####.##.
        \\#####.##.
        \\..##..###
        \\#....#..#
        \\
    ;

    const output = try day13_1(input);
    try std.testing.expectEqual(@as(u64, 405), output);
}

test "input 1" {
    const input = @embedFile("./input13");
    const output = try day13_1(input);
    try std.testing.expectEqual(@as(u64, 33780), output);
}

test "example 2" {
    const input =
        \\#.##..##.
        \\..#.##.#.
        \\##......#
        \\##......#
        \\..#.##.#.
        \\..##..##.
        \\#.#.##.#.
        \\
        \\#...##..#
        \\#....#..#
        \\..##..###
        \\#####.##.
        \\#####.##.
        \\..##..###
        \\#....#..#
        \\
    ;

    const output = try day13_2(input);
    try std.testing.expectEqual(@as(u64, 400), output);
}

test "input 2" {
    const input = @embedFile("./input13");
    const output = try day13_2(input);
    try std.testing.expectEqual(@as(u64, 23479), output);
}
