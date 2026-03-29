# Fundamental Invariant (FI) Generator

[![zread](https://img.shields.io/badge/Ask_Zread-_.svg?style=flat&color=00b0aa&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQuOTYxNTYgMS42MDAxSDIuMjQxNTZDMS44ODgxIDEuNjAwMSAxLjYwMTU2IDEuODg2NjQgMS42MDE1NiAyLjI0MDFWNC45NjAxQzEuNjAxNTYgNS4zMTM1NiAxLjg4ODEgNS42MDAxIDIuMjQxNTYgNS42MDAxSDQuOTYxNTZDNS4zMTUwMiA1LjYwMDEgNS42MDE1NiA1LjMxMzU2IDUuNjAxNTYgNC45NjAxVjIuMjQwMUM1LjYwMTU2IDEuODg2NjQgNS4zMTUwMiAxLjYwMDEgNC45NjE1NiAxLjYwMDFaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00Ljk2MTU2IDEwLjM5OTlIMi4yNDE1NkMxLjg4ODEgMTAuMzk5OSAxLjYwMTU2IDEwLjY4NjQgMS42MDE1NiAxMS4wMzk5VjEzLjc1OTlDMS42MDE1NiAxNC4xMTM0IDEuODg4MSAxNC4zOTk5IDIuMjQxNTYgMTQuMzk5OUg0Ljk2MTU2QzUuMzE1MDIgMTQuMzk5OSA1LjYwMTU2IDE0LjExMzQgNS42MDE1NiAxMy43NTk5VjExLjAzOTlDNS42MDE1NiAxMC42ODY0IDUuMzE1MDIgMTAuMzk5OSA0Ljk2MTU2IDEwLjM5OTlaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik0xMy43NTg0IDEuNjAwMUgxMS4wMzg0QzEwLjY4NSAxLjYwMDEgMTAuMzk4NCAxLjg4NjY0IDEwLjM5ODQgMi4yNDAxVjQuOTYwMUMxMC4zOTg0IDUuMzEzNTYgMTAuNjg1IDUuNjAwMSAxMS4wMzg0IDUuNjAwMUgxMy43NTg0QzE0LjExMTkgNS42MDAxIDE0LjM5ODQgNS4zMTM1NiAxNC4zOTg0IDQuOTYwMVYyLjI0MDFDMTQuMzk4NCAxLjg4NjY0IDE0LjExMTkgMS42MDAxIDEzLjc1ODQgMS42MDAxWiIgZmlsbD0iI2ZmZiIvPgo8cGF0aCBkPSJNNCAxMkwxMiA0TDQgMTJaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00IDEyTDEyIDQiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8L3N2Zz4K&logoColor=ffffff)](https://zread.ai/CQPES/Fundamental-Invariant-Generator)

Program for the generation of fundamental invariant.

Forked from [`kjshao/finn`](https://github.com/kjshao/finn).

Author: kjshao

Modifier: mizu-bai

## Build

Requirements: Intel's `ifort` compiler and MKL math library.

- With `make`

```bash
$ mkdir obj mod bin
$ make
```

- With `cmake`

```bash
$ mkdir build
$ cd build
$ FC=ifort .. -DCMAKE_BUILD_TYPE=Release
$ make
```

## Usage

### Generate New FIs

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

```bash
$ ./invariants < input.txt
```

Use the environment variable `MKL_NUM_THREADS` to control parallelism in the `dgels` subroutine.

### Convert to JaxPIP Compatible JSON

**NOTE: ALL FIS START FROM CONSTANT 1.0 TO KEEP COMPATIBILITY WITH MSA'S STYLE!!!**

```bash
$ python3 utils/dat_polys2json.py -h
usage: dat_polys2json.py [-h] -n NUM_ATOMS [--gz] dat_polys json_file

Convert FI dat.polys to JaxPIP .json

positional arguments:
  dat_polys             Path to input dat.polys file
  json_file             Path to output json file, recommend 'FI_AxByCz.json.gz'

options:
  -h, --help            show this help message and exit
  -n NUM_ATOMS, --num_atoms NUM_ATOMS
                        Number of atoms
  --gz                  Compress with gzip
$ python3 utils/dat_polys2json.py /path/to/dat.polys [/path/to/FI.json | /path/to/FI.json.gz] [--gz]
$ jaxpip show [/path/to/FI.json | /path/to/FI.json.gz]
```

## License

GPL-3.0 License
