## Evaluation status
[Link](https://docs.google.com/spreadsheets/d/1xg8Sr8hcrxKQ8ERlcXY65jWpNdrWGZ1OlyihK1snw78/edit?usp=sharing)
## What is this repository about?

This repository is a modified version of the [SV-Comp](https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks) repo.
It is modified in the following ways.

1. Only some directories have been imported. This is to keep repo size small (Original repo is ~ 12GiB)
2. The `makefile` build system has been enhanced to support building C sources for SEAHORN
3. A `verify-seahorn.sh` script has been added to run SEAHORN on a directory

## How to compile a single C source file (benchmark) for SEAHORN?

We assume that a file `byte_add-2.c` exists.

```sh
cd bitvector
make CC=clang-10 EMIT_LLVM=1 byte_add-2.sea.bc
```
This creates a bitcode file of the given name in the `bin/bitvector` directory.

>Tip: You can add VERBOSE=1 to see the commands being executed 
>Tip: The `LLVM_LINK` tool name can be changed in `Makefile.config` 

## How to run SEAHORN on all benchmarks in the `bitvector` directory?

``` sh
./verify-seahorn bitvector <directory where sea exists>
```

## Where is the bitcode file located?

It is located in the `bin` directory which is generated as part of the build process.

## What should I know about the build process?

The `lib/seahorn` directory contains a file which stubs out functions of interest with SEAHORN variants.

## How do I add more benchmarks to be run by SEAHORN?

One can copy a benchmark directory of interest from the original repo and things should just work.
