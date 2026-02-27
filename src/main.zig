const std = @import("std");
const solver = @import("sudoku_solver");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer switch (gpa.deinit()) {
        .leak => std.debug.print("Allocator leak.\n", .{}),
        // .ok => std.debug.print("All good.\n", .{}),
        .ok => {},
    };
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    // _ = &gpa;
    // for (args, 0..) |arg, i| {
    //     std.debug.print("{d}: {s}\n", .{ i, arg });
    // }
    if (args.len < 2) {
        std.debug.print("no filepath given\n", .{});
    }
    var table = try solver.readTable(args[1]);
    _ = &table;
    var solution: [9][9]u16 = undefined;

    std.debug.print("Solved: {any}\n", .{solver.new_solve(&solution, &table)});

    solver.displayTable(&solution, null);
    solver.displayTable(&table, null);
}
