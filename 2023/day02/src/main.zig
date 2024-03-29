const std = @import("std");

const Amounts = struct {
    red: u64,
    green: u64,
    blue: u64,

    fn new() Amounts {
        return Amounts{ .red = 0, .green = 0, .blue = 0 };
    }

    fn combineMaximum(self: *Amounts, other: *const Amounts) void {
        self.red = @max(self.red, other.red);
        self.green = @max(self.green, other.green);
        self.blue = @max(self.blue, other.blue);
    }

    fn isPossible(self: *const Amounts) bool {
        return self.red <= 12 and self.green <= 13 and self.blue <= 14;
    }

    fn power(self: *const Amounts) u64 {
        return self.red * self.green * self.blue;
    }
};

fn parseSetAmounts(text: []const u8) !Amounts {
    var cubes = std.mem.splitSequence(u8, text, ", ");

    var amounts = Amounts.new();

    while (cubes.next()) |bunch| {
        var cube_parts = std.mem.splitScalar(u8, bunch, ' ');
        const amount = try std.fmt.parseInt(u8, cube_parts.next().?, 10);
        const color = cube_parts.next().?;

        switch (color[0]) {
            'r' => amounts.red = amount,
            'g' => amounts.green = amount,
            'b' => amounts.blue = amount,
            else => unreachable,
        }
    }

    return amounts;
}

pub fn day02_1(input: []const u8) !u32 {
    var result: u32 = 0;

    var games = std.mem.splitScalar(u8, input, '\n');
    while (games.next()) |game| {
        if (game.len == 0) {
            break;
        }

        var sets = std.mem.splitAny(u8, game, ";:");
        var game_part = sets.next().?["Game ".len..];
        var game_id = try std.fmt.parseInt(u32, game_part, 10);

        var is_game_possible = true;

        while (sets.next()) |set| {
            const amounts = try parseSetAmounts(std.mem.trim(u8, set, " "));
            if (!amounts.isPossible()) {
                is_game_possible = false;
            }
        }

        if (is_game_possible) {
            result += game_id;
        }
    }

    return result;
}

pub fn day02_2(input: []const u8) !u64 {
    var result: u64 = 0;

    var games = std.mem.splitScalar(u8, input, '\n');
    while (games.next()) |game| {
        if (game.len == 0) {
            break;
        }

        var sets = std.mem.splitAny(u8, game, ";:");
        _ = sets.next();

        var maximum_amounts = Amounts.new();

        while (sets.next()) |set| {
            const amounts = try parseSetAmounts(std.mem.trim(u8, set, " "));
            maximum_amounts.combineMaximum(&amounts);
        }

        result += maximum_amounts.power();
    }

    return result;
}

test "example 1" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        \\
    ;

    const output = try day02_1(input);
    try std.testing.expectEqual(@as(u32, 8), output);
}

test "input 1" {
    const input = @embedFile("./input02");
    const output = try day02_1(input);
    try std.testing.expectEqual(@as(u32, 3099), output);
}

test "example 2" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        \\
    ;

    const output = try day02_2(input);
    try std.testing.expectEqual(@as(u64, 2286), output);
}

test "input 2" {
    const input = @embedFile("./input02");
    const output = try day02_2(input);
    try std.testing.expectEqual(@as(u64, 72970), output);
}
