// Note: for this day I decided to just remove the code I used to solve part 1 and use the code for part 2 to solve both parts. If you want to see the code I created exclusively for part 1 (while I was solving it), check the commit history.

const std = @import("std");

const Position = struct { x: usize, y: usize };

// For debugging.
fn printUniverse(grid: *std.ArrayList(std.ArrayList(u8))) void {
    for (grid.items) |line| {
        std.debug.print("{s}\n", .{line.items});
    }
}

fn printExpansions(expansions: []bool) void {
    for (expansions) |e| {
        const char_to_print: u8 = if (e) 1 else 0;
        std.debug.print("{d} ", .{char_to_print});
    }
    std.debug.print("\n", .{});
}

fn printPositions(positions: []Position) void {
    std.debug.print("Positions: ", .{});

    for (positions) |pos| {
        std.debug.print("({d},{d}) ", .{ pos.x, pos.y });
    }

    std.debug.print("\n", .{});
}

fn findPositions(grid: *std.ArrayList(std.ArrayList(u8)), positions_list: *std.ArrayList(Position)) !void {
    for (grid.items, 0..) |line, y| {
        for (line.items, 0..) |char, x| {
            if (char == '#') {
                try positions_list.append(Position{ .x = x, .y = y });
            }
        }
    }
}

pub fn day11(input: []const u8, expansion_scale: usize) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    var grid = std.ArrayList(std.ArrayList(u8)).init(arena.allocator());

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var line_list = std.ArrayList(u8).init(arena.allocator());
        try line_list.appendSlice(line);
        try grid.append(line_list);
    }

    var horizontal_expansions = std.ArrayList(bool).init(arena.allocator());
    var vertical_expansions = std.ArrayList(bool).init(arena.allocator());

    try countExpansions(&grid, &horizontal_expansions, &vertical_expansions);

    var positions = std.ArrayList(Position).init(arena.allocator());
    try findPositions(&grid, &positions);

    var result: u64 = 0;

    for (0..positions.items.len) |i| {
        const galaxy_a = positions.items[i];

        for (i + 1..positions.items.len) |j| {
            const galaxy_b = positions.items[j];

            var distX: u64 = 0;
            if (galaxy_a.x < galaxy_b.x) {
                for (galaxy_a.x..galaxy_b.x) |x| {
                    distX += if (horizontal_expansions.items[x]) expansion_scale else 1;
                }
            } else {
                for (galaxy_b.x..galaxy_a.x) |x| {
                    distX += if (horizontal_expansions.items[x]) expansion_scale else 1;
                }
            }
            var distY: u64 = 0;
            if (galaxy_a.y < galaxy_b.y) {
                for (galaxy_a.y..galaxy_b.y) |y| {
                    distY += if (vertical_expansions.items[y]) expansion_scale else 1;
                }
            } else {
                for (galaxy_b.y..galaxy_a.y) |y| {
                    distY += if (vertical_expansions.items[y]) expansion_scale else 1;
                }
            }

            result += distX + distY;
        }
    }

    return result;
}

fn countExpansions(grid: *std.ArrayList(std.ArrayList(u8)), horizontal_expansions: *std.ArrayList(bool), vertical_expansions: *std.ArrayList(bool)) !void {
    for (0..grid.items[0].items.len) |x| {
        const empty_column = for (0..grid.items.len) |y| {
            if (grid.items[y].items[x] == '#') {
                break false;
            }
        } else true;

        try horizontal_expansions.append(empty_column);
    }

    for (0..grid.items.len) |y| {
        const empty_row = std.mem.allEqual(u8, grid.items[y].items, '.');

        try vertical_expansions.append(empty_row);
    }
}

test "example 1" {
    const input =
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
        \\
    ;

    const output = try day11(input, 2);
    try std.testing.expectEqual(@as(u64, 374), output);
}

test "input 1" {
    const input = @embedFile("./input11");
    const output = try day11(input, 2);
    try std.testing.expectEqual(@as(u64, 10292708), output);
}

test "example 2" {
    const input =
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
        \\
    ;

    const output = try day11(input, 10);
    try std.testing.expectEqual(@as(u64, 1030), output);
}

test "example 3" {
    const input =
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
        \\
    ;

    const output = try day11(input, 100);
    try std.testing.expectEqual(@as(u64, 8410), output);
}

test "input 2" {
    const input = @embedFile("./input11");
    const output = try day11(input, 1_000_000);
    try std.testing.expectEqual(@as(u64, 790194712336), output);
}
