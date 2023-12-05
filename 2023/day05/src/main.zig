const std = @import("std");

pub fn day05_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var current_map = std.ArrayList(u64).init(arena.allocator());

    var lines = std.mem.splitScalar(u8, input, '\n');
    const seeds_line = lines.next().?;
    var seeds = std.mem.splitScalar(u8, seeds_line["seeds: ".len..], ' ');

    while (seeds.next()) |seed| {
        const seed_num = try std.fmt.parseInt(u64, seed, 10);
        try current_map.append(seed_num);
    }

    var next_map = try current_map.clone();

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        if (std.mem.indexOf(u8, line, "map:") != null) {
            // We're about to read another map, so move the map we have to the previous one.
            std.mem.copyForwards(u64, current_map.items, next_map.items);
            continue;
        }

        var parts = std.mem.splitScalar(u8, line, ' ');
        const dest_start = try std.fmt.parseInt(u64, parts.next().?, 10);
        const source_start = try std.fmt.parseInt(u64, parts.next().?, 10);
        const len = try std.fmt.parseInt(u64, parts.next().?, 10);

        for (current_map.items, 0..) |curr_num, i| {
            if (curr_num >= source_start and curr_num < source_start + len) {
                // Falls within the range, so we map it.
                next_map.items[i] = dest_start + (curr_num - source_start);
            }
        }
    }

    // Result will be in `next_map` because we haven't done the last `copyForwards()` call.
    return std.mem.min(u64, next_map.items);
}

test "example 1" {
    const input =
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
        \\
    ;

    const output = try day05_1(input);
    try std.testing.expectEqual(@as(u64, 35), output);
}

test "input 1" {
    const input = @embedFile("./input05");
    const output = try day05_1(input);
    try std.testing.expectEqual(@as(u64, 173706076), output);
}
