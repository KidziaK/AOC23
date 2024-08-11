const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("01_input.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;

    const contents: []u8 = try file.reader().readAllAlloc(allocator, 1000000);
    defer allocator.free(contents);

    var it = std.mem.splitSequence(u8, contents, "\n");
    var sum: u64 = 0;
    while (it.next()) |row| {
        var first_digit_found = false;
        var d1: u8 = '0';
        var d2: u8 = '0';

        var i: usize = 0;
        while (i < row.len) : (i += 1) {
            const c = row[i];
            if (std.ascii.isAlphabetic(c)) {
                const ret: ?ReturnValue = try_number(row, i);
                if (first_digit_found) {
                    if (ret != null) {
                        const optional = ret.?;
                        d2 = optional.c;
                        i += (optional.len - 1);
                    }
                } else {
                    if (ret != null) {
                        const optional = ret.?;
                        d1 = optional.c;
                        d2 = d1;
                        i += (optional.len - 1);
                        first_digit_found = true;
                    }
                }
            } else {
                if (first_digit_found) {
                    d2 = c;
                } else {
                    d1 = c;
                    d2 = c;
                    first_digit_found = true;
                }
            }
        }

        const combined: [2]u8 = .{ d1, d2 };
        print("{s}: {s}\n", .{ row, combined });
        sum += try std.fmt.parseInt(u64, &combined, 10);
    }

    print("Total sum: {}\n", .{sum});
}

const ReturnValue = struct { c: u8, len: u8 };

fn try_number(row: []const u8, idx: usize) ?ReturnValue {
    const n = row.len;
    var result: ReturnValue = ReturnValue{ .c = '0', .len = 1 };

    if (idx + 3 <= n) {
        const val = row[idx .. idx + 3];
        if (std.mem.eql(u8, val, "one")) {
            result.c = '1';
            // result.len = 3;
        } else if (std.mem.eql(u8, val, "two")) {
            result.c = '2';
            // result.len = 3;
        } else if (std.mem.eql(u8, val, "six")) {
            result.c = '6';
            // result.len = 3;
        }
    }

    if (idx + 4 <= n) {
        const val = row[idx .. idx + 4];
        if (std.mem.eql(u8, val, "four")) {
            result.c = '4';
            // result.len = 4;
        } else if (std.mem.eql(u8, val, "five")) {
            result.c = '5';
            // result.len = 4;
        } else if (std.mem.eql(u8, val, "nine")) {
            result.c = '9';
            // result.len = 4;
        }
    }

    if (idx + 5 <= n) {
        const val = row[idx .. idx + 5];
        if (std.mem.eql(u8, val, "three")) {
            result.c = '3';
            // result.len = 5;
        } else if (std.mem.eql(u8, val, "seven")) {
            result.c = '7';
            // result.len = 5;
        } else if (std.mem.eql(u8, val, "eight")) {
            result.c = '8';
            // result.len = 5;
        }
    }

    if (result.c == '0') {
        return null;
    }

    return result;
}
