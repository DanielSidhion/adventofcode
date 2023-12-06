const std = @import("std");

pub fn day06_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var time_list = std.ArrayList(u64).init(arena.allocator());
    var distance_list = std.ArrayList(u64).init(arena.allocator());

    var lines = std.mem.splitScalar(u8, input, '\n');
    var times_line = lines.next().?;
    var times = std.mem.splitScalar(u8, times_line["Time:".len..], ' ');
    var distances_line = lines.next().?;
    var distances = std.mem.splitScalar(u8, distances_line["Distance:".len..], ' ');

    while (times.next()) |time| {
        if (time.len == 0) {
            continue;
        }

        const time_num = try std.fmt.parseInt(u64, time, 10);
        try time_list.append(time_num);
    }

    while (distances.next()) |distance| {
        if (distance.len == 0) {
            continue;
        }

        const distance_num = try std.fmt.parseInt(u64, distance, 10);
        try distance_list.append(distance_num);
    }

    return waysToBeatMultiplied(time_list.items, distance_list.items);
}

fn waysToBeatMultiplied(times: []const u64, distances: []const u64) u64 {
    var result: u64 = 1;

    for (times, distances) |time, distance| {
        var ways_to_beat: u64 = 0;

        for (1..time) |button_time| {
            const travelled_distance = button_time * (time - button_time);
            if (travelled_distance > distance) {
                ways_to_beat += 1;
            }
        }

        result *= ways_to_beat;
    }

    return result;
}

pub fn day06_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    var times_line = lines.next().?["Time:".len..];
    var distances_line = lines.next().?["Distance:".len..];

    var time_size = std.mem.replacementSize(u8, times_line, " ", &[_]u8{});
    var time = try arena.allocator().alloc(u8, time_size);
    _ = std.mem.replace(u8, times_line, " ", &[_]u8{}, time);
    const time_num = try std.fmt.parseInt(u64, time, 10);

    var distance_size = std.mem.replacementSize(u8, distances_line, " ", &[_]u8{});
    var distance = try arena.allocator().alloc(u8, distance_size);
    _ = std.mem.replace(u8, distances_line, " ", &[_]u8{}, distance);
    const distance_num = try std.fmt.parseInt(u64, distance, 10);

    return waysToBeatMultiplied(&[_]u64{time_num}, &[_]u64{distance_num});
}

test "example 1" {
    const input =
        \\Time:      7  15   30
        \\Distance:  9  40  200
        \\
    ;

    const output = try day06_1(input);
    try std.testing.expectEqual(@as(u64, 288), output);
}

test "input 1" {
    const input = @embedFile("./input06");
    const output = try day06_1(input);
    try std.testing.expectEqual(@as(u64, 32076), output);
}

test "example 2" {
    const input =
        \\Time:      7  15   30
        \\Distance:  9  40  200
        \\
    ;

    const output = try day06_2(input);
    try std.testing.expectEqual(@as(u64, 71503), output);
}

test "input 2" {
    const input = @embedFile("./input06");
    const output = try day06_2(input);
    try std.testing.expectEqual(@as(u64, 34278221), output);
}
