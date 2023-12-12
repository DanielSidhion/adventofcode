const std = @import("std");

const Position = struct { x: isize, y: isize };

pub fn day11_1(input: []const u8) !u32 {
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

    try expandUniverse(&grid, arena.allocator());

    var positions = std.ArrayList(Position).init(arena.allocator());
    try findPositions(&grid, &positions);

    var result: u32 = 0;

    for (0..positions.items.len) |i| {
        for (i + 1..positions.items.len) |j| {
            const distX = positions.items[i].x - positions.items[j].x;
            const distY = positions.items[i].y - positions.items[j].y;

            // Couldn't find a math.abs in Zig v0.11, rip.
            var dist = if (distX < 0) -distX else distX;
            dist += if (distY < 0) -distY else distY;

            result += @truncate(@as(usize, @intCast(dist)));
        }
    }

    return result;
}

// For debugging.
fn printUniverse(grid: *std.ArrayList(std.ArrayList(u8))) void {
    for (grid.items) |line| {
        std.debug.print("{s}\n", .{line.items});
    }
}

fn expandUniverse(grid: *std.ArrayList(std.ArrayList(u8)), allocator: std.mem.Allocator) !void {
    var x: usize = 0;

    while (x < grid.items[0].items.len) : (x += 1) {
        var empty_column = for (0..grid.items.len) |y| {
            if (grid.items[y].items[x] == '#') {
                break false;
            }
        } else true;

        if (empty_column) {
            for (0..grid.items.len) |y| {
                try grid.items[y].insert(x, '.');
            }
            // Must skip this new empty column, otherwise we'll duplicate it again.
            x += 1;
        }
    }

    var y: usize = 0;

    while (y < grid.items.len) : (y += 1) {
        const empty_row = std.mem.allEqual(u8, grid.items[y].items, '.');

        if (empty_row) {
            var new_line = std.ArrayList(u8).init(allocator);
            try new_line.appendSlice(grid.items[y].items);
            try grid.insert(y, new_line);
            // Again, must skip to avoid duplicating the row again.
            y += 1;
        }
    }
}

fn findPositions(grid: *std.ArrayList(std.ArrayList(u8)), positions_list: *std.ArrayList(Position)) !void {
    for (grid.items, 0..) |line, y| {
        for (line.items, 0..) |char, x| {
            if (char == '#') {
                try positions_list.append(Position{ .x = @intCast(x), .y = @intCast(y) });
            }
        }
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

    const output = try day11_1(input);
    try std.testing.expectEqual(@as(u32, 374), output);
}

test "input 1" {
    const input = @embedFile("./input11");
    const output = try day11_1(input);
    try std.testing.expectEqual(@as(u32, 10292708), output);
}
