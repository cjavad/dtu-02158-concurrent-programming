# Arguments passed to the script:
# $1 is the data file
# $2 is the output file
# $3 is the file with line names (one name per line)
# $4 is the length of a single dataset (number of points per dataset)
# $5 is the count of datasets (how many datasets)

datafile = ARG1
outfile = ARG2
namesfile = ARG3
dataset_length = int(ARG4)
dataset_count = int(ARG5)
plot_title = ARG6

# Set output to PNG
set terminal pngcairo size 800,600
set output outfile

# Set plot title and labels
# Set legend position to middle right
set key at graph 1, graph 0.5
set key right center

set title plot_title
set xlabel "Run Number"
set ylabel "Time (seconds)"
# Ensure Y-axis starts at 0
set yrange [0:]
set xrange [0:]

# Enable grid
set grid

# Read the names for each dataset from the namesfile
names = system(sprintf("cat %s", namesfile))

# Initialize the plot command
plot_command = ''

# Loop over each dataset to build the plot command
do for [i=0:(dataset_count-1)] {
    # Compute start and end lines for the current dataset
    start_line = i * dataset_length
    end_line = (i + 1) * dataset_length - 1

    # Construct the 'every' command
    every_cmd = sprintf("every ::%d::%d", start_line, end_line)

    # Get the title for the current dataset
    title_str = word(names, i+1)

    # Build the plot command for the current dataset
    single_plot = sprintf("'%s' %s using 1:2 with linespoints title '%s' lw 2 pt 7", datafile, every_cmd, title_str)

    # Append to the overall plot command
    if (i == 0) {
        plot_command = single_plot
    } else {
        plot_command = plot_command . ',' . single_plot
    }
}

# Execute the constructed plot command
eval('plot ' . plot_command)

# Close output
unset output