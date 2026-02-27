//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

fn decodeValue(val: u16) u8 {
    if (val <= 1) return 0;
    return 15 - @clz(val);
}

fn isMutable(val: u16) bool {
    return (val & 1 == 0);
}

pub fn readTable(filepath: []const u8) ![9][9]u16 {
    var file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();
    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;
    const len = try reader.readSliceShort(&buffer);
    var table: [9][9]u16 = undefined;

    var x: u8 = 0;
    var y: u8 = 0;
    for (0..len) |i| {
        if (buffer[i] >= '0' and buffer[i] <= '9') {
            // table[y][x] = @as(u9, 1) << @as(u9, @truncate(buffer[i] - '0')) + 1;
            const shift: u4 = @truncate(buffer[i] - '0');
            table[y][x] = (@as(u16, 1) << shift) + 1;
            // std.debug.print("{b}\n", .{table[y][x]});
            x += 1;
            if (x == 9) {
                x = 0;
                y += 1;
            }
        }
        if (buffer[i] == '_') {
            table[y][x] = 0;
            x += 1;
            if (x == 9) {
                x = 0;
                y += 1;
            }
        }
    }

    return table;
}

pub fn clearScreen() void {
    std.debug.print("\x1B[2J\x1B[H", .{});
}

pub fn displayTable(table: *const [9][9]u16, idx: ?u8) void {
    const i: u8 = if (idx) |id| id / 9 else 9;
    const j: u8 = if (idx) |id| id % 9 else 9;

    for (0..9) |y| {
        if (y % 3 == 0) {
            std.debug.print("-" ** 23 ++ "\n", .{});
        }
        for (0..9) |x| {
            if (x % 3 == 0) {
                std.debug.print("| ", .{});
            }
            if (y == i and x == j) {
                std.debug.print("\x1B[1;31m\x1B[1;43m{d}", .{decodeValue(table[y][x])});
                std.debug.print("\x1B[0;37m ", .{});
            } else {
                if (table[y][x] & 0x1 == 0) {
                    std.debug.print("\x1B[30;47m{d}\x1B[0;37m ", .{decodeValue(table[y][x])});
                } else {
                    std.debug.print("{d} ", .{decodeValue(table[y][x])});
                }
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn isElementValid(table: *const [9][9]u16, i: u8, j: u8) bool {
    for (0..9) |a| {
        if (a == j) continue;
        if (table[i][j] & 0xfffe == table[i][a] & 0xfffe) {
            std.debug.print("same element on row...\n", .{});
            return false;
        }
    }
    for (0..9) |a| {
        if (a == i) continue;
        if (table[i][j] & 0xfffe == table[a][j] & 0xfffe) {
            std.debug.print("same element on column...\n", .{});
            return false;
        }
    }
    for (0..3) |a| {
        for (0..3) |b| {
            if (a == i % 3 and b == j % 3) continue;
            if (table[i][j] & 0xfffe == table[a + (i / 3) * 3][b + (j / 3) * 3] & 0xfffe) {
                std.debug.print("same element on cell...\n", .{});
                return false;
            }
        }
    }
    return true;
}

var depth: i64 = 0;

pub fn new_solve(solution: *[9][9]u16, original: *[9][9]u16) bool {
    var table = original.*;
    // clearScreen();
    var rows: [9]u16 = undefined;
    var cols: [9]u16 = undefined;
    var cells: [9]u16 = undefined;
    var numbersLeft: u8 = 81;
    var prevNumbers: u8 = 80;
    rows = .{0} ** 9;
    cols = .{0} ** 9;
    cells = .{0} ** 9;
    var minPossible: u8 = 9;
    for (0..9) |y| {
        for (0..9) |x| {
            if (isMutable(table[y][x])) {
                table[y][x] = 0b1111111110;
                continue;
            }
            rows[y] |= table[y][x];
            cols[x] |= table[y][x];
            cells[x / 3 + y / 3 * 3] |= table[y][x];
        }
    }
    for (0..9) |i| {
        rows[i] = ~rows[i] & 0b1111111110;
        cols[i] = ~cols[i] & 0b1111111110;
        cells[i] = ~cells[i] & 0b1111111110;
        // std.debug.print("{b:0>10}, {b:0>10}, {b:0>10}\n", .{ rows[i], cols[i], cells[i] });
    }
    while (numbersLeft != prevNumbers and numbersLeft != 0) {
        minPossible = 9;
        prevNumbers = numbersLeft;
        numbersLeft = 0;
        // displayTable(&table, null);
        // for (0..9) |i| {
        //     std.debug.print("{b}, {b}, {b}\n", .{ rows[i], cols[i], cells[i] });
        // }
        for (0..9) |y| {
            for (0..9) |x| {
                if (!isMutable(table[y][x])) continue;
                // for (0..9) |i| {
                //     if (!isMutable(table[y][i])) {
                //         table[y][x] |= table[y][i];
                //     }
                // }
                // for (0..9) |j| {
                //     if (!isMutable(table[j][x])) {
                //         table[y][x] |= table[j][x];
                //     }
                // }
                // for (0..3) |i| {
                //     for (0..3) |j| {
                //         if (!isMutable(table[y / 3 * 3 + j][x / 3 * 3 + i])) {
                //             table[y][x] |= table[y / 3 * 3 + j][x / 3 * 3 + i];
                //         }
                //     }
                // }
                numbersLeft += 1;
                table[y][x] &= rows[y] & cols[x] & cells[x / 3 + y / 3 * 3];

                // table[y][x] = ~table[y][x] & 0b1111111110;
                if (minPossible > @popCount(table[y][x])) {
                    minPossible = @popCount(table[y][x]);
                }

                // std.debug.print("Minium possible: {d}\n", .{minPossible});
                // std.debug.print("{d},{d}: {d} {b}\n", .{ y, x, @popCount(table[y][x]), table[y][x] });
                if (@popCount(table[y][x]) == 1) {
                    rows[y] &= ~table[y][x];
                    cols[x] &= ~table[y][x];
                    cells[x / 3 + y / 3 * 3] &= ~table[y][x];
                    table[y][x] += 1;
                } else if (table[y][x] == 0) {
                    // std.debug.print("Impossible\n", .{});
                    return false;
                } else {
                    // table[y][x] = 0b1111111110;
                }
            }
        }
        // for (0..9) |i| {
        //     std.debug.print("{b:0>10}, {b:0>10}, {b:0>10}\n", .{ rows[i], cols[i], cells[i] });
        // }
        // std.debug.print("Numbers left: {d}\nMin poss: {d}\n\n", .{ numbersLeft, minPossible });
    }
    // solve(table);
    if (numbersLeft == 0) {
        @memcpy(solution, &table);
        return true;
    }
    // std.Thread.sleep(1_000_000_000);
    depth += 1;
    // std.debug.print("Branching {d} ..\n\n", .{depth});
    var sol: [9][9]u16 = undefined;
    var branch: [9][9]u16 = undefined;
    var val: u16 = undefined;
    @memcpy(&branch, &table);
    outer: for (0..9) |i| {
        for (0..9) |j| {
            if (!isMutable(branch[i][j])) continue;
            // std.debug.print("{d}, {d}: {b:0>16}, pop:{d}, min:{d}\n", .{ i, j, branch[i][j], @popCount(branch[i][j]), minPossible });
            if (@popCount(branch[i][j]) != minPossible) continue;
            val = branch[i][j];
            while (branch[i][j] != 0) {
                const lshift: u4 = @truncate(decodeValue(branch[i][j]));
                branch[i][j] = branch[i][j] & ((@as(u16, 1) << lshift)) | 1;
                // std.debug.print("Trying branch {d}:\n", .{depth});
                // displayTable(&branch, @as(u8, @truncate(i * 9 + j)));
                if (new_solve(&sol, &branch)) {
                    @memcpy(solution, &sol);
                    return true;
                } else {
                    val = val ^ (@as(u16, 1) << lshift);
                    branch[i][j] = val;
                }
            }
            break :outer;
        }
    }
    depth -= 1;
    return false;
}

fn solve(table: *[9][9]u16) void {
    var idx: u8 = 0;
    const time: u64 = 1;
    for (0..9) |i| {
        for (0..9) |j| {
            if (isMutable(table[i][j])) {
                table[i][j] = 0;
            }
        }
    }
    main_loop: while (true) {
        if (idx == 81) break :main_loop;
        const i = idx / 9;
        const j = idx % 9;

        std.debug.print("\x1B[2J\x1B[H", .{});
        displayTable(table, idx);
        // std.debug.print("index = {d}\nposition : {d},{d}\nvalue: {d}\n", .{ idx, j, i, decodeValue(table[i][j]) });
        idx = (idx + 1);
        if (!isMutable(table[i][j])) continue :main_loop;
        if (table[i][j] == 0) table[i][j] = 0b10;
        if (decodeValue(table[i][j]) > 9) {
            std.debug.print("need to backtrack...\n", .{});
            std.Thread.sleep(time);
            table[i][j] = 0;
            idx -= 2;
            while (table[idx / 9][idx % 9] & 1 != 0) idx -= 1;
            table[idx / 9][idx % 9] <<= 1;
            continue :main_loop;
        }
        if (!isElementValid(table, i, j)) {
            table[i][j] <<= 1;
            std.Thread.sleep(time);
            idx -= 1;
            continue :main_loop;
        }

        std.Thread.sleep(time);
    }
}

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
