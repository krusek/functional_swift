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
        return self.delete(element).blacken()
    }

    func delete(_ element: A) -> RedBlackTree {
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

    private func blacken() -> RedBlackTree {
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
    public func insert(_ element: A) -> RedBlackTree {
        switch self {
        case .empty:
            return .tree(.black, .empty, element, .empty)
        default:
            return self.insertDeep(element).balanced().blacken()
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

    private func redden() -> RedBlackTree {
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
            return .tree(.black, .tree(.black, a, x, b), y, RedBlackTree.tree(.black, c, z, d.redden()).balanced())
        case .tree(.doubleBlack, .tree(.negativeBlack, let a, let x, .tree(.black, let b, let y, let c)), let z, let d) where a.isBlackTree:
            return .tree(.black, RedBlackTree.tree(.black, a.redden(), x, b).balanced(), y, .tree(.black, c, z, d))
        default:
            return self
        }
    }

    private func bubbled() -> RedBlackTree {
        switch self {
        case .tree(let c, let l, let a, let r) where l.isDoubleBlack || r.isDoubleBlack:
            return RedBlackTree.tree(blacker(color: c), l.redder(), a, r.redder()).balanced()
        default:
            return self.balanced()
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

