const std = @import("std");

pub fn day04_1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var result: u32 = 0;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var parts = std.mem.splitAny(u8, line, ":|");
        // Ignored because it's just the id of the card.
        _ = parts.next();

        const winning_numbers_line = std.mem.trim(u8, parts.next().?, " ");
        const scratch_numbers_line = std.mem.trim(u8, parts.next().?, " ");

        var winning_numbers = std.mem.split(u8, winning_numbers_line, " ");
        var winning_numbers_set = std.AutoHashMap(u32, void).init(arena.allocator());

        while (winning_numbers.next()) |num| {
            if (num.len == 0) {
                continue;
            }

            const parsed_num = try std.fmt.parseInt(u8, num, 10);
            try winning_numbers_set.put(parsed_num, {});
        }

        var scratch_numbers = std.mem.split(u8, scratch_numbers_line, " ");
        var numbers_won: u32 = 0;

        while (scratch_numbers.next()) |num| {
            if (num.len == 0) {
                continue;
            }

            const parsed_num = try std.fmt.parseInt(u8, num, 10);
            if (winning_numbers_set.contains(parsed_num)) {
                numbers_won += 1;
            }
        }

        if (numbers_won > 0) {
            result += std.math.pow(u32, 2, numbers_won - 1);
        }
        winning_numbers_set.deinit();
    }

    return result;
}

test "example 1" {
    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        \\
    ;

    const output = try day04_1(input);
    try std.testing.expectEqual(@as(u32, 13), output);
}

test "input 1" {
    const input = @embedFile("./input04");
    const output = try day04_1(input);
    try std.testing.expectEqual(@as(u32, 21558), output);
}
