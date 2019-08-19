# Reduction Mode Examples

This example is to clarify the difference between how default reduction and running reduction work. Imagine the extract from each classification produces a number from 0 to 10 and the reducer computes the average of these numbers.

The same extracts are processed by each reducer in the same order and we illustrate the changing values in the system as they arrive. For clarity, the values of extracts are indicated in bold.

## Default Reduction

| Extract ID | Extract Value | Extracts to reducer | Store Value In | Calculation | Store Value | Items in Association |
|------------|---------------|---------------------|----------------|-------------|-------------|----------------------|
| 1 | **5** | 1 | nil | **5**/1 | nil | 0 |
| 2 | **3** | 1, 2 | nil | (**5**+**3**)/2 | nil | 0 |
| 2 | **3** | 1, 2 | nil | (**5**+**3**)/2 | nil | 0 |
| 3 | **4** | 1, 2, 3 | nil | (**5**+**3**+**4**)/3 | nil | 0 |


## Running Reduction

| Extract ID | Extract Value | Extracts to reducer | Store Value In | Calculation | Store Value | Items in Association |
|------------|---------------|---------------------|----------------|-------------|-------------|----------------------|
| 1 | **5** | 1 | nil | (0*0+**5**)/(0+1) | 1 | 1 |
| 2 | **3** | 2 | 1 | (5*1+**3**)/(1+1) | 2 | 2 |
| 2 | **3** | nil | N/A | N/A | 2 | 2 |
| 3 | **4** | 3 | 2 | (4*2+**4**)/(2+1) | 3 | 3 |

## Points of Note

Note that in default reduction mode, re-reduction is always triggered, regardless of whether an extract is being processed twice. Also notice that each computation in default reduction consumes all of the extracts. We calculate an average by summing together the values of all of the extracts and then dividing by the number of extracts.

In running reduction, on the other hand, the store keeps a running count of how many items the reducer has seen. This store, with the previous value of the reduction, can be used to compute the new average using only the new value by using the formula `((old average * previous count) + new value)/(old count + 1)` and the store can be updated with the new count `(old count + 1)`.

When using running reducers for performance reasons, please keep in mind that the performance benefits of running reduction are only realized if *every* reducer for that reducible is executed in running mode. The primary advantage of running reduction is that it eliminates the need to load large numbers of extracts for a given subject or user.