# Mandatory Assignment 1: Task-based Parallel Computing in Java

> Group 7:
> 02158 Concurrent Programming

**Members:**

| Study nr. | Name                       |
|-----------|----------------------------|
| s215773   | Magnus August McCubbin     |
| s224792   | Javad Asgari Shafique      | 
| s224772   | Hjalte Cornelius Nannestad |

## Problem 1

Parameters:

```
PATTERN=TCAG
FILE=./data/02hgp10.txt
```

![](./images/problem-1-10.png)

Using `-W 2`

![](./images/problem-1-10-2.png)

Using `-W 4`

![](./images/problem-1-10-4.png)

![](./images/problem-1-50-2.png)

![](./images/problem-1-50-4.png)

![](./images/problem-1-50-25.png)

## Problem 2

> TODO: Explain this

```java
// Create list of tasks
List<SearchTask> taskList = new ArrayList<SearchTask>();

for(
int i = 0;
i<ntasks;i++){
int from = i * len / ntasks;
int to = (i + 1) * len / ntasks;
int realTo = Math.min(to + pattern.length - 1, len);
    taskList.

add(new SearchTask(text, pattern, from, realTo));
        }
```

```java
// Overall result is an ordered list of unique occurrence positions
result =new LinkedList<Integer>();
        for(
var future :futures)result.

addAll(future.get()); 
```

> TODO: Speedup %

Parameters:

```
WARMUPS=25
RUNS=50

PATTERN=xxxx
TASKS=16
FILE=./data/xtest.txt
```

![](./images/problem-2-single.png)
![](./images/problem-2-multi-1.png)
![](./images/problem-2-multi-2.png)
![](./images/problem-2-multi-16.png)

## Problem 3

Parameters:

```
PATTERN="world"
FILE=./data/100-0.txt
```

Hardware specs:

Mobile Ryzen 9 5900HX 8/16 3.3 GHz (4.6 GHz)

![](./images/problem-3-1.png)
![](./images/problem-3-2.png)
![](./images/problem-3-4.png)
![](./images/problem-3-16.png)

## Problem 4

![](./images/problem-4-speedup.png)

## Problem 5

Ran on 48-core HPC node.

![](./images/problem-5-speedup.png)