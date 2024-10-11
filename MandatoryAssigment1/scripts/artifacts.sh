#!/bin/sh

SCRIPTDIR=$(dirname $0)
cd $SCRIPTDIR/../

rm -rf artifacts
mkdir -p artifacts

LONG_PATTERN=$(< ./data/02hgp10-pattern.txt)
# Build all artifacts.
function build_plot() {
  NAME=$1
  shift
  ARGS=$@
  $SCRIPTDIR/plot.sh $ARGS > artifacts/$NAME.txt

  # If args 3 is greater than 0 save multi otherwise single.
  if [ $3 -gt 0 ]; then
    cp multi_plot.png artifacts/$NAME-multi.png
  else
    cp single_plot.png artifacts/$NAME-single.png
  fi
}

build_plot "problem-1-50-25" "./data/02hgp10.txt" "$LONG_PATTERN" 1 1 "-Es"

build_plot "problem-2-multi-1" "./data/02hgp10.txt" "$LONG_PATTERN" 1 1 "-Es"
build_plot "problem-2-multi-2" "./data/02hgp10.txt" "$LONG_PATTERN" 2 1 "-Es"
build_plot "problem-2-multi-16" "./data/02hgp10.txt" "$LONG_PATTERN" 16 1 "-Es"

build_plot "problem-3-1" "./data/02hgp10.txt" "$LONG_PATTERN" 1 1 "-Ec"
build_plot "problem-3-2" "./data/02hgp10.txt" "$LONG_PATTERN" 2 2 "-Ec"
build_plot "problem-3-4" "./data/02hgp10.txt" "$LONG_PATTERN" 4 4 "-Ec"
build_plot "problem-3-16" "./data/02hgp10.txt" "$LONG_PATTERN" 16 16 "-Ec"
