// Note: for this day I decided to just adapt the code I used to solve part 1 and use the same core code to solve both parts. If you want to see the code I created exclusively for part 1 (while I was solving it), check the commit history.

const std = @import("std");

pub fn day12_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var result: u64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var parts = std.mem.splitScalar(u8, line, ' ');
        const springs = parts.next().?;

        var spring_list = std.ArrayList(u8).init(arena.allocator());
        try spring_list.appendSlice(springs);

        var groups = std.mem.splitScalar(u8, parts.next().?, ',');
        var group_list = std.ArrayList(u8).init(arena.allocator());
        while (groups.next()) |group| {
            const group_num = try std.fmt.parseInt(u8, group, 10);
            try group_list.append(group_num);
        }

        const possibilities = try countPossibilities(spring_list.items, group_list.items, arena.allocator());
        result += possibilities;

        spring_list.deinit();
        group_list.deinit();
    }

    return result;
}

const ComputedPossibility = struct { remaining_springs: usize, remaining_groups: usize };

fn countPossibilities(springs: []u8, groups: []u8, allocator: std.mem.Allocator) !u64 {
    var possibilities_map = std.AutoHashMap(ComputedPossibility, ?u64).init(allocator);
    defer possibilities_map.deinit();

    const possibilities = try countPossibilitiesInner(springs, groups, &possibilities_map);
    return possibilities.?;
}

fn allSpringsClear(springs: []u8) bool {
    for (springs) |spring| {
        if (spring == '#') {
            return false;
        }
    }

    // Either '?' or '.'.
    return true;
}

fn continuousBrokenSprings(springs: []u8) bool {
    for (springs) |spring| {
        if (spring == '.') {
            return false;
        }
    }

    // Either '?' or '#'.
    return true;
}

fn countPossibilitiesInner(springs: []u8, groups: []u8, possibilities_map: *std.AutoHashMap(ComputedPossibility, ?u64)) !?u64 {
    // std.debug.print("Springs is {s}, groups is ", .{springs});
    // for (groups) |grp| {
    //     std.debug.print("{d},", .{grp});
    // }
    // std.debug.print("\n", .{});
    const computed_possibility = ComputedPossibility{ .remaining_springs = springs.len, .remaining_groups = groups.len };

    if (possibilities_map.get(computed_possibility)) |possibilities| {
        // if (possibilities != null) {
        //     std.debug.print("  found computed: {d}\n", .{possibilities.?});
        // } else {
        //     std.debug.print("  found computed: null\n", .{});
        // }
        return possibilities;
    }

    if (groups.len == 0) {
        if (springs.len == 0 or allSpringsClear(springs)) {
            // std.debug.print("  all remaining springs clear, saving 1 possibility.\n", .{});
            try possibilities_map.put(computed_possibility, 1);
            return 1;
        } else {
            // No groups remain, but we still have springs to match, which is impossible.
            // std.debug.print("  no groups remain, but still have spring groups, saving null.\n", .{});
            try possibilities_map.put(computed_possibility, null);
            return null;
        }
    } else {
        if (springs.len == 0) {
            // No springs remain, but we still have springs to match, which is impossible.
            // std.debug.print("  there are still groups remaining, but no more springs, saving null.\n", .{});
            try possibilities_map.put(computed_possibility, null);
            return null;
        }
    }

    if (springs[0] == '.') {
        // std.debug.print("  skipping clear spring.\n", .{});
        return countPossibilitiesInner(springs[1..], groups, possibilities_map);
    } else if (springs[0] == '#') {
        const group_len = groups[0];

        // Try to find a group of len `group_len`.
        if (springs.len >= group_len and continuousBrokenSprings(springs[0..group_len])) {
            if (springs.len > group_len and springs[group_len] == '#') {
                // std.debug.print("  can't get group of {d} broken springs because group would be larger, saving null.\n", .{group_len});
                // Very next character is a broken spring, which will increase the size of the group. Both `springs[0]` and `springs[group_len]` are '#', so there's no way there can be a continuous group of '#' of len `group_len`.
                try possibilities_map.put(computed_possibility, null);
                return null;
            } else if (springs.len > group_len) {
                // If we're here, means `springs[group_len]` == '.' or `springs[group_len]` == '?'. These MUST be clear springs, so we'll skip them directly here, otherwise we might match `springs[group_len]` to a group of len 1 later, which is wrong.
                // std.debug.print("  can get group of {d} broken springs, continuing and skipping next char.\n", .{group_len});
                return countPossibilitiesInner(springs[group_len + 1 ..], groups[1..], possibilities_map);
            } else {
                // If we're here, means `springs.len == group_len`, in which case there won't be any more springs to check. We'll just continue so we can save the results.
                return countPossibilitiesInner(springs[group_len..], groups[1..], possibilities_map);
            }
        } else {
            // std.debug.print("  can't get group of {d} broken springs because not enough continuous springs, saving null.\n", .{group_len});
            try possibilities_map.put(computed_possibility, null);
            return null;
        }
    } else {
        // std.debug.print("  found ?, recursing.\n", .{});
        // `springs[0]` is '?', so we gotta test both '.' and '#' now. We'll start testing '.', which means we just skip it.
        var possibilities: u64 = (try countPossibilitiesInner(springs[1..], groups, possibilities_map)) orelse 0;

        // We'll do a similar test as '#' here now. The reason we do this here is so we can save the computed possibility with the correct values.
        const group_len = groups[0];
        if (springs.len >= group_len and continuousBrokenSprings(springs[0..group_len])) {
            if (springs.len == group_len) {
                // std.debug.print(" we managed to match a spring group of len {d}, continuing.\n", .{group_len});
                possibilities += (try countPossibilitiesInner(springs[group_len..], groups[1..], possibilities_map)) orelse 0;
            } else if (springs[group_len] == '.' or springs[group_len] == '?') {
                // std.debug.print(" we managed to match a spring group of len {d}, continuing and skipping next char.\n", .{group_len});
                // The very next character has to be a clear spring, so we'll skip it here. If the next character is '?' and we don't skip it here, we might match it to a group of len 1, which is wrong (because we just got a group of broken springs too).
                possibilities += (try countPossibilitiesInner(springs[group_len + 1 ..], groups[1..], possibilities_map)) orelse 0;
            }
        }

        try possibilities_map.put(computed_possibility, possibilities);
        return possibilities;
    }
}

