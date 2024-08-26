const std = @import("std");

const NoVal = struct{};
const Position = struct { x: usize, y: usize };

fn in_bounds(x: usize, y: usize, grid: std.ArrayList([]const u8)) bool {
    const row_count = grid.items.len;
    const col_count = grid.items[0].len;

    return x >= 0 and x < row_count and y >= 0 and y < col_count;
}

fn valid_neighbor(pos: Position, )

fn next_position(pos: Position, grid: std.ArrayList([]const u8), visited: std.AutoHashMap(Position, NoVal)) ?Position {
    switch (grid.items[pos.x][pos.y]) {
        'S' => {
            if (in_bounds(pos.x + 1, pos.y, grid) and grid.items[pos.x][pos.y])
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const file_contents = try std.fs.cwd().readFileAlloc(alloc, "10_input_simple.txt", 1000000);
    var row_it = std.mem.splitSequence(u8, file_contents, "\n");

    var grid = std.ArrayList([]const u8).init(alloc);
    defer grid.deinit();

    while (row_it.next()) |row| {
        try grid.append(row);
    }

    var current_position: Position = undefined;

    var outer: void = outer_loop: {
        for (0..grid.items.len) |i| {
            for (0..grid.items[0].len) |j| {
                if (grid.items[i][j] == 'S') {
                    current_position = Position {.x = i, .y = j};
                    break :outer_loop;
                }
            }
        }
    };

    var loop_closed = false;
    var loop_len = 0;

    
    var visited = std.AutoHashMap(Position, NoVal).init(alloc);
    defer visited.deinit();

    try visited.put(current_position, Noval {});

    while (!loop_closed) {
        current_position = next_position(x, y, grid, visited) orelse break;
        loop_len += 1;
    }

    std.debug.print("1-star solution: {}\n", .{loop_len / 2});
}
