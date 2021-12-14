## What is this repository about?

This repository is a modified version of the [SV-Comp](https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks) repo.

## How to run benchmarks?

``` sh
mkdir build; cd build
cmake -DSEAHORN_ROOT=<SEAHORN_RUN_DIRECTORY> -DSEA_CONFIG=../sea.yaml ../
ctest -R
```

To run a single benchmark, use

``` sh
ctest -R <test name>
```
