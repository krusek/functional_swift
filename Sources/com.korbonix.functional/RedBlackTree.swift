//
//  RedBlackTree.swift
//  com.korbonix.functional
//
//  Created by Korben Rusek on 10/14/19.
//

import Foundation

public enum Color {
    case red, black, doubleBlack, negativeBlack
}

public indirect enum RedBlackTree<A: Comparable> {
    case empty, doubleEmpty, tree(Color, RedBlackTree<A>, A, RedBlackTree<A>)

    public static func create(_ element: A) -> RedBlackTree {
        return .tree(.black, .empty, element, .empty)
    }
}

extension RedBlackTree {
    public func remove(_ element: A) -> RedBlackTree {
        return self.delete(element).makeBlack()
    }

    /// This deletes a node by first finding the node in question and then
    /// changing its value to the next smaller value. It then rebalances the
    /// red/black rules from the bottom up.
    ///
    /// - Parameter element: The element to be removed
    /// - Returns: A balanced tree without the given element.
    private func delete(_ element: A) -> RedBlackTree {
        switch self {
        case .empty, .doubleEmpty:
            return self
        case .tree(let c, let left, let x, let right) where x == element:
            guard let mx = left.max() else {
                return right.blacker()
            }
            return RedBlackTree.tree(c, left.delete(mx), mx, right).bubbled()
        case .tree(let c, let left, let x, let right) where x < element:
            return RedBlackTree.tree(c, left, x, right.delete(element)).bubbled()
        case .tree(let c, let left, let x, let right):
            return RedBlackTree.tree(c, left.delete(element), x, right).bubbled()
        }
    }

    private func max() -> A? {
        switch self {
        case .empty, .doubleEmpty:
            return nil
        case .tree(_, _, let a, .empty):
            return a
        case .tree(_, _, _, let right):
            return right.max()
        }
    }
}

extension RedBlackTree {
    public func insert(_ element: A) -> RedBlackTree {
        switch self {
        case .empty:
            return .tree(.black, .empty, element, .empty)
        default:
            return self.insertDeep(element).balanced().makeBlack()
        }
    }

    private func insertDeep(_ element: A) -> RedBlackTree {
        switch self {
        case .empty, .doubleEmpty:
            return .tree(Color.red, .empty, element, .empty)
        case .tree(let color, let lhs, let value, let rhs) where value > element:
            return .tree(color, lhs.insertDeep(element).balanced(), value, rhs)
        case .tree(let color, let lhs, let value, let rhs):
            return .tree(color, lhs, value, rhs.insertDeep(element).balanced())
        }
    }

    /// This method balances the tree -- removing red - red violations as well as removing the
    /// double blacks that can be easily removed. The red - red violations are easy as they
    /// require a simple rebalancing such that the parent is red and the two immediate children
    /// are black instead.
    ///
    /// It also fixes double black trees with red - red violations by doing a similar balancing as
    /// above but where the parent is black instead of read.
    ///
    /// Finally it fixes doubleblack trees with negative black children by replacing both nodes
    /// with regular black nodes.
    ///
    /// NOTE: This could be broken into three methods to more easily illucidate the logic and allow
    /// better method naming. It could also be broken down such that only the balancing applying
    /// to left trees are together and balancing for right trees are together.
    ///
    /// - Returns: A balanced tree when called recursively from the bottom.
    private func balanced() -> RedBlackTree {
        switch self {
        case .empty:
            return self
            // Standard balancing
        case .tree(.black, let a, let x, .tree(.red, let b, let y, .tree(.red, let c, let z, let d))),
             .tree(.black, let a, let x, .tree(.red, .tree(.red, let b, let y, let c), let z, let d)),
             .tree(.black, .tree(.red, .tree(.red, let a, let x, let b), let y, let c), let z, let d),
             .tree(.black, .tree(.red, let a, let x, .tree(.red, let b, let y, let c)), let z, let d):
            return .tree(.red, .tree(.black, a, x, b), y, .tree(.black, c, z, d))
            // Double black balancing when easy.
        case .tree(.doubleBlack, let a, let x, .tree(.red, let b, let y, .tree(.red, let c, let z, let d))),
             .tree(.doubleBlack, let a, let x, .tree(.red, .tree(.red, let b, let y, let c), let z, let d)),
             .tree(.doubleBlack, .tree(.red, .tree(.red, let a, let x, let b), let y, let c), let z, let d),
             .tree(.doubleBlack, .tree(.red, let a, let x, .tree(.red, let b, let y, let c)), let z, let d):
            return .tree(.black, .tree(.black, a, x, b), y, .tree(.black, c, z, d))
            // Double black / negative black balancing
        case .tree(.doubleBlack, let a, let x, .tree(.negativeBlack, .tree(.black, let b, let y, let c), let z, let d)) where d.isBlackTree:
            return .tree(.black, .tree(.black, a, x, b), y, RedBlackTree.tree(.black, c, z, d.makeRed()).balanced())
        case .tree(.doubleBlack, .tree(.negativeBlack, let a, let x, .tree(.black, let b, let y, let c)), let z, let d) where a.isBlackTree:
            return .tree(.black, RedBlackTree.tree(.black, a.makeRed(), x, b).balanced(), y, .tree(.black, c, z, d))
        default:
            return self
        }
    }

