const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;
const fs = std.fs;
const assert = std.debug.assert;

const GridDims = struct {
    rows: usize,
    cols: usize
};

const Grid = struct {
    const Self = @This();

    memory_handle: std.ArrayList([]const u8),

    pub fn init(alloc: std.mem.Allocator, grid_string: []const u8) std.mem.Allocator.Error!Grid {
        var it = std.mem.splitSequence(u8, grid_string, "\n");
        var grid = std.ArrayList([]const u8).init(alloc);

        while (it.next()) |row| {
            try grid.append(row);
        } 

        return Grid {.memory_handle = grid};
    }

    pub fn transpose(self: Self, alloc: std.mem.Allocator) std.mem.Allocator.Error!Grid {
        const grid_dims = self.dims();
        const rows = grid_dims.rows;
        const cols = grid_dims.cols;

        var grid = std.ArrayList([]const u8).init(alloc);

        for (0..cols) |col_num| {
            var row = try alloc.alloc(u8, rows);
            for (0..rows) |row_num| {
                row[row_num] = self.get(row_num, col_num);
            }
            try grid.append(row);
        }

        return Grid {.memory_handle = grid};
    }

    pub fn get(self: Self, i: usize, j: usize) u8 {
        return self.memory_handle.items[i][j];
    }

    pub fn get_row(self: Self, i: usize) []const u8 {
        return self.memory_handle.items[i];
    }

    pub fn deinit(self: Self) void {
        self.memory_handle.deinit();
    }

    pub fn rows_count(self: Self) usize {
        return self.memory_handle.items.len;
    }

    pub fn cols_count(self: Self) usize {
        assert(self.memory_handle.items.len > 0);
        return self.memory_handle.items[0].len;
    }

    pub fn dims(self: Self) GridDims {
        assert(self.memory_handle.items.len > 0);
        return GridDims {.rows = self.rows_count(), .cols = self.cols_count()};
    }

    pub fn to_string(self: Self, alloc: std.mem.Allocator) anyerror![]const u8 {
        return std.mem.join(alloc, "\n", self.memory_handle.items);
    }

    pub fn is_line_of_reflection(self: Self, line_idx: usize) bool {
        const rows = self.rows_count();

        for (0..@min(line_idx, rows - line_idx)) |row_idx| {
            const row_above_line = self.get_row(line_idx - row_idx - 1);
            const row_below_line = self.get_row(line_idx + row_idx);

            if (!std.mem.eql(u8, row_below_line, row_above_line)) {
                return false;
            }
        }

        return true;
    }

    pub fn count_line_of_reflections_score(self: Self) usize {
        const rows = self.rows_count();

        var count: usize = 0;
        for (1..rows) |line_idx|{
            if (self.is_line_of_reflection(line_idx)) count += line_idx;
        }

        return count;
    }
};



fn print_with_one_string_arg(arg: []const u8) void {
    print("{s}\n", .{arg});
}

fn print_with_one_char_arg(arg: u8) void {
    print("{c}\n", .{arg});
}

fn sub_solution(grid_array: *std.ArrayList([]const u8)) !usize {
    const grid_str = try std.mem.join(allocator, "\n", grid_array.items);
            
    const grid = try Grid.init(allocator, grid_str);
    defer grid.deinit();

    const horizontal = grid.count_line_of_reflections_score();
    const grid_t = try grid.transpose(allocator);
    defer grid_t.deinit();

    const vertical = grid_t.count_line_of_reflections_score();
    
    grid_array.clearRetainingCapacity();

    return 100 * horizontal + vertical;
}


pub fn main() !void {
    const file_contents = try fs.cwd().readFileAlloc(allocator, "13_simple.txt", std.math.maxInt(u32));
    var file_it = std.mem.splitSequence(u8, file_contents, "\n");
    var grid_array = std.ArrayList([]const u8).init(allocator);
    defer grid_array.deinit();

    var total: usize = 0;

    while (file_it.next()) |row|{
        if (row.len == 0) {
            total += try sub_solution(&grid_array);
        } else {
            try grid_array.append(row);
        }
    }

    total += try sub_solution(&grid_array);

    print("total: {}\n", .{total});
}