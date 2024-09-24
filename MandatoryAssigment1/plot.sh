#!/bin/sh

# These settings cannot be changed.
WARMUPS=25
RUNS=50

# Change these.
PATTERN="world"
TASKS=1
THREADS=1
FILE=./data/100-0.txt

# Allow task and threads to come from command line
if [ "$#" -eq 2 ]; then
    TASKS=$1
    THREADS=$2
fi

echo "Running with $TASKS tasks and $THREADS threads in Fixed Mode"

IFS=$'\n' data=( $(./search -Ef -W $WARMUPS -R $RUNS $FILE $PATTERN $TASKS $THREADS) )

truncate -s 0 single.txt
truncate -s 0 multi.txt

for i in "${data[@]}"
do
    echo $i

    # Parse line 'Single task: Run no. 47: 30553 occurrences found in 0,031074 s'
    if [[ $i == *"Single task: Run no."* ]]; then
        echo $i | awk '{ print $5, $10  }' | tr -d ':' | tr ',' '.' >> single.txt
    fi

    # Parse line 'Using  $TASKS tasks: Run no.  0: 30553 occurrences found in 0,032900 s'
    if [[ $i == *"tasks: Run no."* ]]; then
        echo $i | awk '{ print $6, $11  }' | tr -d ':' | tr ',' '.' >> multi.txt
    fi

    # Parse line: Single task (avg.): 0,034048 s
    if [[ $i == *"Single task (avg.):"* ]]; then
        echo "SINGLE $PATTERN $FILE" $(echo -n $i | awk '{ print $4  }' | tr -d ':' | tr ',' '.') >> avg_single.txt
    fi

    # Parse line: Using 16 tasks (avg.): 0,006741 s
    if [[ $i == *"tasks (avg.):"* ]]; then
        echo "MULTI $PATTERN $FILE $TASKS $THREADS" $(echo -n $i | awk '{ print $5  }' | tr -d ':' | tr ',' '.') >> avg_multi.txt
    fi

    # Parse line: Average speedup: 5,05
    if [[ $i == *"Average speedup:"* ]]; then
        echo "$TASKS $THREADS" $(echo -n $i | awk '{ print $3  }' | tr -d ':' | tr ',' '.') >> speedup.txt
    fi

done

gnuplot -c plot.gp single.txt single_plot.png "Single task"
gnuplot -c plot.gp multi.txt multi_plot.png "$TASKS tasks"