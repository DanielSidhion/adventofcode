const std = @import("std");

const Node = struct {
    left: []const u8,
    right: []const u8,
};

pub fn day08_1(input: []const u8) !u64 {
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

    var steps: u64 = 0;
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

pub fn day08_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var node_map = std.StringHashMap(Node).init(arena.allocator());
    var curr_positions = std.ArrayList([]const u8).init(arena.allocator());

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

        if (std.mem.endsWith(u8, curr_node_str, "A")) {
            try curr_positions.append(curr_node_str);
        }
    }

    // This is a bit of a hack based on the inputs and examples. For every starting position, eventually we'll reach a location that ends with Z, and from that location we'll always loop back to it. Additionally, the number of steps to reach the --Z location from the starting position is the same number of steps to loop from --Z back to --Z again.
    // Based on this observation, the code below calculates how many steps it takes to reach a --Z location for each starting position individually. After that, it calculates the least common multiple between all the number of steps we have, because we'll always keep looping between those --Z locations.

    var steps_per_position = try std.ArrayList(u64).initCapacity(arena.allocator(), curr_positions.items.len);
    steps_per_position.expandToCapacity();

    for (0..curr_positions.items.len) |i| {
        var steps: u64 = 0;
        var curr_direction_index: usize = 0;
        while (true) : ({
            steps += 1;
            curr_direction_index = (curr_direction_index + 1) % movement.len;
        }) {
            if (std.mem.endsWith(u8, curr_positions.items[i], "Z")) {
                break;
            }

            const node = node_map.get(curr_positions.items[i]).?;
            curr_positions.items[i] = if (movement[curr_direction_index] == 'L') node.left else node.right;
        }

        steps_per_position.items[i] = steps;
    }

    if (steps_per_position.items.len == 1) {
        return steps_per_position.items[0];
    }

    var result: u64 = lcm(steps_per_position.items[0], steps_per_position.items[1]);

    var i: usize = 2;
    while (i < steps_per_position.items.len) : (i += 1) {
        result = lcm(result, steps_per_position.items[i]);
    }

    return result;
}

fn gcd(a: u64, b: u64) u64 {
    // Zig treats function parameters as constants, so we need the code below.
    var a_ = a;
    var b_ = b;

    while (b_ > 0) {
        var tmp = b_;
        b_ = a_ % b_;
        a_ = tmp;
    }

    return a_;
}

fn lcm(a: u64, b: u64) u64 {
    return a * b / gcd(a, b);
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
    try std.testing.expectEqual(@as(u64, 2), output);
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
    try std.testing.expectEqual(@as(u64, 6), output);
}

test "input 1" {
    const input = @embedFile("./input08");
    const output = try day08_1(input);
    try std.testing.expectEqual(@as(u64, 12361), output);
}

test "example 3" {
    const input =
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)
        \\
    ;

    const output = try day08_2(input);
    try std.testing.expectEqual(@as(u64, 6), output);
}

test "input 2" {
    const input = @embedFile("./input08");
    const output = try day08_2(input);
    try std.testing.expectEqual(@as(u64, 18215611419223), output);
}
