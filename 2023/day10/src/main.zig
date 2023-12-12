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

pub fn day10_2(input: []const u8) !u32 {
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

    // The idea we'll follow is:
    // - We'll create a "cleaned" version of the grid. It starts with all '.' characters.
    // - As we follow the loop from the starting position, we'll print the pipes that belong to the loop in the clean grid.
    // - We'll also keep track of whether the "inside" of the loop is to our left or to our right. We do this by counting how many left turns and right turns we take. If we take more right turns than left when we finish the loop, this means the "inside" of the loop is to our right, else it's to our left.
    // - We'll go through the loop again, but this time, since we know where the "inside" is, we'll mark any '.' that we find along the way and is inside the loop. We'll change those from '.' to 'I'.
    // - After this, we perform a flood-fill on all 'I' characters, and count how many 'I' we have.

    // This is the "cleaned" version of the grid.
    var painted_grid = std.ArrayList([]u8).init(arena.allocator());
    // Used for the flood-fill.
    var visited = std.ArrayList([]bool).init(arena.allocator());
    for (0..grid.items.len) |_| {
        var empty_line = try std.ArrayList(u8).initCapacity(arena.allocator(), grid.items[0].len);
        empty_line.expandToCapacity();
        @memset(empty_line.items, '.');
        try painted_grid.append(empty_line.items);

        var visited_line = try std.ArrayList(bool).initCapacity(arena.allocator(), grid.items[0].len);
        visited_line.expandToCapacity();
        @memset(visited_line.items, false);
        try visited.append(visited_line.items);
    }

    const dir = paintLoop(grid.items, painted_grid.items, starting_pos[0], starting_pos[1]);

    const right_is_inside = dir > 0; // If false, it means left is inside.
    paintInside(grid.items, painted_grid.items, starting_pos[0], starting_pos[1], right_is_inside);
    floodFillInside(painted_grid.items, visited.items);

    var total_inside: u32 = 0;
    for (painted_grid.items) |line| {
        total_inside += @intCast(std.mem.count(u8, line, "I"));
    }
    return total_inside;
}

// For some debugging.
fn printGrid(grid: [][]const u8) void {
    for (grid) |line| {
        for (line) |char| {
            const char_to_print = switch (char) {
                'F' => "┏",
                '-' => "━",
                '|' => "┃",
                'J' => "┛",
                '7' => "┓",
                'L' => "┗",
                '.' => "·",
                else => &[_]u8{char},
            };

            std.debug.print("{s}", .{char_to_print});
        }
        std.debug.print("\n", .{});
    }
}

fn paintLoop(grid: [][]const u8, painted_grid: [][]u8, x: usize, y: usize) i32 {
    if (x > 0 and (grid[y][x - 1] == '-' or grid[y][x - 1] == 'F' or grid[y][x - 1] == 'L')) {
        switch (grid[y][x - 1]) {
            '-' => return paintLoopInner(grid, painted_grid, x, y, x - 1, y, 0),
            'F' => return paintLoopInner(grid, painted_grid, x, y, x - 1, y, -1),
            'L' => return paintLoopInner(grid, painted_grid, x, y, x - 1, y, 1),
            else => unreachable,
        }
    } else if (x < grid[0].len - 1 and (grid[y][x + 1] == '-' or grid[y][x + 1] == '7' or grid[y][x + 1] == 'J')) {
        switch (grid[y][x + 1]) {
            '-' => return paintLoopInner(grid, painted_grid, x, y, x + 1, y, 0),
            '7' => return paintLoopInner(grid, painted_grid, x, y, x + 1, y, 1),
            'J' => return paintLoopInner(grid, painted_grid, x, y, x + 1, y, -1),
            else => unreachable,
        }
    } else if (y > 0 and (grid[y - 1][x] == '|' or grid[y - 1][x] == '7' or grid[y - 1][x] == 'F')) {
        switch (grid[y - 1][x]) {
            '|' => return paintLoopInner(grid, painted_grid, x, y, x, y - 1, 0),
            '7' => return paintLoopInner(grid, painted_grid, x, y, x, y - 1, -1),
            'F' => return paintLoopInner(grid, painted_grid, x, y, x, y - 1, 1),
            else => unreachable,
        }
    } else if (y < grid.len - 1 and (grid[y + 1][x] == '|' or grid[y + 1][x] == 'L' or grid[y + 1][x] == 'J')) {
        switch (grid[y + 1][x]) {
            '|' => return paintLoopInner(grid, painted_grid, x, y, x, y - 1, 0),
            'L' => return paintLoopInner(grid, painted_grid, x, y, x, y - 1, -1),
            'J' => return paintLoopInner(grid, painted_grid, x, y, x, y - 1, 1),
            else => unreachable,
        }
    } else {
        unreachable;
    }
}

