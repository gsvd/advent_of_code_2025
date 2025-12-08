const std = @import("std");

pub fn getMaxValue(bank: []const u8) !usize {
    const k: usize = 12;

    var pos: usize = 0;
    var chosen: usize = 0;
    var value: usize = 0;

    while (chosen < k) : (chosen += 1) {
        const limit = bank.len - k + chosen;

        var best_digit: usize = 0;
        var best_idx: usize = pos;

        var i: usize = pos;
        while (i <= limit) : (i += 1) {
            const digit = try std.fmt.parseInt(usize, &[_]u8{bank[i]}, 10);
            if (digit > best_digit) {
                best_digit = digit;
                best_idx = i;
                if (digit == 9) break;
            }
        }

        value = value * 10 + best_digit;
        pos = best_idx + 1;
    }

    return value;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input_day03.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var it = std.mem.splitScalar(u8, input, '\n');
    var joltage: usize = 0;
    while (it.next()) |bank| {
        const result = try getMaxValue(bank);
        joltage += result;
        std.debug.print("bank joltage: {d}, {s}, total: {d}\n", .{ result, bank, joltage });
    }
    std.debug.print("total joltage: {d}\n", .{joltage});
}
