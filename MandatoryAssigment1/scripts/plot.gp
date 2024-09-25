# Arguments passed to the script: $0 is the script, $1 is the data file
datafile = ARG1
outfile = ARG2
name = ARG3

# Set output to PNG
set terminal pngcairo size 800,600
set output outfile

# Set plot title and labels
set title name . ": Run Times"
set xlabel "Run Number"
set ylabel "Time (seconds)"
# Ensure Y-axis starts at 0
set yrange [0:]
set xrange [0:]

# Enable grid
set grid

# Plot data from the provided file, using the first and second columns
plot datafile using 1:2 with linespoints title "Run Time" lw 2 pt 7


# Close output
unset output