pub fn day12_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var result: u64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var parts = std.mem.splitScalar(u8, line, ' ');
        const springs = parts.next().?;

        var spring_list = std.ArrayList(u8).init(arena.allocator());
        try spring_list.appendSlice(springs);
        try spring_list.append('?');
        try spring_list.appendSlice(springs);
        try spring_list.append('?');
        try spring_list.appendSlice(springs);
        try spring_list.append('?');
        try spring_list.appendSlice(springs);
        try spring_list.append('?');
        try spring_list.appendSlice(springs);

        var groups = std.mem.splitScalar(u8, parts.next().?, ',');
        var group_list = std.ArrayList(u8).init(arena.allocator());
        while (groups.next()) |group| {
            const group_num = try std.fmt.parseInt(u8, group, 10);
            try group_list.append(group_num);
        }

        const initial_len = group_list.items.len;
        try group_list.resize(initial_len * 5);
        for (initial_len..group_list.items.len) |i| {
            group_list.items[i] = group_list.items[i % initial_len];
        }

        const possibilities = try countPossibilities(spring_list.items, group_list.items, arena.allocator());
        result += possibilities;

        spring_list.deinit();
        group_list.deinit();
    }

    return result;
}

test "example 1" {
    const input =
        \\???.### 1,1,3
        \\.??..??...?##. 1,1,3
        \\?#?#?#?#?#?#?#? 1,3,1,6
        \\????.#...#... 4,1,1
        \\????.######..#####. 1,6,5
        \\?###???????? 3,2,1
        \\
    ;

    const output = try day12_1(input);
    try std.testing.expectEqual(@as(u64, 21), output);
}

test "input 1" {
    const input = @embedFile("./input12");
    const output = try day12_1(input);
    try std.testing.expectEqual(@as(u64, 7622), output);
}

test "example 2" {
    const input =
        \\???.### 1,1,3
        \\.??..??...?##. 1,1,3
        \\?#?#?#?#?#?#?#? 1,3,1,6
        \\????.#...#... 4,1,1
        \\????.######..#####. 1,6,5
        \\?###???????? 3,2,1
        \\
    ;

    const output = try day12_2(input);
    try std.testing.expectEqual(@as(u64, 525152), output);
}

test "input 2" {
    const input = @embedFile("./input12");
    const output = try day12_2(input);
    try std.testing.expectEqual(@as(u64, 4964259839627), output);
}
