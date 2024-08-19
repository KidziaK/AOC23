const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const heap = std.heap;

const Hand = struct {
    cards: []const u8,
    bid: u64
};

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}) {};
    const alloc = gpa.allocator();

    const contents = try fs.cwd().readFileAlloc(alloc, "07_input_sorted.txt", 1000000);
    

    var rows_it = std.mem.splitSequence(u8, contents, "\n");
    var hands = std.ArrayList(Hand).init(alloc);
    defer hands.deinit();

    while (rows_it.next()) |row| {
        var hand_it = std.mem.splitSequence(u8, row, " ");
        const cards = hand_it.next().?;

        const bid = try std.fmt.parseInt(u64, hand_it.next().?, 10);
        const hand = Hand {.cards = cards, .bid = bid};

        try hands.append(hand);
    }

    var result: u64 = 0;

    for (hands.items, 0..) |h, i| {
        result += (i + 1) * h.bid;
    }

    print("{}\n", .{result});
}