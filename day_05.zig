const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,
};

fn parseFreshRange(line: []const u8) !Range {
    var it = std.mem.splitScalar(u8, line, '-');
    const start_str = it.next().?;
    const end_str = it.next().?;

    const start = try std.fmt.parseInt(u64, start_str, 10);
    const end = try std.fmt.parseInt(u64, end_str, 10);

    return .{ .start = start, .end = end };
}

fn partOne() !void {
    std.debug.print("Day 05 Part One:\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input_day05.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(allocator);

    var lines = std.mem.splitScalar(u8, input, '\n');
    var is_ranging = true;
    var i: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            is_ranging = false;
            continue;
        }

        if (is_ranging) {
            const range = try parseFreshRange(line);
            try ranges.append(allocator, range);
        } else {
            const id = try std.fmt.parseInt(u64, line, 10);
            for (ranges.items) |r| {
                if (id >= r.start and id <= r.end) {
                    i += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("Total of Fresh IDs: {d}\n", .{i});
    std.debug.print("End of Day 05 Part One\n", .{});
}

fn rangeLessThan(_: void, a: Range, b: Range) bool {
    if (a.start == b.start) return a.end < b.end;
    return a.start < b.start;
}

fn partTwo() !void {
    std.debug.print("Day 05 Part Two:\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input_day05.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(allocator);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;

        const range = try parseFreshRange(line);
        try ranges.append(allocator, range);
    }

    if (ranges.items.len == 0) {
        std.debug.print("Total of really Fresh IDs: 0\n", .{});
        std.debug.print("End of Day 05 Part Two\n", .{});
        return;
    }

    std.mem.sort(Range, ranges.items, {}, rangeLessThan);

    var total: u64 = 0;
    var cur = ranges.items[0];

    for (ranges.items[1..]) |r| {
        if (r.start <= cur.end + 1) {
            if (r.end > cur.end) cur.end = r.end;
        } else {
            total += cur.end - cur.start + 1;
            cur = r;
        }
    }

    total += cur.end - cur.start + 1;

    std.debug.print("Total of really Fresh IDs: {d}\n", .{total});
    std.debug.print("End of Day 05 Part Two\n", .{});
}

pub fn main() !void {
    try partOne();
    std.debug.print("\n", .{});
    try partTwo();
}
