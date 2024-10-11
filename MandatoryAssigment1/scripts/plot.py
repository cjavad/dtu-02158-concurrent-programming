import functools
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

DIR = Path(__file__).parent.parent

ARTIFACT_DIR = DIR / 'artifacts'
DATA_DIR = DIR / 'data'
BUILD_DIR = DIR / 'build'
SEARCH_BIN = BUILD_DIR / 'search'
SCRIPT_DIR = DIR / 'scripts'

ARTIFACT_DIR.mkdir(exist_ok=True)
BUILD_DIR.mkdir(exist_ok=True)


def build_java_program():
    subprocess.check_output(['javac', '-d', BUILD_DIR, DIR / 'src/Search.java'])


def cleanup():
    # Delete artificats and speedup.txt
    shutil.rmtree(ARTIFACT_DIR, ignore_errors=True)
    (DIR / "speedup.txt").unlink(missing_ok=True)


def run_search_speedup(
        pattern: str,
        warmup: int,
        runs: int,
        file: Path | str,
        executor: str = 's',
        # Calculate as 2^x, where x is the number of tasks starting from 0 to 7
        max_task_n: int = 7,
        # Calculate as 2^x, where x is the number of threads starting from 0 to 5
        max_thread_n: int = 5,
        plot_name=None,
):
    (DIR / "speedup.txt").unlink(missing_ok=True)

    for thread_i in range(0, max_thread_n):
        for task_i in range(0, max_task_n):
            task_n = 2 ** task_i
            thread_n = 2 ** thread_i

            run_search(
                pattern, warmup, runs, file, executor, task_n, thread_n, None, False
            )

    subprocess.check_output([
        'gnuplot',
        '-c',
        str(SCRIPT_DIR / 'speedup.gp'),
        str(DIR / 'speedup.txt'),
        str(ARTIFACT_DIR / (plot_name + '.png')),
        str(max_task_n),
        str(max_thread_n),
    ])


def parse_output(p: str):
    # Parse lines 'Single task: Run no. 47: 30553 occurrences found in 0,031074 s'
    single_task_match = re.findall(r'Single task: Run no.\s*(\d+):\s*\d+ occurrences found in\s*([\d,]+) s', p,
                                   re.MULTILINE)
    # Map run no. and duration (parse comma as decimal separator)
    single_task = [(int(a), float(b.replace(',', '.'))) for (a, b) in single_task_match]

    # Parse lines 'Using  $TASKS tasks: Run no.  0: 30553 occurrences found in 0,032900 s'
    multi_task_match = re.findall(r'Using\s*(\d+) tasks: Run no.\s*(\d+):\s*\d+ occurrences found in ([\d,]+) s', p,
                                  re.MULTILINE)

    multi_task_task_count = [int(a) for (a, _, _) in multi_task_match][0]
    # Map run no., duration and number of tasks (parse comma as decimal separator)
    multi_task = [(int(a), float(b.replace(',', '.'))) for (_, a, b) in multi_task_match]

    # Parse line: Single task (avg.): 0,034048 s
    single_task_avg_match = re.search(r'Single task \(avg.\):\s*([\d,]+) s', p)
    single_task_avg = float(single_task_avg_match.group(1).replace(',', '.'))

    # Parse line: Using 16 tasks (avg.): 0,006741 s
    multi_task_avg_match = re.search(r'Using\s*(\d+) tasks \(avg.\):\s*([\d,]+) s', p)
    multi_task_avg = float(multi_task_avg_match.group(2).replace(',', '.'))

    return single_task, multi_task, multi_task_task_count, single_task_avg, multi_task_avg


def run_search(
        pattern: str,
        warmup: int,
        runs: int,
        file: Path | str,
        executor: str = 's',
        ntasks=0,
        nthreads=0,
        plot_name=None,
        plot_single=True,
):
    if plot_name and (ARTIFACT_DIR / (plot_name + '.png')).exists():
        print(f"Skipping {plot_name} as it already exists")
        return

    args = []

    if warmup > 0:
        args.append("-W")
        args.append(str(warmup))

    if runs > 0:
        args.append("-R")
        args.append(str(runs))

    args.append(f'-E{executor}')

    rest = []

    if ntasks > 0:
        rest.append(f'{ntasks}')

    if nthreads > 0:
        rest.append(f'{nthreads}')

    cli = [
        'java',
        '-classpath',
        str(BUILD_DIR),
        'Search',
        *args,
        str(file),
        pattern,
        *rest
    ]

    print(f"Running search {pattern=} {warmup=} {runs=} {file=} {executor=} {ntasks=} {nthreads=}")

    p = subprocess.check_output(cli, stderr=subprocess.STDOUT).decode('utf-8')
    # Parse line: Average speedup: 5,05
    speedup_match = re.search(r'Average speedup:\s*([\d,]+)', p)
    speedup = float(speedup_match.group(1).replace(',', '.'))

    with open(DIR / 'speedup.txt', 'a') as f:
        f.write(f"{ntasks} {nthreads} {speedup}\n")

    if plot_name is None:
        return

    single_task, multi_task, multi_task_task_count, single_task_avg, multi_task_avg = parse_output(p)

    # Write output as plot_name.txt
    with open(ARTIFACT_DIR / (plot_name + '.txt'), 'w') as f:
        f.write(p)

    with tempfile.NamedTemporaryFile(mode='w') as plotfile:
        for run, duration in (single_task if plot_single else multi_task):
            plotfile.write(f'{run} {duration}\n')

        plotfile.flush()

        subprocess.check_output([
            'gnuplot',
            '-c',
            str(SCRIPT_DIR / 'plot.gp'),
            plotfile.name,
            str(ARTIFACT_DIR / (plot_name + '.png')),
            "Single task" if plot_single else f"{multi_task_task_count} tasks"
        ])