    /// Bubbles the double black state upwardsin the tree. That is, if a child is double black
    /// it will blacken the parent and make the children redder. It follows the bubbling with
    /// balancing to make sure that introducing the red nodes doesn't break the double red rule.
    /// If this is called recursively from the bottom, then the new double black node will bubble
    /// to the top. When it makes its way to the top then it can be replaced with a black node.
    ///
    /// - Returns: A tree with at most one double black node when called recursively from the bottom.
    private func bubbled() -> RedBlackTree {
        switch self {
        case .tree(let c, let l, let a, let r) where l.isDoubleBlack || r.isDoubleBlack:
            return RedBlackTree.tree(blacker(color: c), l.redder(), a, r.redder()).balanced()
        default:
            return self.balanced()
        }
    }
}

//MARK: Color changing and checking
extension RedBlackTree {
    private var isBlackTree: Bool {
        switch self {
        case .tree(.black, _, _, _):
            return true
        default:
            return false
        }
    }

    private var isDoubleBlack: Bool {
        switch self {
        case .tree(.doubleBlack, _, _, _),
             .doubleEmpty:
            return true
        default:
            return false
        }
    }

    private func makeRed() -> RedBlackTree {
        switch  self {
        case .tree(_, let x, let a, let y):
            return .tree(.red, x, a, y)
        default:
            return self
        }
    }

    private func redder() -> RedBlackTree {
        switch self {
        case .doubleEmpty:
            return .empty
        case .tree(let c, let l, let a, let r):
            return .tree(redder(color: c), l, a, r)
        default:
            assert(false)
        }
    }

    private func redder(color: Color) -> Color {
        switch color {
        case .red:
            return .negativeBlack
        case .black:
            return .red
        case .doubleBlack:
            return .black
        case .negativeBlack:
            assert(false)
        }
    }

    private func makeBlack() -> RedBlackTree {
        switch self {
        case .empty, .doubleEmpty:
            return .empty
        case .tree(.red, let lhs, let a, let rhs):
            return .tree(.black, lhs, a, rhs)
        default:
            return self
        }
    }

    private func blacker() -> RedBlackTree {
        switch self {
        case .empty, .doubleEmpty:
            return .doubleEmpty
        case .tree(let color, let left, let a, let right):
            return .tree(blacker(color: color), left, a, right)
        }
    }

    private func blacker(color: Color) -> Color {
        switch color {
        case .negativeBlack:
            return .red
        case .red:
            return .black
        case .black, .doubleBlack:
            return .doubleBlack
        }
    }

}

extension RedBlackTree {
    public func toArray() -> [[(Color, A)?]] {
        guard let head = self.simpleTuple() else { return [] }
        var array: [[(Color, A)?]] = [[head]]
        let harray: [RedBlackTree] = [self]
        var next = RedBlackTree.nextItems(harray)
        while next.count > 0 {
            let narray = next.map({ $0.simpleTuple() })
            if narray.compactMap({$0}).count == 0 { break }
            array.append(narray)
            next = RedBlackTree.nextItems(next)
        }
        return array
    }

    static private func nextItems(_ list: [RedBlackTree]) -> [RedBlackTree] {
        return list.flatMap({ (item) -> [RedBlackTree] in
            switch item {
            case .empty, .doubleEmpty:
                return []
            case .tree(_, let lhs, _, let rhs):
                return [lhs, rhs]
            }
        })
    }

    private func simpleTuple() -> (Color, A)? {
        switch self {
        case .empty, .doubleEmpty:
            return nil
        case .tree(let c, _, let value, _):
            return (c, value)
        }
    }
}

