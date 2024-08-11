const std = @import("std");
const MAX_ALLOC = 1000000;

const NumberSet = std.ArrayList(u32);

const Card = struct {
    winning_numbers: NumberSet,
    numbers: NumberSet,

    pub fn from_string(string: []const u8) !Card {
        const alloc = std.heap.page_allocator;
        const header_end = std.mem.indexOf(u8, string, ":").?;
        const number_sets = string[header_end + 1 ..];
        const set_split = std.mem.indexOf(u8, number_sets, "|").?;

        const set_1 = number_sets[0..set_split];
        const set_2 = number_sets[set_split + 1 ..];

        var it_set_1 = std.mem.splitSequence(u8, set_1, " ");
        var it_set_2 = std.mem.splitSequence(u8, set_2, " ");

        var winning_numbers = NumberSet.init(alloc);
        var numbers = NumberSet.init(alloc);

        while (it_set_1.next()) |num_str| {
            const num = std.fmt.parseInt(u32, num_str, 10) catch null;
            if (num != null) {
                try winning_numbers.append(num.?);
            }
        }

        while (it_set_2.next()) |num_str| {
            const num = std.fmt.parseInt(u32, num_str, 10) catch null;
            if (num != null) {
                try numbers.append(num.?);
            }
        }

        return Card{ .winning_numbers = winning_numbers, .numbers = numbers };
    }

    pub fn points(self: *const Card) u32 {
        var count: u32 = 0;
        for (self.numbers.items) |n1| {
            for (self.winning_numbers.items) |n2| {
                if (n1 == n2) {
                    count += 1;
                }
            }
        }

        if (count == 0) return 0;
        return std.math.pow(u32, 2, count - 1);
    }

    pub fn matching_numbers(self: *const Card) u32 {
        var count: u32 = 0;
        for (self.numbers.items) |n1| {
            for (self.winning_numbers.items) |n2| {
                if (n1 == n2) {
                    count += 1;
                }
            }
        }

        return count;
    }
};

fn array_clean(array: std.ArrayList(Card)) void {
    for (array.items) |card| {
        card.winning_numbers.deinit();
        card.numbers.deinit();
    }

    array.deinit();
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const debug = if (args.len == 3) args[2][0] == '1' else false;
    const file_name = if (debug) "04_input_simple.txt" else "04_input.txt";

    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const contents = try file.reader().readAllAlloc(alloc, MAX_ALLOC);
    defer alloc.free(contents);

    var it_contents = std.mem.splitSequence(u8, contents, "\n");
    var cards = std.ArrayList(Card).init(alloc);
    defer array_clean(cards);

    while (it_contents.next()) |row| {
        const card = try Card.from_string(row);
        try cards.append(card);
    }

    var total_copies_number: u32 = 0;
    var card_to_copies = std.AutoHashMap(usize, u32).init(alloc);
    defer card_to_copies.deinit();

    for (cards.items, 0..) |_, i| {
        try card_to_copies.put(i, 1);
    }

    for (cards.items, 0..) |card, i| {
        const copies = card_to_copies.get(i).?;
        total_copies_number += copies;

        const matches = card.matching_numbers();

        for (i + 1..@min(i + 1 + matches, cards.items.len)) |j| {
            const copies_of_j_th_card = card_to_copies.get(j).?;
            try card_to_copies.put(j, copies_of_j_th_card + copies);
        }
    }

    std.debug.print("copies = {}\n", .{total_copies_number});
}