def combine_plots(plot_legend: str, plot_name: str, plot_single=False, *outputs: str):
    with tempfile.NamedTemporaryFile(mode='w') as plotfile, tempfile.NamedTemporaryFile(mode='w') as line_names_file:
        # Offset to give gnuplot script.
        l = None
        line_names = []

        for output in outputs:
            data = (ARTIFACT_DIR / (output + '.txt')).read_text()
            # parse data
            single_task, multi_task, multi_task_task_count, single_task_avg, multi_task_avg = parse_output(data)
            tasks = (single_task if plot_single else multi_task)

            if l is None:
                l = len(tasks)

            assert (l == len(tasks))

            for run, duration in tasks:
                plotfile.write(f'{run} {duration}\n')

            line_names.append(f"{multi_task_task_count}-tasks")

        plotfile.flush()

        line_names_file.write(' '.join(line_names) + '\n')

        line_names_file.flush()

        subprocess.check_output([
            'gnuplot',
            '-c',
            str(SCRIPT_DIR / 'plot_multiple.gp'),
            str(plotfile.name),
            str(ARTIFACT_DIR / (plot_name + '.png')),
            str(line_names_file.name),
            str(l),
            str(len(line_names)),
            plot_legend
        ])


def generate_artifacts():
    # Long pattern from 02hgp10.txt
    long_pattern = "CACGCCTGTAATCTCAGTATTTTGGGAGGCTGAGATGGGTGGATCACCAGAGGTCAGGAG\r\nTTCGGGACCAGCCTGTCCAATATGGTAAAACCCCGTCTCTACTAAAAATCTGCTCCCCCC"
    warmups = 5
    runs = 10

    problem2 = functools.partial(run_search, pattern=long_pattern, warmup=warmups, runs=runs,
                                 file=DATA_DIR / '02hgp10.txt',
                                 executor='s')
    problem2(ntasks=1, nthreads=1, plot_name="problem-2-multi-1", plot_single=False)
    problem2(ntasks=2, nthreads=1, plot_name="problem-2-multi-2", plot_single=False)
    problem2(ntasks=16, nthreads=1, plot_name="problem-2-multi-16", plot_single=False)

    problem3 = functools.partial(run_search, pattern=long_pattern, warmup=warmups, runs=runs,
                                 file=DATA_DIR / '02hgp10.txt',
                                 executor='c')
    problem3(ntasks=1, nthreads=1, plot_name="problem-3-1", plot_single=False)
    problem3(ntasks=2, nthreads=2, plot_name="problem-3-2", plot_single=False)
    problem3(ntasks=4, nthreads=4, plot_name="problem-3-4", plot_single=False)
    problem3(ntasks=16, nthreads=16, plot_name="problem-3-16", plot_single=False)
    problem3(ntasks=32, nthreads=32, plot_name="problem-3-32", plot_single=False)
    problem3(ntasks=64, nthreads=64, plot_name="problem-3-64", plot_single=False)
    problem3(ntasks=128, nthreads=128, plot_name="problem-3-128", plot_single=False)

    run_search_speedup(
        long_pattern,
        5, 10,
        DATA_DIR / '02hgp10.txt',
        'f',
        plot_name="problem4"
    )

    # To be run on HPC node.
    run_search_speedup(
        long_pattern,
        5, 10,
        DATA_DIR / '02hgp10.txt',
        'f',
        max_task_n=9,
        max_thread_n=7,
        plot_name="problem5"
    )


combine_plots("Single Executor with multiple tasks", "problem-2-multi", False, "problem-2-multi-1", "problem-2-multi-2", "problem-2-multi-16")
combine_plots("Cached executor with multiple tasks", "problem-3-multi", False, "problem-3-1", "problem-3-2", "problem-3-4", "problem-3-16", "problem-3-32",
              "problem-3-64", "problem-3-128")
