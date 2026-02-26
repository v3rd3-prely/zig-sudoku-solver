const std = @import("std");
const sudoku_solver = @import("sudoku_solver");

fn readTable(filepath: []const u8) ![9][9]u5 {
    var file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();
    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;
    const len = try reader.readSliceShort(&buffer);
    var table: [9][9]u5 = undefined;
    {
        var x: u8 = 0;
        var y: u8 = 0;
        for (0..len) |i| {
            if (buffer[i] >= '0' and buffer[i] <= '9') {
                table[y][x] = @truncate(buffer[i] - '0');
                x += 1;
                if (x == 9) {
                    x = 0;
                    y += 1;
                }
            }
            if (buffer[i] == '_') {
                table[y][x] = 0x10;
                x += 1;
                if (x == 9) {
                    x = 0;
                    y += 1;
                }
            }
        }
    }
    return table;
}

fn displayTable(table: [9][9]u5, idx: u8) !void {
    std.debug.print("\x1B[2J\x1B[H", .{});
    const i = idx / 9;
    const j = idx % 9;
    for (0..9) |y| {
        if (y % 3 == 0) {
            std.debug.print("-" ** 23 ++ "\n", .{});
        }
        for (0..9) |x| {
            if (x % 3 == 0) {
                std.debug.print("| ", .{});
            }
            if (y == i and x == j) {
                std.debug.print("\x1B[1;31m\x1B[1;43m{d}", .{table[y][x] & 0xf});
                std.debug.print("\x1B[0;37m ", .{});
            } else {
                if (table[y][x] & 0x10 != 0) {
                    std.debug.print("\x1B[30;47m{d}\x1B[0;37m ", .{table[y][x] & 0xf});
                } else {
                    std.debug.print("{d} ", .{table[y][x] & 0xf});
                }
            }
        }
        std.debug.print("\n", .{});
    }
}

fn checkElement(table: [9][9]u5, i: u8, j: u8) bool {
    // const i = idx / 9;
    // const j = idx % 9;
    for (0..9) |a| {
        if (a == j) continue;
        if (table[i][j] & 0xf == table[i][a] & 0xf) {
            // table[i][j] += 1;
            std.debug.print("same element on row...\n", .{});
            // std.Thread.sleep(time);
            // idx -= 1;
            // continue :main_loop;
            return false;
        }
    }
    for (0..9) |a| {
        if (a == i) continue;
        if (table[i][j] & 0xf == table[a][j] & 0xf) {
            // table[i][j] += 1;
            std.debug.print("same element on column...\n", .{});
            // std.Thread.sleep(time);
            // idx -= 1;
            // continue :main_loop;
            return false;
        }
    }
    for (0..3) |a| {
        for (0..3) |b| {
            if (a == i % 3 and b == j % 3) continue;
            if (table[i][j] & 0xf == table[a + (i / 3) * 3][b + (j / 3) * 3] & 0xf) {
                // table[i][j] += 1;
                std.debug.print("same element on cell...\n", .{});
                // std.Thread.sleep(time);
                // idx -= 1;
                // continue :main_loop;
                return false;
            }
        }
    }
    return true;
}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    // var gpa = std.heap.DebugAllocator(.{});
    // const allocator = gpa.init;
    // defer allocator.deinit();
    // defer gpa.deinit();

    var table = try readTable("input.in");
    // var w: std.io.Writer = .fixed(&buffer);

    var idx: u8 = 0;
    const time: u64 = 100000;
    main_loop: while (true) {
        const i = idx / 9;
        const j = idx % 9;
        try displayTable(table, idx);
        std.debug.print("{d}:{d},{d}\nvalue: {d}\n", .{ idx, j, i, table[i][j] & 0xf });
        idx = (idx + 1);
        if (table[i][j] & 0x10 == 0) continue :main_loop;
        if (table[i][j] == 0x10) table[i][j] += 1;
        if (table[i][j] & 0xf > 9) {
            std.debug.print("need to backtrack...\n", .{});
            std.Thread.sleep(time);
            table[i][j] = 0x10;
            idx -= 2;
            while (table[idx / 9][idx % 9] & 0x10 == 0) idx -= 1;
            table[idx / 9][idx % 9] += 1;
            continue :main_loop;
        }
        if (!checkElement(table, i, j)) {
            table[i][j] += 1;
            std.Thread.sleep(time);
            idx -= 1;
            continue :main_loop;
        }

        std.Thread.sleep(time);
        if (idx == 81) break :main_loop;
    }
    // std.debug.print("\x1B[2J\x1B[H", .{});

    // reader.readSliceAll(&buffer) catch |err| std.debug.print("{}\n\n", .{err});
    // const len = try reader.stream(&w, .unlimited);
    // std.debug.print("\n\n{s}\n{d}\n", .{ buffer, len });
    // std.debug.print("size of table : {d}\n\n", .{@sizeOf(@TypeOf(table))});
    // std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // try sudoku_solver.bufferedPrint();
}
