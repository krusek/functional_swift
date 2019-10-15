//
//  RedBlackTree.swift
//  com.korbonix.functional
//
//  Created by Korben Rusek on 10/14/19.
//

import Foundation

public enum Color {
    case red, black
}

public indirect enum RedBlackTree<A> {
    case empty, tree(Color, RedBlackTree, A, RedBlackTree)

    public func toArray() -> [[(Color, A)?]] {
        guard let head = self.simpleTuple() else { return [] }
        var array: [[(Color, A)?]] = [[head]]
        let harray: [RedBlackTree] = [self]
        var next = RedBlackTree.nextItems(harray)
        while next.count > 0 {
            let narray = next.map({ $0.simpleTuple() })
            array.append(narray)
            next = RedBlackTree.nextItems(next)
        }
        return array
    }

    static private func nextItems(_ list: [RedBlackTree]) -> [RedBlackTree] {
        return list.flatMap({ (item) -> [RedBlackTree] in
            switch item {
            case .empty:
                return []
            case .tree(_, .empty, _, .empty):
                return []
            case .tree(_, let lhs, _, let rhs):
                return [lhs, rhs]
            }
        })
    }

    func simpleTuple() -> (Color, A)? {
        switch self {
        case .empty:
            return nil
        case .tree(let c, _, let value, _):
            return (c, value)
        }
    }

    func children() -> [(Color, A)?] {
        switch self {
        case .empty:
            return []
        case .tree(_, .empty, _, .empty):
            return []
        case .tree(_, let ltree, _, let rtree):
            return [ltree.simpleTuple(), rtree.simpleTuple()]
        }
    }
}
