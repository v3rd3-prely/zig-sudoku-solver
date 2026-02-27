const std = @import("std");
const sudoku_solver = @import("sudoku_solver");

pub fn main() !void {
    var table = try sudoku_solver.readTable("extreme.in");
    _ = &table;
    var solution: [9][9]u16 = undefined;

    std.debug.print("Solved: {any}\n", .{sudoku_solver.new_solve(&solution, &table)});

    sudoku_solver.displayTable(&solution, null);
    sudoku_solver.displayTable(&table, null);
}
