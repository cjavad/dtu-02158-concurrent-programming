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

![](./images/chromesome-search-r-10.png)

Use `-W 2`

## Problem 2

```java
// Create list of tasks
List<SearchTask> taskList = new ArrayList<SearchTask>();

for (int i = 0; i < ntasks; i++) {
    int from = i * len / ntasks;
    int to = (i + 1) * len / ntasks;
    int realTo = Math.min(to + pattern.length - 1, len);
    taskList.add(new SearchTask(text, pattern, from, realTo));
}
```

```java
// Overall result is an ordered list of unique occurrence positions
result = new LinkedList<Integer>();
for (var future : futures) result.addAll(future.get()); 
```

## Problem 3

## Problem 4

## Problem 5
