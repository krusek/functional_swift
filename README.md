# com.korbonix.functional

This includes various data structures in functional programming.

# RedBlackTree

This is a red/black tree implemented as an `indirect enum`. It allows both inserting and removing elements. It stays balanced due to the red / black rules:

- red nodes cannot have red children
- every path from the head to a leaf must have the same number of black nodes.
