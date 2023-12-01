const std = @import("std");

pub fn day01_1(input: []const u8) !u64 {
    var result: u64 = 0;
    var curr_value: [2]u8 = "xx".*;

    for (input) |curr_char| {
        if (curr_char == '\n') {
            if (curr_value[1] == 'x') {
                curr_value[1] = curr_value[0];
            }
            result += try std.fmt.parseInt(u64, &curr_value, 10);
            curr_value = "xx".*;
            continue;
        }

        if (curr_char >= '0' and curr_char <= '9') {
            switch (curr_value[0]) {
                'x' => {
                    curr_value[0] = curr_char;
                },
                else => {
                    curr_value[1] = curr_char;
                },
            }
        }
    }

    return result;
}

fn starts_with(input: []const u8, text: []const u8) bool {
    return std.mem.eql(u8, input[0..@min(text.len, input.len)], text);
}

pub fn day01_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var parsed_input = std.ArrayList(u8).init(arena.allocator());

    const KV = struct { []const u8, u8 };
    const replacements = [_]KV{
        .{ "one", '1' },
        .{ "two", '2' },
        .{ "three", '3' },
        .{ "four", '4' },
        .{ "five", '5' },
        .{ "six", '6' },
        .{ "seven", '7' },
        .{ "eight", '8' },
        .{ "nine", '9' },
    };

    var curr_index: usize = 0;
    input_parsing: while (curr_index < input.len) : (curr_index += 1) {
        for (replacements) |repl| {
            if (starts_with(input[curr_index..], repl[0])) {
                try parsed_input.append(repl[1]);
                continue :input_parsing;
            }
        }

        try parsed_input.append(input[curr_index]);
    }

    return day01_1(parsed_input.items);
}

test "example 1" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
        \\
    ;

    const output = try day01_1(input);
    try std.testing.expectEqual(output, 142);
}

test "input 1" {
    const input = @embedFile("./input01");
    const output = try day01_1(input);
    try std.testing.expectEqual(output, 55621);
}

test "example 2" {
    const input =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
        \\
    ;

    const output = try day01_2(input);
    try std.testing.expectEqual(output, 281);
}

test "input 2" {
    const input = @embedFile("./input01");
    const output = try day01_2(input);
    try std.testing.expectEqual(output, 53592);
}
