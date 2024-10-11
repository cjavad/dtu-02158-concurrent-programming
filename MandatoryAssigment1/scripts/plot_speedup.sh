#!/bin/sh

SCRIPTDIR=$(dirname $0)
cd $SCRIPTDIR/../

truncate -s 0 speedup.txt

for THREAD_I in $(seq 0 $(($THREAD_N-1))); do
  for TASK_I in $(seq 0 $(($TASK_N-1))); do
    THREAD_X=$((2**$THREAD_I))
    TASK_X=$((2**$TASK_I))

    $SCRIPTDIR/plot.sh $TASK_X $THREAD_X
  done
done

gnuplot -c $SCRIPTDIR/speedup.gp speedup.txt speedup.png $TASK_N $THREAD_N