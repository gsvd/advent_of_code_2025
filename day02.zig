const std = @import("std");

const input = "199617-254904,7682367-7856444,17408-29412,963327-1033194,938910234-938964425,3207382-3304990,41-84,61624-105999,1767652-1918117,492-749,85-138,140-312,2134671254-2134761843,2-23,3173-5046,16114461-16235585,3333262094-3333392446,779370-814446,26-40,322284296-322362264,6841-12127,290497-323377,33360-53373,823429-900127,17753097-17904108,841813413-841862326,518858-577234,654979-674741,773-1229,2981707238-2981748769,383534-468118,587535-654644,1531-2363";

fn isInvalidId(id: u64) bool {
    var buf: [32]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "{d}", .{id}) catch unreachable;

    if (s[0] == '0') return false;

    const len = s.len;
    if (len % 2 != 0) return false;

    const half = len / 2;
    const first_half = s[0..half];
    const second_half = s[half..len];

    return std.mem.eql(u8, first_half, second_half);
}

fn isInvalidId2(id: u64) bool {
    var buf: [32]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "{d}", .{id}) catch unreachable;

    if (s[0] == '0') return false;

    const len = s.len;
    if (len < 2) return false;

    var chunk_len: usize = 1;
    while (chunk_len <= len / 2) : (chunk_len += 1) {
        if (len % chunk_len != 0) continue;

        const chunk = s[0..chunk_len];

        var i: usize = chunk_len;
        var ok = true;
        while (i < len) : (i += 1) {
            if (s[i] != chunk[i % chunk_len]) {
                ok = false;
                break;
            }
        }

        if (ok) {
            return true;
        }
    }

    return false;
}

pub fn main() !void {
    const line = std.mem.trim(u8, input, " \n\r\t");

    var it = std.mem.splitScalar(u8, line, ',');
    var total_sum: u64 = 0;

    while (it.next()) |range_str| {
        if (range_str.len == 0) continue;

        const dash_index = std.mem.indexOfScalar(u8, range_str, '-') orelse continue;

        const start_str = range_str[0..dash_index];
        const end_str = range_str[dash_index + 1 ..];

        if (start_str.len == 0 or end_str.len == 0) continue;

        const start_id = try std.fmt.parseInt(u64, start_str, 10);
        const end_id = try std.fmt.parseInt(u64, end_str, 10);

        var n = start_id;
        while (n <= end_id) : (n += 1) {
            if (isInvalidId2(n)) {
                total_sum += n;
            }
        }
    }

    std.debug.print("{d}\n", .{total_sum});
}
