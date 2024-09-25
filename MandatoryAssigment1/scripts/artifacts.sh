#!/bin/sh

SCRIPTDIR=$(dirname $0)
cd $SCRIPTDIR/../

rm -rf artifacts
mkdir -p artifacts

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

build_plot "problem-1-50-25" "./data/02hgp10.txt" "TCAGGGG" 1 1 "-Es"

build_plot "problem-2-multi-1" "./data/xtest.txt" "xxxx" 1 1 "-Es"
build_plot "problem-2-multi-2" "./data/xtest.txt" "xxxx" 2 1 "-Es"
build_plot "problem-2-multi-16" "./data/xtest.txt" "xxxx" 16 1 "-Es"

build_plot "problem-3-1" "./data/100-0.txt" "world" 1 1 "-Ec"
build_plot "problem-3-2" "./data/100-0.txt" "world" 2 2 "-Ec"
build_plot "problem-3-4" "./data/100-0.txt" "world" 4 4 "-Ec"
build_plot "problem-3-16" "./data/100-0.txt" "world" 16 16 "-Ec"
