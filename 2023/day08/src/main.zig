const std = @import("std");

const Node = struct {
    left: []const u8,
    right: []const u8,
};

pub fn day08_1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var node_map = std.StringHashMap(Node).init(arena.allocator());

    var lines = std.mem.splitScalar(u8, input, '\n');
    const movement = lines.next().?;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var parts = std.mem.splitAny(u8, line, "=(,)");
        const curr_node_str = std.mem.trim(u8, parts.next().?, " ");
        _ = parts.next();
        const left_str = parts.next().?;
        const right_str = std.mem.trim(u8, parts.next().?, " ");

        var curr_node = try node_map.getOrPut(curr_node_str);
        curr_node.value_ptr.left = left_str;
        curr_node.value_ptr.right = right_str;
    }

    var steps: u32 = 0;
    var curr_direction_index: usize = 0;
    var curr_node_str: []const u8 = "AAA";

    while (true) : ({
        steps += 1;
        curr_direction_index = (curr_direction_index + 1) % movement.len;
    }) {
        if (std.mem.eql(u8, curr_node_str, "ZZZ")) {
            break;
        }

        const curr_node = node_map.get(curr_node_str).?;
        curr_node_str = if (movement[curr_direction_index] == 'L') curr_node.left else curr_node.right;
    }

    return steps;
}

test "example 1" {
    const input =
        \\RL
        \\
        \\AAA = (BBB, CCC)
        \\BBB = (DDD, EEE)
        \\CCC = (ZZZ, GGG)
        \\DDD = (DDD, DDD)
        \\EEE = (EEE, EEE)
        \\GGG = (GGG, GGG)
        \\ZZZ = (ZZZ, ZZZ)
        \\
    ;

    const output = try day08_1(input);
    try std.testing.expectEqual(@as(u32, 2), output);
}

test "example 2" {
    const input =
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
        \\
    ;

    const output = try day08_1(input);
    try std.testing.expectEqual(@as(u32, 6), output);
}

test "input 1" {
    const input = @embedFile("./input08");
    const output = try day08_1(input);
    try std.testing.expectEqual(@as(u32, 12361), output);
}
