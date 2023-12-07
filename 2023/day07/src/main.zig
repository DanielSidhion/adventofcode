const std = @import("std");

const Hand = struct { cards: [5]u8, type: u8, bid: u32 };

const card_values = std.ComptimeStringMap(u8, .{
    .{ "A", 13 },
    .{ "K", 12 },
    .{ "Q", 11 },
    .{ "J", 10 },
    .{ "T", 9 },
    .{ "9", 8 },
    .{ "8", 7 },
    .{ "7", 6 },
    .{ "6", 5 },
    .{ "5", 4 },
    .{ "4", 3 },
    .{ "3", 2 },
    .{ "2", 1 },
});

const card_values_joker = std.ComptimeStringMap(u8, .{
    .{ "A", 13 },
    .{ "K", 12 },
    .{ "Q", 11 },
    .{ "T", 10 },
    .{ "9", 9 },
    .{ "8", 8 },
    .{ "7", 7 },
    .{ "6", 6 },
    .{ "5", 5 },
    .{ "4", 4 },
    .{ "3", 3 },
    .{ "2", 2 },
    .{ "J", 1 },
});

fn handLessThanCompare(_: void, a: Hand, b: Hand) bool {
    if (a.type < b.type) {
        return true;
    }

    if (a.type > b.type) {
        return false;
    }

    const order = std.mem.order(u8, &a.cards, &b.cards);
    return order == std.math.Order.lt;
}

pub fn day07_1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var hand_list = std.ArrayList(Hand).init(arena.allocator());

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var parts = std.mem.splitScalar(u8, line, ' ');
        const hand_chars = parts.next().?;
        var new_hand = try hand_list.addOne();
        new_hand.bid = try std.fmt.parseInt(u32, parts.next().?, 10);

        var hand_card_types = std.AutoHashMap(u8, u8).init(arena.allocator());

        for (hand_chars, 0..) |char, i| {
            new_hand.cards[i] = card_values.get(&[_]u8{char}).?;
            var entry = try hand_card_types.getOrPut(char);
            entry.value_ptr.* = if (entry.found_existing) entry.value_ptr.* + 1 else 1;
        }

        switch (hand_card_types.count()) {
            5 => {
                // High card.
                new_hand.type = 0;
            },
            4 => {
                // There is one pair.
                new_hand.type = 1;
            },
            3 => {
                // Either two pairs or three of a kind.
                new_hand.type = 2;

                var counts = hand_card_types.valueIterator();
                while (counts.next()) |count| {
                    if (count.* == 3) {
                        // It's three of a kind.
                        new_hand.type = 3;
                        break;
                    }
                }
            },
            2 => {
                // Either full house or four of a kind.
                new_hand.type = 4;

                var counts = hand_card_types.valueIterator();
                while (counts.next()) |count| {
                    if (count.* == 4) {
                        // It's four of a kind.
                        new_hand.type = 5;
                        break;
                    }
                }
            },
            1 => {
                // Five of a kind.
                new_hand.type = 6;
            },
            else => unreachable,
        }
    }

    std.mem.sort(Hand, hand_list.items, {}, comptime handLessThanCompare);

    var result: u32 = 0;

    for (hand_list.items, 1..) |hand, rank| {
        result += hand.bid * @as(u32, @intCast(rank));
    }

    return result;
}

pub fn day07_2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var hand_list = std.ArrayList(Hand).init(arena.allocator());

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var parts = std.mem.splitScalar(u8, line, ' ');
        const hand_chars = parts.next().?;
        var new_hand = try hand_list.addOne();
        new_hand.bid = try std.fmt.parseInt(u32, parts.next().?, 10);

        var hand_card_types = std.AutoHashMap(u8, u8).init(arena.allocator());

        var amount_of_jokers: u8 = 0;

        for (hand_chars, 0..) |char, i| {
            new_hand.cards[i] = card_values_joker.get(&[_]u8{char}).?;

            if (char == 'J') {
                amount_of_jokers += 1;
            } else {
                var entry = try hand_card_types.getOrPut(char);
                entry.value_ptr.* = if (entry.found_existing) entry.value_ptr.* + 1 else 1;
            }
        }

        // We always add the amount of jokers to the card type with the highest count. This is guaranteed to make the hand be as strong as possible.
        var highest_value: *u8 = undefined;
        var counts = hand_card_types.valueIterator();
        if (counts.next()) |count_ptr| {
            highest_value = count_ptr;

            while (counts.next()) |curr_count_ptr| {
                if (highest_value.* < curr_count_ptr.*) {
                    highest_value = curr_count_ptr;
                }
            }

            highest_value.* += amount_of_jokers;
        }

        switch (hand_card_types.count()) {
            5 => {
                // High card.
                new_hand.type = 0;
            },
            4 => {
                // There is one pair.
                new_hand.type = 1;
            },
            3 => {
                // Either two pairs or three of a kind.
                new_hand.type = 2;

                counts = hand_card_types.valueIterator();
                while (counts.next()) |count| {
                    if (count.* == 3) {
                        // It's three of a kind.
                        new_hand.type = 3;
                        break;
                    }
                }
            },
            2 => {
                // Either full house or four of a kind.
                new_hand.type = 4;

                counts = hand_card_types.valueIterator();
                while (counts.next()) |count| {
                    if (count.* == 4) {
                        // It's four of a kind.
                        new_hand.type = 5;
                        break;
                    }
                }
            },
            1 => {
                // Five of a kind.
                new_hand.type = 6;
            },
            0 => {
                // Hand is all jokers. Five of a kind as well.
                new_hand.type = 6;
            },
            else => unreachable,
        }
    }

    std.mem.sort(Hand, hand_list.items, {}, comptime handLessThanCompare);

    var result: u32 = 0;

    for (hand_list.items, 1..) |hand, rank| {
        result += hand.bid * @as(u32, @intCast(rank));
    }

    return result;
}

test "example 1" {
    const input =
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
        \\
    ;

    const output = try day07_1(input);
    try std.testing.expectEqual(@as(u32, 6440), output);
}

test "input 1" {
    const input = @embedFile("./input07");
    const output = try day07_1(input);
    try std.testing.expectEqual(@as(u32, 250120186), output);
}

test "example 2" {
    const input =
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
        \\
    ;

    const output = try day07_2(input);
    try std.testing.expectEqual(@as(u32, 5905), output);
}

test "input 2" {
    const input = @embedFile("./input07");
    const output = try day07_2(input);
    try std.testing.expectEqual(@as(u32, 250665248), output);
}
