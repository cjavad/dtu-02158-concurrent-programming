# Documentation for execution and replicating results

> Requires bash/sh, gnuplot and java/javac.

We've wrapped the execution of `Search.java` into a shell script called `search` which compiles the file and runs it
with the given parameters.

To change the parameters we use for our testing, change them in `plot.sh` as seen in the top of the file.

Running `plot.sh` takes two arguments `NTASKS` and `NTHREADS` it runs in `-Ef` mode by default to support the
`plot_speedup.sh` script that plots the figures for the last part of the report.

It generates two outputs `single.png` and `multi.png` alongside adding to some average files that the other plot script
uses.

Running the `plot_speedup.sh` script is quite resource intensive as it runs through all the combinations of tasks and
threads based
on the upper limits defined in the script. It outputs `speedup.png`.

## Replicating results.

Refer to the parameter table in the report and configure `plot.sh` correctly. Remember to switch out `-Ef` with another
execution backend if necessary.

Primarily just run `plot.sh`, otherwise run `plot_speedup.sh` for the last two results.

For you convenience all the smaller outputs can be found in `artifacts` which have been generated with `artifacts.sh`

As an example from this directory you could run

```shell
./scripts/search -W 2 -R 10 ./data/xtest.txt xxxx
```

To just run the program.

```shell
./scripts/plot.sh ./data/xtest.txt xxxx 1 1 -Es
```

To run the program and get the plots.