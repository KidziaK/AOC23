const std = @import("std");
const json = std.json;
const print = std.debug.print;
const fs = std.fs;
const heap = std.heap;

const Config = struct {
    time: []const u64,
    distance: []const u64
};

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}) {};
    const alloc = gpa.allocator();

    const contents = try fs.cwd().readFileAlloc(alloc, "06_input_2star.json", 1000000);
    defer alloc.free(contents);

    const config = try json.parseFromSlice(Config, alloc, contents, .{ .allocate = .alloc_always });
    defer config.deinit();

    const num_races = config.value.time.len;
    const time = config.value.time;
    const distance = config.value.distance;

    var product: u64 = 1;

    for (0..num_races) |i| {
        const T: f64 = @floatFromInt(time[i]);
        const D: f64 = @floatFromInt(distance[i]);

        const sum_sq = T * T - 4 * D;
        const sqrt = std.math.sqrt(sum_sq);

        const t1: f64 = std.math.ceil((T - sqrt) / 2 + 0.0001);
        const t2: f64 = std.math.floor((T + sqrt) / 2 - 0.0001); 

        const range: u64 = @intFromFloat(1 + @min(t2, T) - @max(t1, 0.0));
        product *= range;
    }

    print("{}\n", .{product});
}