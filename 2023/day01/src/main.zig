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

test "example" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
        \\
    ;

    const output = day01_1(input);
    try std.testing.expectEqual(output, 142);
}

test "input 1" {
    const input = @embedFile("./input01");
    const output = day01_1(input);
    try std.testing.expectEqual(output, 55621);
}
