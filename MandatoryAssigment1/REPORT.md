# Mandatory Assignment 1: Task-based Parallel Computing in Java

> Group 7:
> 02158 Concurrent Programming

**Members:**

| Study nr. | Name                       |
|-----------|----------------------------|
| s215773   | Magnus August McCubbin     |
| s224792   | Javad Asgari Shafique      | 
| s224772   | Hjalte Cornelius Nannestad |

For this assigment we've decided to include the 3 recommend files as test cases,
in this report we'll refer to them by their name as seen in the following table
together with the pattern we've used for the search.

| File name   | Description                           |
|-------------|---------------------------------------|
| 02hgp10.txt | Human Genome Project                  |
| 100-0.txt   | Complete works of William Shakespeare |
| xtest.txt   | Text from problem 2                   |

Primarily the tests were run on a Ryzen 9 5900HX 8/16 3.3 GHz (4.6 GHz) laptop processor.

For plots, we decided to go with gnuplot to automate the process of generating plots.
See the attached GitHub repository for the scripts used to generate the
plots: <https://github.com/cjavad/dtu-02158-concurrent-programming>.

## Problem 1

Attempting to find a pattern that took a significant amount of time (greater than 0.1 seconds) using a combination
of the data files we used was not feasible without using patterns that yielded no results, but we decided on a pattern
with a small amount of results anyway. We decided to use 50 runs, this will give us better measurements of the average
speedup
and other average values later on.

| Parameter | Value       |
|-----------|-------------|
| PATTERN   | TCAGGGG     |
| FILE      | 02hgp10.txt |
| RUNS      | 50          |
| WARMUPS   | 0           |
| EXECUTOR  | Single      |

![](./images/problem-1-50.png)

Running the search with no warmups shows a small startup cost that nearly doubles the time it took to search for the
pattern
in a single go. This can be attributed to many factors, including the startup cost of Java, memory allocation and other
factors.

| Parameter | Value       |
|-----------|-------------|
| PATTERN   | TCAGGGG     |
| FILE      | 02hgp10.txt |
| RUNS      | 50          |
| WARMUPS   | 25          |
| EXECUTOR  | Single      |

![](./images/problem-1-50-25.png)

Using a warmup parameter of 25, the variance has been smoothed out to less than 0.01 seconds.

We had additionally performed tests on combinations of 10 runs with 2 and 4 warmups and 2, 4 and 8 warmups with 50
runs but found this combination made the most sense for accurate results.

## Problem 2

> TODO: Explain this (Including how we ensure we get the correct results)

```
// Create list of tasks
List<SearchTask> taskList = new ArrayList<SearchTask>();

for (int i = 0; i < ntasks; i++) {
    int from = i * len / ntasks;
    int to = (i + 1) * len / ntasks;
    int realTo = Math.min(to + pattern.length - 1, len);
    taskList.add(new SearchTask(text, pattern, from, realTo));
}
```

```
// Overall result is an ordered list of unique occurrence positions
result = new LinkedList<Integer>();
for (var future : futures)
        result.addAll(future.get()); 
```

> TODO: Explain "Average speedup%" and how it is calculated and how we can use it.

> TODO: Explain if the speedup we measured is what we expected. We are running multiple tasks on one thread.

| Parameter | Value      |
|-----------|------------|
| PATTERN   | xxxx       |
| FILE      | xtest.txt  |
| TASKS     | 0 (Single) |
| RUNS      | 50         |
| WARMUPS   | 25         |
| EXECUTOR  | Single     |

![](./images/problem-2-single.png)

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | xxxx      |
| FILE      | xtest.txt |
| TASKS     | 1         |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Single    |

![](./images/problem-2-multi-1.png)

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | xxxx      |
| FILE      | xtest.txt |
| TASKS     | 2         |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Single    |

![](./images/problem-2-multi-2.png)

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | xxxx      |
| FILE      | xtest.txt |
| TASKS     | 16        |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Single    |