fn paintLoopInner(grid: [][]const u8, painted_grid: [][]u8, start_x: usize, start_y: usize, x: usize, y: usize, turn_counter: i32) i32 {
    var new_x = x;
    var new_y = y;
    var new_turn_counter = turn_counter;

    switch (grid[y][x]) {
        'S' => {
            // We mostly don't care about transforming the 'S' in its correct pipe character. It's possible this is a bug that was never uncovered during the AoC inputs, but I spent too much time on this already.
            painted_grid[y][x] = 'S';
            return new_turn_counter;
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
                new_turn_counter -= 1;
            } else {
                new_y = y + 1;
                new_turn_counter += 1;
            }
        },
        'J' => {
            if (x == start_x) {
                new_x = x - 1;
                new_turn_counter += 1;
            } else {
                new_y = y - 1;
                new_turn_counter -= 1;
            }
        },
        'F' => {
            if (x == start_x) {
                new_x = x + 1;
                new_turn_counter += 1;
            } else {
                new_y = y + 1;
                new_turn_counter -= 1;
            }
        },
        'L' => {
            if (x == start_x) {
                new_x = x + 1;
                new_turn_counter -= 1;
            } else {
                new_y = y - 1;
                new_turn_counter += 1;
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

    painted_grid[y][x] = grid[y][x];
    return paintLoopInner(grid, painted_grid, x, y, new_x, new_y, new_turn_counter);
}

fn paintInside(grid: [][]const u8, painted_grid: [][]u8, x: usize, y: usize, right_is_inside: bool) void {
    if (x > 0 and (grid[y][x - 1] == '-' or grid[y][x - 1] == 'F' or grid[y][x - 1] == 'L')) {
        return paintInsideInner(grid, painted_grid, x, y, x - 1, y, right_is_inside);
    } else if (x < grid[0].len - 1 and (grid[y][x + 1] == '-' or grid[y][x + 1] == '7' or grid[y][x + 1] == 'J')) {
        return paintInsideInner(grid, painted_grid, x, y, x + 1, y, right_is_inside);
    } else if (y > 0 and (grid[y - 1][x] == '|' or grid[y - 1][x] == '7' or grid[y - 1][x] == 'F')) {
        return paintInsideInner(grid, painted_grid, x, y, x, y - 1, right_is_inside);
    } else if (y < grid.len - 1 and (grid[y + 1][x] == '|' or grid[y + 1][x] == 'L' or grid[y + 1][x] == 'J')) {
        return paintInsideInner(grid, painted_grid, x, y, x, y - 1, right_is_inside);
    } else {
        unreachable;
    }
}

fn maybePaintInsidePosition(painted_grid: [][]u8, x: isize, y: isize) void {
    if (x < 0 or y < 0) {
        return;
    }

    const x_u: usize = @intCast(x);
    const y_u: usize = @intCast(y);

    if (y_u > painted_grid.len or x_u > painted_grid[0].len) {
        return;
    }

    if (painted_grid[y_u][x_u] == '.') {
        painted_grid[y_u][x_u] = 'I';
    }
}

fn paintInsideInner(grid: [][]const u8, painted_grid: [][]u8, start_x: usize, start_y: usize, x: usize, y: usize, right_is_inside: bool) void {
    var new_x = x;
    var new_y = y;

    const x_i: isize = @intCast(x);
    const y_i: isize = @intCast(y);

    switch (grid[y][x]) {
        'S' => {
            return;
        },
        '-' => {
            if (x > start_x) {
                new_x = x + 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i, y_i + 1);
                } else {
                    maybePaintInsidePosition(painted_grid, x_i, y_i - 1);
                }
            } else {
                new_x = x - 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i, y_i - 1);
                } else {
                    maybePaintInsidePosition(painted_grid, x_i, y_i + 1);
                }
            }
        },
        '7' => {
            if (x == start_x) {
                new_x = x - 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i + 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i - 1);
                }
            } else {
                new_y = y + 1;

                if (!right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i + 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i - 1);
                }
            }
        },
        'J' => {
            if (x == start_x) {
                new_x = x - 1;

                if (!right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i + 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i + 1);
                }
            } else {
                new_y = y - 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i + 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i + 1);
                }
            }
        },
        'F' => {
            if (x == start_x) {
                new_x = x + 1;

                if (!right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i - 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i - 1);
                }
            } else {
                new_y = y + 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i - 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i - 1);
                }
            }
        },
        'L' => {
            if (x == start_x) {
                new_x = x + 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i - 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i + 1);
                }
            } else {
                new_y = y - 1;

                if (!right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i - 1, y_i);
                    maybePaintInsidePosition(painted_grid, x_i, y_i + 1);
                }
            }
        },
        '|' => {
            if (y > start_y) {
                new_y = y + 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i - 1, y_i);
                } else {
                    maybePaintInsidePosition(painted_grid, x_i + 1, y_i);
                }
            } else {
                new_y = y - 1;

                if (right_is_inside) {
                    maybePaintInsidePosition(painted_grid, x_i + 1, y_i);
                } else {
                    maybePaintInsidePosition(painted_grid, x_i - 1, y_i);
                }
            }
        },
        else => unreachable,
    }

    return paintInsideInner(grid, painted_grid, x, y, new_x, new_y, right_is_inside);
}

