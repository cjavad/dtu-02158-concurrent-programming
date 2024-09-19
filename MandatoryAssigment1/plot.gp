# Arguments passed to the script: $0 is the script, $1 is the data file
datafile = ARG1
outfile = ARG2

# Set output to PNG
set terminal pngcairo size 800,600
set output outfile

# Set plot title and labels
set title "Single Task: Run Times"
set xlabel "Run Number"
set ylabel "Time (seconds)"

# Enable grid
set grid

# Plot data from the provided file, using the first and second columns
plot datafile using 1:2 with linespoints title "Run Time" lw 2 pt 7

# Close output
unset output

