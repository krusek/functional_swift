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

public indirect enum RedBlackTree<A: Comparable> {
    case empty, tree(Color, RedBlackTree, A, RedBlackTree)

    public static func create(_ element: A) -> RedBlackTree {
        return .tree(.black, .empty, element, .empty)
    }

    public func insert(_ element: A) -> RedBlackTree {
        switch self {
        case .empty:
            return .tree(Color.red, .empty, element, .empty)
        case .tree(let color, let lhs, let value, let rhs) where value > element:
            return .tree(color, lhs.insert(element), value, rhs)
        case .tree(let color, let lhs, let value, let rhs):
            return .tree(color, lhs, value, rhs.insert(element))
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
            case .empty:
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
}