fn floodFillInside(grid: [][]u8, visited: [][]bool) void {
    for (0..grid.len) |y| {
        for (0..grid[0].len) |x| {
            if (grid[y][x] == 'I' and !visited[y][x]) {
                floodFillInsideInner(grid, visited, x, y);
            }
        }
    }
}

fn isPipe(char: u8) bool {
    return char != '.' and char != 'I';
}

fn floodFillInsideInner(grid: [][]u8, visited: [][]bool, x: usize, y: usize) void {
    if (visited[y][x]) {
        return;
    }

    visited[y][x] = true;

    if (isPipe(grid[y][x])) {
        return;
    }

    if (grid[y][x] == '.') {
        grid[y][x] = 'I';
    }

    if (x > 0) {
        floodFillInsideInner(grid, visited, x - 1, y);
    }
    if (x < grid[0].len - 1) {
        floodFillInsideInner(grid, visited, x + 1, y);
    }
    if (y > 0) {
        floodFillInsideInner(grid, visited, x, y - 1);
    }
    if (y < grid.len - 1) {
        floodFillInsideInner(grid, visited, x, y + 1);
    }
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

test "example 5" {
    const input =
        \\...........
        \\.S-------7.
        \\.|F-----7|.
        \\.||.....||.
        \\.||.....||.
        \\.|L-7.F-J|.
        \\.|..|.|..|.
        \\.L--J.L--J.
        \\...........
        \\
    ;

    const output = try day10_2(input);
    try std.testing.expectEqual(@as(u32, 4), output);
}

test "example 6" {
    const input =
        \\..........
        \\.S------7.
        \\.|F----7|.
        \\.||....||.
        \\.||....||.
        \\.|L-7F-J|.
        \\.|..||..|.
        \\.L--JL--J.
        \\..........
        \\
    ;

    const output = try day10_2(input);
    try std.testing.expectEqual(@as(u32, 4), output);
}

test "example 7" {
    const input =
        \\.F----7F7F7F7F-7....
        \\.|F--7||||||||FJ....
        \\.||.FJ||||||||L7....
        \\FJL7L7LJLJ||LJ.L-7..
        \\L--J.L7...LJS7F-7L7.
        \\....F-J..F7FJ|L7L7L7
        \\....L7.F7||L7|.L7L7|
        \\.....|FJLJ|FJ|F7|.LJ
        \\....FJL-7.||.||||...
        \\....L---J.LJ.LJLJ...
        \\
    ;

    const output = try day10_2(input);
    try std.testing.expectEqual(@as(u32, 8), output);
}

test "example 8" {
    const input =
        \\FF7FSF7F7F7F7F7F---7
        \\L|LJ||||||||||||F--J
        \\FL-7LJLJ||||||LJL-77
        \\F--JF--7||LJLJ7F7FJ-
        \\L---JF-JLJ.||-FJLJJ7
        \\|F|F-JF---7F7-L7L|7|
        \\|FFJF7L7F-JF7|JL---7
        \\7-L-JL7||F7|L7F-7F7|
        \\L.L7LFJ|||||FJL7||LJ
        \\L7JLJL-JLJLJL--JLJ.L
        \\
    ;

    const output = try day10_2(input);
    try std.testing.expectEqual(@as(u32, 10), output);
}

test "input 2" {
    const input = @embedFile("./input10");
    const output = try day10_2(input);
    try std.testing.expectEqual(@as(u32, 273), output);
}
