const std = @import("std");

const Round = struct {
    red: u32,
    green: u32,
    blue: u32,

    pub fn is_possible(self: *const Round, max_red: u32, max_green: u32, max_blue: u32) bool {
        return ((self.red <= max_red) and (self.green <= max_green) and (self.blue <= max_blue));
    }

    pub fn from_string(round_string: []const u8) !Round {
        var balls = std.mem.splitSequence(u8, round_string, ",");
        var red: u32 = 0;
        var green: u32 = 0;
        var blue: u32 = 0;

        while (balls.next()) |b| {
            var info = std.mem.splitSequence(u8, b, " ");
            _ = info.next();
            const number_of_balls = try std.fmt.parseInt(u32, info.next().?, 10);
            const color = info.next().?;

            if (std.mem.eql(u8, color, "red")) {
                red += number_of_balls;
            } else if (std.mem.eql(u8, color, "blue")) {
                blue += number_of_balls;
            } else if (std.mem.eql(u8, color, "green")) {
                green += number_of_balls;
            }
        }

        return Round{ .red = red, .green = green, .blue = blue };
    }
};

const Game = struct {
    id: u32,
    rounds: std.ArrayList(Round),

    pub fn is_possible(self: *const Game, max_red: u32, max_green: u32, max_blue: u32) bool {
        for (self.rounds.items) |r| {
            if (!r.is_possible(max_red, max_green, max_blue)) {
                return false;
            }
        }

        return true;
    }

    pub fn power(self: *const Game) u32 {
        var max_red: u32 = 0;
        var max_green: u32 = 0;
        var max_blue: u32 = 0;

        for (self.rounds.items) |r| {
            max_red = @max(r.red, max_red);
            max_green = @max(r.green, max_green);
            max_blue = @max(r.blue, max_blue);
        }

        return max_red * max_green * max_blue;
    }
};

fn load_games_from_file(file_name: []const u8) !std.ArrayList(Game) {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const allocator = std.heap.page_allocator;

    const contents = try file.reader().readAllAlloc(allocator, 100000);

    var iterator = std.mem.splitSequence(u8, contents, "\n");
    var games = std.ArrayList(Game).init(allocator);

    while (iterator.next()) |row| {
        var game_info_it = std.mem.splitSequence(u8, row, ":");
        const game_info = game_info_it.next().?;

        var game_id_it = std.mem.splitSequence(u8, game_info, " ");
        _ = game_id_it.next();
        const game_id = try std.fmt.parseInt(u32, game_id_it.next().?, 10);

        const rounds_info_full = game_info_it.next().?;
        var rounds_info_it = std.mem.splitSequence(u8, rounds_info_full, ";");
        var rounds = std.ArrayList(Round).init(allocator);

        while (rounds_info_it.next()) |r| {
            const round_instance = try Round.from_string(r);
            try rounds.append(round_instance);
        }

        const game = Game{ .id = game_id, .rounds = rounds };
        try games.append(game);
    }

    return games;
}

pub fn main() !void {
    const max_red: u32 = 12;
    const max_green: u32 = 13;
    const max_blue: u32 = 14;

    const games = try load_games_from_file("02_input.txt");
    defer games.deinit();

    var sum_of_ids: u32 = 0;
    var sum_of_products: u32 = 0;
    for (games.items) |g| {
        if (g.is_possible(max_red, max_green, max_blue)) {
            sum_of_ids += g.id;
        }

        sum_of_products += g.power();
    }

    std.debug.print("sum of ids: {}\n", .{sum_of_ids});
    std.debug.print("sum of products: {}\n", .{sum_of_products});
}
