const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;
const print = std.debug.print;

const Position = struct {
    const Self = @This();

    x: usize,
    y: usize,

    pub fn eq(self: Self, other: Self) bool {
        return self.x == other.x and self.y == other.y;
    }

    pub fn distance(self: Self, other: Self) usize {
        return @max(self.x, other.x) - @min(self.x, other.x) + @max(self.y, other.y) - @min(self.y, other.y);
    }
};

const PositionList = std.ArrayList(Position);

const Space = struct {
    const Self = @This();

    galaxies: PositionList,
    expansion_rate: usize,
    expansion_cols: std.AutoHashMap(usize, bool),
    expansion_rows: std.AutoHashMap(usize, bool),

    pub fn expansion_amount(self: Self, g1: Position, g2: Position) usize {
        const x_min = @min(g1.x, g2.x);
        const x_max = @max(g1.x, g2.x);

        const y_min = @min(g1.y, g2.y);
        const y_max = @max(g1.y, g2.y);

        var amount: usize = 0;

        for (x_min..x_max) |i| {
            const expand_row = self.expansion_rows.get(i);
            if (expand_row.?) amount += self.expansion_rate;
        }

        for (y_min..y_max) |j| {
            const expand_col = self.expansion_cols.get(j);
            if (expand_col.?) amount += self.expansion_rate;
        }

        return amount;
    }

    pub fn sum_distances(self: Self) usize {
        var sum: usize = 0;
        for (0..self.galaxies.items.len) |i| {
            for (i + 1..self.galaxies.items.len) |j| {
                const g1 = self.galaxies.items[i];
                const g2 = self.galaxies.items[j];
                if (g1.eq(g2)) continue;
                sum += g1.distance(g2);
                sum += self.expansion_amount(g1, g2);
            }
        }
        return sum;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const file_contents = try fs.cwd().readFileAlloc(alloc, "11_input.txt", 100000);
    var file_it = std.mem.splitSequence(u8, file_contents, "\n");

    var i: usize = 0;
    var galaxies: PositionList = PositionList.init(alloc);
    defer galaxies.deinit();

    var expansion_cols = std.AutoHashMap(usize, bool).init(alloc);
    defer expansion_cols.deinit();

    var expansion_rows = std.AutoHashMap(usize, bool).init(alloc);
    defer expansion_rows.deinit();

    while (file_it.next()) |row| {
        for (row, 0..) |c, j| {
            if (c == '#') {
                try galaxies.append(Position{ .x = i, .y = j });
                try expansion_rows.put(i, false);
                try expansion_cols.put(j, false);
            } else {
                if (expansion_rows.get(i) == null) try expansion_rows.put(i, true);
                if (expansion_cols.get(j) == null) try expansion_cols.put(j, true);
            }
        }
        i += 1;
    }

    const expansion_rate = 1000000;
    const space = Space{ .galaxies = galaxies, .expansion_rate = expansion_rate - 1, .expansion_cols = expansion_cols, .expansion_rows = expansion_rows };

    print("{}\n", .{space.sum_distances()});
}
