# Zig Sudoku Solver

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Zig](https://img.shields.io/badge/Zig-0.15.2-orange.svg)](https://ziglang.org/)

A command-line program written in Zig that solves Sudoku puzzles using a backtracking algorithm. It reads puzzles from text files and outputs the solution.

## ✨ Features

- **Efficient Solving:** Uses a backtracking algorithm to find the solution for standard 9x9 Sudoku grids.
- **File Input:** Reads the initial puzzle state from a simple text file provided as a command-line argument.
- **Multiple Test Cases:** Includes sample puzzle files (`input.in`, `medium.in`, `extreme.in`) to demonstrate functionality.
- **Clear Output:** Prints the unsolved puzzle followed by the solved puzzle to the console.

## 🚀 Tech Stack

- **Language:** [Zig](https://ziglang.org/) (0.15.2)
- **Build System:** Zig Build System (`build.zig`)

## 📦 Installation & Setup

### Prerequisites

Ensure you have **Zig version 0.15.2** installed on your system. You can download it from the [official website](https://ziglang.org/download/) or use a version manager like [`zvm`](https://github.com/tristanisham/zvm).

### Steps

Instructions for cloning the repository and building the project using the Zig build system.
```bash
git clone https://github.com/v3rd3-prely/zig-sudoku-solver.git
cd zig-sudoku-solver
```
```bash
zig build
```

## 🎮 Usage

### Basic Usage

Run the compiled executable with a puzzle file as an argument.
```bash
./zig-out/bin/sudoku_solver <filepath>
```

### Examples

Commands for solving different puzzle files included in the repository (`input.in`, `medium.in`, `extreme.in`).

### Puzzle File Format
Input files should contain 81 characters (whitespaces and commas are not counted).
<br>
Any non-numeric character (except for those mentioned previously) is treated as an empty cell value.

### Sample Output

```bash
-----------------------
| 6 5 9 | 8 1 2 | 3 7 4
| 8 3 7 | 4 9 6 | 1 5 2
| 2 4 1 | 5 7 3 | 8 6 9
-----------------------
| 9 7 5 | 2 3 8 | 4 1 6
| 1 2 3 | 9 6 4 | 5 8 7
| 4 6 8 | 7 5 1 | 2 9 3
-----------------------
| 5 9 2 | 1 4 7 | 6 3 8
| 7 8 6 | 3 2 5 | 9 4 1
| 3 1 4 | 6 8 9 | 7 2 5

-----------------------
| 0 0 0 | 8 1 0 | 0 0 0
| 0 0 0 | 0 0 6 | 0 0 2
| 2 0 0 | 0 7 0 | 0 0 0
-----------------------
| 0 0 5 | 0 0 8 | 4 0 0
| 0 0 3 | 0 6 0 | 0 0 0
| 0 6 0 | 0 5 1 | 0 0 3
-----------------------
| 0 9 2 | 0 4 7 | 6 0 0
| 7 8 0 | 3 0 0 | 9 4 0
| 3 1 0 | 0 8 9 | 7 2 0
```

### Error Handling

The program provides error messages for common issues like missing files, invalid puzzle format, or unsolvable puzzles.

## 🗺️ Project Roadmap

- [x] Core backtracking solver
- [x] File input via command line argument
- [x] Support for Zig 0.15.2
- [ ] Parse Sudoku directly from an image
