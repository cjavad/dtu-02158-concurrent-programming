datafile = ARG1
outfile = ARG2
tasks_count = ARG3  # Number of tasks (like 7)
threads_count = ARG4  # Number of threads (like 5 for up to 32 threads, or 7 for up to 128 threads)

# Set output to PNG
set terminal pngcairo size 800,600
set output outfile

set title "Speedup vs Tasks for Different Threads"
set xlabel "Tasks"
set ylabel "Speedup"
set key left top
set grid

# Set x as power of 2
# set logscale x 2

# Dynamic plot generation
plot for [i=0:threads_count-1] datafile using 1:3 every ::(i*tasks_count)::((i+1)*tasks_count-1) title sprintf('Threads = %d', 2**i) with linespoints
