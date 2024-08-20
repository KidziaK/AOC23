const std = @import("std");
const print = std.debug.print;

const Config = struct {
    directions: []const u8,
    nodes: []const [3][3]u8
};

const err = error.MaxIterationExceed;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {}; 
    const alloc = gpa.allocator();

    const file_contents = try std.fs.cwd().readFileAlloc(alloc, "08_input.json", 1000000);
    const parsed_config = try std.json.parseFromSlice(Config, alloc, file_contents, .{.allocate = .alloc_always});
    const config = parsed_config.value;

    var nodes = std.AutoHashMap([3]u8, [2][3]u8).init(alloc);
    defer nodes.deinit();

    const VoidValue = struct {};
    var nodes_ending_with_A = std.AutoHashMap([3]u8, VoidValue).init(alloc);
    defer nodes_ending_with_A.deinit();

    for (config.nodes) |node| {
        if (node[0][2] == 'A') try nodes_ending_with_A.put(node[0], VoidValue{});
        const lr: [2][3]u8 = node[1..3].*;
        try nodes.put(node[0], lr);
    }

    var all_steps = std.ArrayList(u64).init(alloc);
    defer all_steps.deinit();

    var it = nodes_ending_with_A.keyIterator();
    while (it.next()) |key| {
        var current_direction = config.directions[0];
        var step: u64 = 0;
        var current_node = key.*;

        while (true) {
            step += 1;
            if (current_direction == 'L') current_node = nodes.get(current_node).?[0];
            if (current_direction == 'R') current_node = nodes.get(current_node).?[1];
            if (current_node[2] == 'Z') break;
            current_direction = config.directions[step % config.directions.len];
        }

        try all_steps.append(step);
    }

    var lcm: u64 = 1;

    for (all_steps.items) |i| {
        lcm = lcm * i / std.math.gcd(lcm, i);
    }

    print("solution = {}\n", .{lcm});
}