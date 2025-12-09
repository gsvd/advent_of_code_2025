const std = @import("std");

const Matrix = std.ArrayList(std.ArrayList(usize));

fn parseInput(allocator: std.mem.Allocator) !struct {
    matrix: Matrix,
    operators: std.ArrayList(u8),
} {
    const file = try std.fs.cwd().openFile("input_day06.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var operators: std.ArrayList(u8) = .empty;
    var matrix: Matrix = .empty;

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) continue;

        var token = std.mem.tokenizeAny(u8, line, " ");
        var values: std.ArrayList(usize) = .empty;

        while (token.next()) |field| {
            const v = std.fmt.parseInt(usize, field, 10) catch {
                try operators.append(allocator, field[0]);
                continue;
            };
            try values.append(allocator, v);
        }

        if (values.items.len > 0)
            try matrix.append(allocator, values)
        else
            values.deinit(allocator);
    }

    return .{ .matrix = matrix, .operators = operators };
}

fn partOne(matrix: Matrix, operators: std.ArrayList(u8)) usize {
    const num_rows = matrix.items.len;
    const num_cols = matrix.items[0].items.len;

    var total: usize = 0;

    for (0..num_cols) |c| {
        var result = matrix.items[0].items[c];
        const op = operators.items[c];

        for (1..num_rows) |r| {
            const v = matrix.items[r].items[c];
            switch (op) {
                '+' => result += v,
                '*' => result *= v,
                else => {},
            }
        }

        total += result;
    }

    return total;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var parsed = try parseInput(allocator);
    defer {
        for (parsed.matrix.items) |*row| row.deinit(allocator);
        parsed.matrix.deinit(allocator);
        parsed.operators.deinit(allocator);
    }

    const p1 = partOne(parsed.matrix, parsed.operators);
    std.debug.print("Part One = {d}\n", .{p1});
}
