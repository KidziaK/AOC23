const std = @import("std");
const print = std.debug.print;

const Seed = [2]u64;
const Value = [3]u64;

const Config = struct {
    seeds: []const Seed,
    seed_to_soil: []const Value,
    soil_to_fertilizer: []const Value,
    fertilizer_to_water: []const Value,
    water_to_light: []const Value,
    light_to_temperature: []const Value,
    temperature_to_humidity: []const Value,
    humidity_to_location: []const Value
};

pub fn convert(value: u64, mappings: []const Value) u64 {
    for (mappings) |map| {
        const destination_start = map[0];
        const source_start = map[1];
        const len = map[2];

        const source_end = source_start + len - 1;
        if (source_start <= value and value <= source_end) {
            const index = value - source_start;
            return destination_start + index; 
        }
    }
    
    return value;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();

    const file_contents = try std.fs.cwd().readFileAlloc(allocator, "05_input.json", 100000000000);
    defer allocator.free(file_contents);

    const parsed = try std.json.parseFromSlice(Config, allocator, file_contents, .{ .allocate = .alloc_always });
    defer parsed.deinit();

    const items = parsed.value;

    var min: u64 = std.math.maxInt(u64);
    
    for (items.seeds) |seed_pair| {
        const start = seed_pair[0];
        const len = seed_pair[1];

        for (start..start+len) |seed| {     
            var value = seed;
            inline for (0.., std.meta.fields(Config)) |i, f| {
                if (i == 0) continue;    
                value = convert(value, @field(items, f.name));
            }
            min = @min(min, value);
        }
        
    } 

    print("{}\n", .{min});
}
