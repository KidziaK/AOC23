const std = @import("std");

const Grid = std.ArrayList(std.ArrayList(u8));

fn cleanup(grid: Grid) void {
    for (grid.items) |row| {
        row.deinit();
    }
}

fn is_symbol(c: u8) bool {
    switch (c) {
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.' => {
            return false;
        },
        else => {
            return true;
        },
    }

    unreachable;
}

fn is_adjecent(grid: Grid, i: usize, j: usize) bool {
    const n = grid.items.len;
    const m = grid.items[0].items.len;
    // std.debug.print("{} {} {} {}\n", .{ i, j, n, m });
    if ((i >= 1) and is_symbol(grid.items[i - 1].items[j])) {
        return true;
    }

    if ((i + 1 < n) and is_symbol(grid.items[i + 1].items[j])) {
        return true;
    }

    if ((j >= 1) and is_symbol(grid.items[i].items[j - 1])) {
        return true;
    }

    if ((j + 1 < m) and is_symbol(grid.items[i].items[j + 1])) {
        return true;
    }

    if ((i >= 1) and (j >= 1) and is_symbol(grid.items[i - 1].items[j - 1])) {
        return true;
    }

    if ((i + 1 < n) and (j >= 1) and is_symbol(grid.items[i + 1].items[j - 1])) {
        return true;
    }

    if ((i >= 1) and (j + 1 < m) and is_symbol(grid.items[i - 1].items[j + 1])) {
        return true;
    }

    if ((i + 1 < n) and (j + 1 < m) and is_symbol(grid.items[i + 1].items[j + 1])) {
        return true;
    }

    return false;
}

fn abs_diff(a: usize, b: usize) usize {
    return @max(a, b) - @min(a, b);
}

const Position = struct {
    i: usize,
    j: usize,

    pub fn is_adjecent(self: *const Position, num: Number) bool {
        if (abs_diff(self.i, num.pos.i) > 1) {
            return false;
        }

        const num_end_index = num.pos.j + num.len - 1;

        for (num.pos.j..num_end_index) |col| {
            if (abs_diff(self.j, col) <= 1) {
                return true;
            }
        }

        return false;
    }
};

const Number = struct {
    pos: Position,
    len: usize,
};

pub fn main() !void {
    const debug_mode = false;
    const file_name = if (debug_mode) "03_input_simple.txt" else "03_input.txt";

    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const allocator = std.heap.page_allocator;

    const contents = try file.reader().readAllAlloc(allocator, 1000000000);
    defer allocator.free(contents);
    var it = std.mem.splitSequence(u8, contents, "\n");

    var grid = Grid.init(allocator);
    defer grid.deinit();
    defer cleanup(grid);

    while (it.next()) |row| {
        var grid_row = std.ArrayList(u8).init(allocator);
        for (row) |c| {
            try grid_row.append(c);
        }

        try grid.append(grid_row);
    }

    var numbers = std.ArrayList(Number).init(allocator);
    var gears = std.ArrayList(Position).init(allocator);
    defer numbers.deinit();
    defer gears.deinit();

    const VoidValue = struct {};
    var number_chars = std.AutoHashMap(u8, VoidValue).init(allocator);
    defer number_chars.deinit();

    try number_chars.put('0', VoidValue{});
    try number_chars.put('1', VoidValue{});
    try number_chars.put('2', VoidValue{});
    try number_chars.put('3', VoidValue{});
    try number_chars.put('4', VoidValue{});
    try number_chars.put('5', VoidValue{});
    try number_chars.put('6', VoidValue{});
    try number_chars.put('7', VoidValue{});
    try number_chars.put('8', VoidValue{});
    try number_chars.put('9', VoidValue{});

    // var sum: u64 = 0;

    for (0..grid.items.len) |i| {
        const row = grid.items[i];
        var l: i32 = -1;
        for (0..row.items.len) |j| {
            if (row.items[j] == '*') {
                try gears.append(Position{ .i = i, .j = j });
            }

            const c = number_chars.get(row.items[j]);

            if (c != null and l == -1) {
                l = @intCast(j);
            } else if (c == null and l >= 0) {
                const l_positive: usize = @intCast(l);
                // std.debug.print("{s}\n", .{grid.items[i].items[l_positive..j]});
                try numbers.append(Number{ .pos = Position{ .i = i, .j = l_positive }, .len = j - l_positive + 1 });
                l = -1;
            }
        }

        if (l >= 0) {
            const l_positive: usize = @intCast(l);
            const length = row.items.len - l_positive + 1;
            // std.debug.print("{s} {s} {}\n", .{ row.items, row.items[l_positive .. l_positive + length], length });
            try numbers.append(Number{ .pos = Position{ .i = i, .j = l_positive }, .len = length });
        }
    }

    var sum: usize = 0;
    for (gears.items) |pos| {
        var adjecent: usize = 0;
        var ratio: usize = 1;
        for (numbers.items) |num| {
            if (pos.is_adjecent(num)) {
                adjecent += 1;
                ratio *= try std.fmt.parseInt(usize, grid.items[num.pos.i].items[num.pos.j .. num.pos.j + num.len - 1], 10);
                // std.debug.print("{} {}\n", .{ try std.fmt.parseInt(usize, grid.items[num.pos.i].items[num.pos.j .. num.pos.j + num.len - 1], 10), adjecent });
            }
        }

        if (adjecent == 2) {
            // std.debug.print("{s}\n", .{grid.items[num.pos.i].items[num.pos.j .. num.pos.j + num.len]});
            sum += ratio;
        }
    }

    std.debug.print("total sum: {}\n", .{sum});
}
