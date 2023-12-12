const std = @import("std");

pub fn day12_1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var result: u32 = 0;

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

        const possibilities = countPossibilities(&spring_list.items, group_list.items);
        result += possibilities;
    }

    return result;
}

fn countPossibilities(springs: *[]u8, groups: []u8) u32 {
    return countPossibilitiesInner(springs, groups, 0, 0);
}

fn countPossibilitiesInner(springs: *[]u8, groups: []u8, pos: usize, current_possibilities: u32) u32 {
    if (pos == springs.len) {
        if (isPossible(springs.*, groups)) {
            return current_possibilities + 1;
        } else {
            return 0;
        }
    }

    if (springs.*[pos] == '?') {
        springs.*[pos] = '.';
        const possibilities_empty = countPossibilitiesInner(springs, groups, pos + 1, current_possibilities);
        springs.*[pos] = '#';
        const possibilities_spring = countPossibilitiesInner(springs, groups, pos + 1, current_possibilities);
        springs.*[pos] = '?';

        return possibilities_empty + possibilities_spring;
    } else {
        return countPossibilitiesInner(springs, groups, pos + 1, current_possibilities);
    }
}

fn isPossible(springs: []u8, groups: []u8) bool {
    var spring_groups = std.mem.splitScalar(u8, springs, '.');

    var current_group_index: usize = 0;
    while (spring_groups.next()) |spring_group| {
        if (spring_group.len == 0) {
            continue;
        }

        if (current_group_index >= groups.len) {
            return false;
        }

        if (spring_group.len != groups[current_group_index]) {
            return false;
        }

        current_group_index += 1;
    }

    return current_group_index == groups.len;
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
    try std.testing.expectEqual(@as(u32, 21), output);
}

test "input 1" {
    const input = @embedFile("./input12");
    const output = try day12_1(input);
    try std.testing.expectEqual(@as(u32, 7622), output);
}
