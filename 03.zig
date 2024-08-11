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

    var sum: u64 = 0;

    for (0..grid.items.len) |i| {
        const row = grid.items[i];
        var l: i32 = -1;
        var adjecent_to_symbol = false;
        for (0..row.items.len) |j| {
            const c = number_chars.get(row.items[j]);

            if (c != null) {
                if (l == -1) {
                    l = @intCast(j);
                }
                adjecent_to_symbol = adjecent_to_symbol or is_adjecent(grid, i, j);
            } else if ((c == null) and (l >= 0)) {
                if (adjecent_to_symbol) {
                    // std.debug.print("{s}\n", .{row.items[@intCast(l)..j]});
                    sum += try std.fmt.parseInt(u32, row.items[@intCast(l)..j], 10);
                }

                adjecent_to_symbol = false;
                l = -1;
            }
        }

        if ((l >= 0) and (adjecent_to_symbol)) {
            sum += try std.fmt.parseInt(u32, row.items[@intCast(l)..], 10);
        }
    }

    std.debug.print("total sum: {}\n", .{sum});
}
