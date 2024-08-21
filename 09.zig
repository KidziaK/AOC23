const std = @import("std");

fn find_next_number_in_sequence(nums: []i64) i64 {
    var sum: i64 = 0;

    for (1..nums.len) |row| {
        sum += nums[nums.len - row];
        for (0..nums.len - row) |i| {
            nums[i] = nums[i + 1] - nums[i];
        }
    }

    return sum;
}

fn find_prev_number_in_sequence(nums: []i64) i64 {
    var sum: i64 = nums[0];
    var parity = true;

    for (1..nums.len) |row| {
        for (0..nums.len - row) |i| {
            nums[i] = nums[i + 1] - nums[i];
        }

        sum = if (parity) sum - nums[0] else sum + nums[0];
        parity = !parity;
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const contents = try std.fs.cwd().readFileAlloc(alloc, "09_input.txt", 1000000);
    var it = std.mem.splitSequence(u8, contents, "\n");

    var nums = std.ArrayList(i64).init(alloc);
    defer nums.deinit();

    var nums_populated = false;

    while (it.next()) |row| {
        var row_it = std.mem.splitSequence(u8, row, " ");
        var i: u64 = 0;

        while (row_it.next()) |n| {
            if (nums_populated) {
                nums.items[i] += try std.fmt.parseInt(i64, n, 10);
            } else {
                try nums.append(try std.fmt.parseInt(i64, n, 10));
            }
            i += 1;
        }

        nums_populated = true;
    }

    const answer: i64 = find_next_number_in_sequence(nums.items);
    var anwser_two_star: i64 = 0;

    it = std.mem.splitSequence(u8, contents, "\n");

    while (it.next()) |row| {
        var row_it = std.mem.splitSequence(u8, row, " ");
        var nums2 = std.ArrayList(i64).init(alloc);
        defer nums2.deinit();

        while (row_it.next()) |n| {
            try nums2.append(try std.fmt.parseInt(i64, n, 10));
        }

        nums_populated = true;
        anwser_two_star += find_prev_number_in_sequence(nums2.items);
    }

    std.debug.print("{any}\n", .{answer});
    std.debug.print("{any}\n", .{anwser_two_star});
}
