# Fish Scripts

This repo contains useful fish scripts I created

## How to use

Copy the scripts you would like to use to `/usr/local/bin`.

## Projects

### ero.fish

- Helpful for competitive programming.
- Compiles, runs and tests your cpp code against predefined input and answer files.
- Input `.in*` and answer `.ans*` files must have the same name as the cpp file and must be numbered:

```
fibonacci.cpp fibonacci.in1 fibonacci.in2 fibonacci.ans1 fibonacci.ans2
```

- Usage: `ero fibonacci.cpp`

- Simply run `ero --help` to get started.

### output.fish

- Lightweight version of the `diff` command in linux

- Usage: `output one.txt two.txt`

### sigmean.fish

- Simple script that accepts a signal number or name and prints out what the abbrievation stands for.
- Example:

```
sigmean 139
[SIGSEGV] Segmentation fault
```

## License

This project is licensed under the terms of the GNU license.
A copy of the license can be found in the root directory of
the project in the file [LICENSE](./LICENSE).
