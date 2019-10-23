# com.korbonix.functional

This includes various data structures in functional programming.

# RedBlackTree

This is a red/black tree implemented as an `indirect enum`. It allows both inserting and removing elements. It stays balanced due to the red / black rules:

- red nodes cannot have red children
- every path from the head to a leaf must have the same number of black nodes.

# QuantumOperators

This is yet another approach to quantum operators. This is based on the recursive behavior of tensor products.

## Tensor Products

A quantum operator acting on a single qubit can be represented by a 2x2 matrix. When you apply two operators to two different qubits (here we including the identity operator) there is a simple, recursive way to view it. Let `M` be a single qubit operator represented as  
```
| a b |
| c d |.
```
Furthermore let `N` be another operator represented as
```
| e f |
| g h |.
```

Then `M` tensored with `N` can be written as
```
| aN bN |
| cN dN |.
```
Where `M` tensored with `N` is a 4x4 matrix. This can be multiplied out to a full 4x4 matrix. But the approach taken here is to
define the operators recursively and leave them unexpanded. That is a `QuantumOperator` is either a constant or a set of
four `QuantumOperator`s. Similarly a set of qubits can be represented as a `QuantumVector` which in turn is a constant
or a set of 2 `QuantumVector`s.

In this view tensor products and operator qubit operators are pretty straightforward. Actually the most complicated bit is
converting them to a human readable string format.

