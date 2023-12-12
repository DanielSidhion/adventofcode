const std = @import("std");

pub fn day09_1(input: []const u8) !i32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var result: i32 = 0;

    while (lines.next()) |report_line| {
        if (report_line.len == 0) {
            continue;
        }

        var report_nums = std.mem.splitScalar(u8, report_line, ' ');
        var prediction_table = std.ArrayList(std.ArrayList(i32)).init(arena.allocator());
        var actual_nums = std.ArrayList(i32).init(arena.allocator());

        while (report_nums.next()) |num| {
            const num_parsed = try std.fmt.parseInt(i32, num, 10);
            try actual_nums.append(num_parsed);
        }

        try prediction_table.append(actual_nums);

        var last_differences = actual_nums;
        while (true) {
            if (std.mem.allEqual(i32, last_differences.items, 0)) {
                break;
            }

            var next_differences = std.ArrayList(i32).init(arena.allocator());
            var pairs = std.mem.window(i32, last_differences.items, 2, 1);

            while (pairs.next()) |slice| {
                try next_differences.append(slice[1] - slice[0]);
            }

            try prediction_table.append(next_differences);
            last_differences = next_differences;
        }

        var next_num: i32 = 0;
        for (prediction_table.items) |row| {
            next_num += row.items[row.items.len - 1];
        }
        result += next_num;
    }

    return result;
}

test "example 1" {
    const input =
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
        \\
    ;

    const output = try day09_1(input);
    try std.testing.expectEqual(@as(i32, 114), output);
}

test "input 1" {
    const input = @embedFile("./input09");
    const output = try day09_1(input);
    try std.testing.expectEqual(@as(i32, 2043677056), output);
}
