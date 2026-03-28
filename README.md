# Fundamental Invariant (FI) Generator

Program for the generation of fundamental invariant.

Forked from [`kjshao/finn`](https://github.com/kjshao/finn).

Author: kjshao

Modifier: mizu-bai

## Build

Requirements: Intel's `ifort` compiler and MKL math library.

- With `make`

```
$ mkdir obj mod bin
$ make
```

- With `cmake`

```
$ mkdir build
$ cd build
$ FC=ifort .. -DCMAKE_BUILD_TYPE=Release
$ make
```

## Usage

Input file:

```
Number of atoms:
4
Labels of atoms:
A A A A
Degree and number of exit points:
5 1
Exit indices:
1
```

Run:

```
$ ./invariants < input.txt
```

## License

GPL-3.0 license
