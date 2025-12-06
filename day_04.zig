const std = @import("std");

fn countTrueNeighbors(matrix: [][]bool, x: usize, y: usize) usize {
    var count: usize = 0;

    const rows = matrix.len;
    const cols = matrix[0].len;

    const start_x = if (x == 0) 0 else x - 1;
    const end_x = if (x + 1 >= rows) rows - 1 else x + 1;
    const start_y = if (y == 0) 0 else y - 1;
    const end_y = if (y + 1 >= cols) cols - 1 else y + 1;

    var ix = start_x;
    while (ix <= end_x) : (ix += 1) {
        var iy = start_y;
        while (iy <= end_y) : (iy += 1) {
            if (ix == x and iy == y) continue;
            if (matrix[ix][iy]) count += 1;
        }
    }

    return count;
}

pub fn buildMatrix(allocator: std.mem.Allocator, input: []const u8) ![][]bool {
    var matrix = try allocator.alloc([]bool, 136);
    var it = std.mem.splitScalar(u8, input, '\n');
    var i: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        matrix[i] = try allocator.alloc(bool, line.len);
        for (line, 0..) |c, y| {
            matrix[i][y] = switch (c) {
                '@' => true,
                '.' => false,
                else => return error.InvalidCharacter,
            };
        }
        i += 1;
    }
    return matrix;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input_day04.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var matrix = try buildMatrix(allocator, input);
    defer allocator.free(matrix);

    var total_removed: usize = 0;

    while (true) {
        var changed = false;

        for (matrix, 0..) |row, x| {
            for (row, 0..) |cell, y| {
                if (!cell) continue;

                const neighbors = countTrueNeighbors(matrix, x, y);
                if (neighbors < 4) {
                    matrix[x][y] = false;
                    total_removed += 1;
                    changed = true;
                }
            }
        }

        if (!changed) break;
    }

    std.debug.print("Result: {}\n", .{total_removed});
}
