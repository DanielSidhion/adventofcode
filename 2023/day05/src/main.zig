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

const Range = struct { start: u64, end: u64 };

pub fn day05_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var current_map = std.ArrayList(Range).init(arena.allocator());

    var lines = std.mem.splitScalar(u8, input, '\n');
    const seeds_line = lines.next().?;
    var seed_parts = std.mem.splitScalar(u8, seeds_line["seeds: ".len..], ' ');

    while (seed_parts.next()) |start| {
        const start_num = try std.fmt.parseInt(u64, start, 10);
        const len = try std.fmt.parseInt(u64, seed_parts.next().?, 10);
        var new_range = try current_map.addOne();
        new_range.start = start_num;
        // Note that the range is all-inclusive now.
        new_range.end = start_num + len - 1;
    }

    var next_map = std.ArrayList(Range).init(arena.allocator());

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        if (std.mem.indexOf(u8, line, "map:") != null) {
            // We're about to read another map, so move the map we have to the previous one.

            // If there were any unmapped ranges, they are mapped 1:1, so we just add those ranges into `next_map` before flipping.
            for (current_map.items) |current_range| {
                try next_map.append(current_range);
            }

            current_map.deinit();
            current_map = next_map;
            next_map = std.ArrayList(Range).init(arena.allocator());
            continue;
        }

        var parts = std.mem.splitScalar(u8, line, ' ');
        const dest_start = try std.fmt.parseInt(u64, parts.next().?, 10);
        const source_start = try std.fmt.parseInt(u64, parts.next().?, 10);
        const len = try std.fmt.parseInt(u64, parts.next().?, 10);
        const source_end = source_start + len - 1;
        const dest_end = dest_start + len - 1;

        var i: isize = 0;
        while (i < current_map.items.len) : (i += 1) {
            var curr_range = &current_map.items[@intCast(i)];

            if (curr_range.end < source_start or curr_range.start > source_end) {
                continue;
            }

            // For sure the curr_range overlaps with the map, so we'll always add at least one new range in the next map.
            var new_range = try next_map.addOne();

            if (curr_range.start >= source_start) {
                // No need to break the beginning of the range.
                if (curr_range.end <= source_end) {
                    // No need to break the end of the range either, so just add the current range completely mapped.
                    new_range.start = dest_start + curr_range.start - source_start;
                    new_range.end = new_range.start + (curr_range.end - curr_range.start);
                    _ = current_map.orderedRemove(@intCast(i));
                    i -= 1;
                } else {
                    // Must break the end of the range.
                    new_range.start = dest_start + curr_range.start - source_start;
                    new_range.end = dest_end;
                    curr_range.start = source_end + 1;
                }
            } else {
                // Need to break the beginning of the range.
                if (curr_range.end <= source_end) {
                    // No need to break the end of the range.
                    new_range.start = dest_start;
                    new_range.end = new_range.start + (curr_range.end - curr_range.start) - (source_start - curr_range.start); // We're not mapping the whole curr_range, only the items that fall within the source range, so we need to remove the amount of items that don't fall within the source range from the len of curr_range.
                    curr_range.end = source_start - 1;
                } else {
                    // Must break the end of the range as well.
                    new_range.start = dest_start;
                    new_range.end = dest_end;

                    const end_of_extra_range = curr_range.end;
                    // For the bit remaining before the source range.
                    curr_range.end = source_start - 1;

                    // For the bit remaining after the source range. After we add one to `current_map`, the `curr_range` pointer might be invalid, so that's why we saved the value we needed to use before.
                    var extra_curr_range = try current_map.addOne();
                    extra_curr_range.start = source_end + 1;
                    extra_curr_range.end = end_of_extra_range;
                }
            }
        }
    }

    var smallest_location: u64 = 0;
    smallest_location = ~smallest_location;

    // Must check both current map and next map because at the end we don't merge both maps to flip to a new one (because there won't be a new one).
    for (current_map.items) |range| {
        if (range.start < smallest_location) {
            smallest_location = range.start;
        }
    }

    for (next_map.items) |range| {
        if (range.start < smallest_location) {
            smallest_location = range.start;
        }
    }

    return smallest_location;
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

test "example 2" {
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

    const output = try day05_2(input);
    try std.testing.expectEqual(@as(u64, 46), output);
}

test "input 2" {
    const input = @embedFile("./input05");
    const output = try day05_2(input);
    try std.testing.expectEqual(@as(u64, 11611182), output);
}