![](./images/problem-2-multi-16.png)

## Problem 3

Previously we had only had the ability to take advantage of a single OS thread
using the "Cached" executor each task now has its own thread to run on.
Since we are running on a machine with 8 physical cores and 16 logical cores (amount of different stack contexts the CPU
can keep track of at once) simple math might dictate we should expect a speedup of at least 8x.

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | world     |
| FILE      | 100-0.txt |
| TASKS     | 1         |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Cached    |

![](./images/problem-3-1.png)

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | world     |
| FILE      | 100-0.txt |
| TASKS     | 2         |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Cached    |

![](./images/problem-3-2.png)

Comparing the speedup of 1 task vs 2 tasks we see an approximate speedup of 1.5x,
this is a bit less than the expected 2x speedup so how come?

Beyond the fact that the actual implementation of the Java code might have some overhead and non-paralellizable parts
the actual thread we are running does not always get 100% of the CPU time, and even more often the hungrier a thread the
less CPU time the OS scheduler will give it.

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | world     |
| FILE      | 100-0.txt |
| TASKS     | 4         |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Cached    |

![](./images/problem-3-4.png)

Doubling the amount of tasks (and threads) it does seem that we are getting a similar "doubling" in speedup, going from
the original 1.5x speed to near 3x.

| Parameter | Value     |
|-----------|-----------|
| PATTERN   | world     |
| FILE      | 100-0.txt |
| TASKS     | 16        |
| RUNS      | 50        |
| WARMUPS   | 25        |
| EXECUTOR  | Cached    |

![](./images/problem-3-16.png)

Now using the same amount of threads as the CPU has logical processing units, we see even in the best runs
the speedup was "only" double that of the 4 task/thread run, going on 0.01 seconds to half of that with 0.005 seconds.
This does seem to reflect the fact the CPU only has 8 physical cores, which is the actual representation of the amount
of physical
components it has to perform operations such as comparisons and memory access. If we consider the worst runs with 1
thread and the best runs with 16 threads the maximum point to point speedup is only 8x.

Going beyond this amount of tasks/threads the average speedup plateaus at around a total of 5x and even decreases at
some points
due to the nondeterministic nature of the operating system scheduler.

## Problem 4

Using a fixed thread pool executor, which in theory should reduce a lot of the overhead that comes
from creating and starting a new thread we can visualize the total average speedup in relation to the amount of tasks
(to overwork the threads to achieve maximum throughput) in proportion to the amount of threads which can reflect the
systems overall capability.

| Parameter | Value            |
|-----------|------------------|
| PATTERN   | world            |
| FILE      | 100-0.txt        |
| TASKS     | 1,2,4,8,16,32,64 |
| THREADS   | 1,2,4,8,16       |
| RUNS      | 50               |
| WARMUPS   | 25               |
| EXECUTOR  | Fixed            |

![](./images/problem-4-speedup.png)

Executions that only have 1 thread seems to approximate an average speedup of 1x, which is expected.
The same actually goes for 2 threads, and even 4 threads where the average speedup is linearly increasing
with some relative factor of 1.5x perhaps due to the nature of the operating system, shared physical hardware and other
nondeterministic factors.

Once we reach 8 and 16 threads things seem to stop increasing, but with more tasks than threads it does seem that
throughput keeps on going up. This is likely happening since with more work to do, the less "starved" the threads are,
so they'll be able to perform work as soon as they are allowed to.

## Problem 5


> TODO: Write this.

Ran on 48-core HPC node.

| Parameter | Value                    |
|-----------|--------------------------|
| PATTERN   | world                    |
| FILE      | 100-0.txt                |
| TASKS     | 1,2,4,8,16,32,64,128,256 |
| THREADS   | 1,2,4,8,16,32,64         |
| RUNS      | 50                       |
| WARMUPS   | 25                       |
| EXECUTOR  | Fixed                    |

![](./images/problem-5-speedup.png)

## Conclusion

> TODO: Write this.
