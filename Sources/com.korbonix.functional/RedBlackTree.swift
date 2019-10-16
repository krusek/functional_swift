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
    case empty, doubleEmpty, tree(Color, RedBlackTree, A, RedBlackTree)

    public static func create(_ element: A) -> RedBlackTree {
        return .tree(.black, .empty, element, .empty)
    }
}

extension RedBlackTree {
    public func remove(_ element: A) -> RedBlackTree {
        switch self {
        case .empty, .doubleEmpty:
            return self
        case .tree(let c, let left, let x, let right) where x == element:
            guard let mx = right.max() else {
                return left
            }
            return .tree(c, left, mx, right.remove(mx))
        case .tree(let c, let left, let x, let right) where x < element:
            return .tree(c, left, x, right.remove(element))
        case .tree(let c, let left, let x, let right):
            return .tree(c, left.remove(element), x, right)
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
        let tree: RedBlackTree
        switch self {
        case .empty:
            tree = .tree(.black, .empty, element, .empty)
        default:
            tree = self.insertDeep(element).balance()
        }
        switch tree {
        case .tree(.red, let lhs, let a, let rhs):
            return .tree(.black, lhs, a, rhs)
        default:
            return tree
        }
    }

    private func insertDeep(_ element: A) -> RedBlackTree {
        switch self {
        case .empty, .doubleEmpty:
            return .tree(Color.red, .empty, element, .empty)
        case .tree(let color, let lhs, let value, let rhs) where value > element:
            return .tree(color, lhs.insertDeep(element).balance(), value, rhs)
        case .tree(let color, let lhs, let value, let rhs):
            return .tree(color, lhs, value, rhs.insertDeep(element).balance())
        }
    }

    private func balance() -> RedBlackTree {
        switch self {
        case .empty:
            return self
        case .tree(.black, let a, let x, .tree(.red, let b, let y, .tree(.red, let c, let z, let d))),
             .tree(.black, let a, let x, .tree(.red, .tree(.red, let b, let y, let c), let z, let d)),
             .tree(.black, .tree(.red, .tree(.red, let a, let x, let b), let y, let c), let z, let d),
             .tree(.black, .tree(.red, let a, let x, .tree(.red, let b, let y, let c)), let z, let d):
            return .tree(.red, .tree(.black, a, x, b), y, .tree(.black, c, z, d))
        default:
            return self
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

    func simpleTuple() -> (Color, A)? {
        switch self {
        case .empty, .doubleEmpty:
            return nil
        case .tree(let c, _, let value, _):
            return (c, value)
        }
    }
}

