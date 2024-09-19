#!/bin/sh

WARMUPS=0
RUNS=10
PATTERN=TCAG
FILE=./data/02hgp10.txt

./search -R $RUNS $FILE $PATTERN | grep 'Run no.' | awk '{ print $5, $10  }' | tr -d ':' | tr ',' '.' > data.txt && gnuplot -c plot.gp data.txt plot.png
