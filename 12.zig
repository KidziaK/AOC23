const std = @import("std");
const print = std.debug.print;

const State = struct {
    cfg: []const u8,
    nums: []const u8,
};

const StateContext = struct {
    pub fn hash(ctx: StateContext, key: State) u32 {
        _ = ctx;
        var h = std.hash.Adler32.init();
        h.update(key.cfg);
        h.update(key.nums);
        return h.final();
    }

    pub fn eql(ctx: StateContext, a: State, b: State, _: usize) bool {
        _ = ctx;
        return (std.mem.eql(u8, a.cfg, b.cfg) and std.mem.eql(u8, a.nums, b.nums));
    }
};

const Counter = struct {
    cache: std.ArrayHashMap(State, usize, StateContext, true),

    pub fn init(alloc: std.mem.Allocator) Counter {
        return Counter {.cache = std.ArrayHashMap(State, usize, StateContext, true).init(alloc)};
    }

    pub fn deinit(self: *Counter) void {
        self.cache.deinit();
    }

    pub fn count(self: *Counter, configuration: []const u8, nums: []const usize) !usize {
        const usize_size = @sizeOf(usize);
        const u8_slice = nums[0..];

        // Cast the slice of usize to a slice of u8
        const p_u8: [*]u8 = @ptrCast(@constCast(u8_slice.ptr));
        const nums_as_u8 = p_u8[0..nums.len * usize_size];

        const state = State {.cfg = configuration, .nums = nums_as_u8};
        const cached_result = self.cache.get(state);

        if (cached_result != null) {
            return cached_result.?;
        } 

        if (configuration.len == 0){
            return if (nums.len == 0) 1 else 0;
        }

        if (nums.len == 0) {
            return if (std.mem.containsAtLeast(u8, configuration, 1, "#")) 0 else 1;
        }

        var result: usize = 0;

        if (configuration[0] == '.' or configuration[0] == '?') {
            if (configuration.len == 1) {
                result += try self.count(&.{}, nums);
            } else {
                result += try self.count(configuration[1..], nums);
            }   
        }

        if (configuration[0] == '#' or configuration[0] == '?') {
            if (nums[0] <= configuration.len and !std.mem.containsAtLeast(u8, configuration[0..nums[0]], 1, ".") and (nums[0] == configuration.len or configuration[nums[0]] != '#')) {
                if (nums[0] == configuration.len) {
                    result += try self.count(&.{}, nums[1..]);
                } else {
                    result += try self.count(configuration[nums[0] + 1..], nums[1..]);
                }
            }
        }

        try self.cache.put(state, result);
        return result;
    }
};

fn count(configuration: []const u8, nums: []const usize) usize {
    if (configuration.len == 0){
        return if (nums.len == 0) 1 else 0;
    }

    if (nums.len == 0) {
        return if (std.mem.containsAtLeast(u8, configuration, 1, "#")) 0 else 1;
    }

    var result: usize = 0;

    if (configuration[0] == '.' or configuration[0] == '?') {
        if (configuration.len == 1) {
            result += count(&.{}, nums);
        } else {
            result += count(configuration[1..], nums);
        }   
    }

    if (configuration[0] == '#' or configuration[0] == '?') {
        if (nums[0] <= configuration.len and !std.mem.containsAtLeast(u8, configuration[0..nums[0]], 1, ".") and (nums[0] == configuration.len or configuration[nums[0]] != '#')) {
            if (nums[0] == configuration.len) {
                result += count(&.{}, nums[1..]);
            } else {
                result += count(configuration[nums[0] + 1..], nums[1..]);
            }
        }
    }
        
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const alloc = gpa.allocator();

    const file_contents = try std.fs.cwd().readFileAlloc(alloc, "12_input.txt", std.math.maxInt(u32));
    var row_it = std.mem.splitSequence(u8, file_contents, "\n");
    var arrangments: usize = 0;

    while (row_it.next()) |row| {
        var operational_info_it = std.mem.splitSequence(u8, row, " ");
        const left_info = operational_info_it.next().?;
        const right_info = operational_info_it.next().?;

        var numbers = std.ArrayList(usize).init(alloc);
        defer numbers.deinit();

        for (0..5) |_| {
        var spring_it = std.mem.splitSequence(u8, right_info, ",");
            while (spring_it.next()) |num| {
                const usize_num: usize = try std.fmt.parseInt(usize, num, 10);
                
                try numbers.append(usize_num);
                
            }
        }

        var final_info = std.ArrayList(u8).init(alloc);
        defer final_info.deinit();

        for (left_info) |c| {
            try final_info.append(c);
        }

        for (0..4) |_| {
            try final_info.append('?');
            for (left_info) |c| {
                try final_info.append(c);
            }
        }

        var counter = Counter.init(alloc);
        defer counter.deinit();
        arrangments += try counter.count(final_info.items, numbers.items);
    }

    print("result = {}\n", .{arrangments});
}