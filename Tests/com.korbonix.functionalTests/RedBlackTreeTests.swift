//
//  RedBlackTreeTests.swift
//  com.korbonix.functionalTests
//
//  Created by Korben Rusek on 10/14/19.
//

import XCTest
import com_korbonix_functional

class RedBlackTreeArrayTests: XCTestCase {
    func testEmptyTree() {
        let tree = RedBlackTree<Int>.empty
        let empty: [[(Color, Int)?]] = []
        XCTAssertTrue(equals(tree.toArray(), empty))
    }

    func testSingleElement() {
        let tree = RedBlackTree<Int>.create(5)
        XCTAssertTrue(equals(tree.toArray(), [[(Color.black, 5)]]))
    }

    func testSimpleTree() {
        let tree = RedBlackTree<Int>.tree(Color.red,
                                          .tree(Color.black,
                                                .tree(Color.red, .empty, 20, .empty),
                                                10,
                                                .empty),
                                          5,
                                          .tree(Color.black, .empty, 15, .empty))
        XCTAssertTrue(equals(tree.toArray(), [[(Color.red, 5)],[(Color.black, 10), (Color.black, 15)],[(Color.red, 20), nil, nil, nil]]))
    }
}

class RedBlackTreeInsertionTests: XCTestCase {
    func testInsertionContainsValues() {
        let tree = RedBlackTree.create(0).insert(1).insert(2).insert(-1).insert(-2)
        let array = tree.toArray().flatMap({$0}).compactMap({$0}).map({$0.1}).sorted()
        XCTAssertEqual(array, [-2, -1, 0, 1, 2])
    }

    func testOrderingForInsertion() {
        let tree = RedBlackTree.create(0).insert(1).insert(2).insert(-1).insert(-2)
        let ordering = checkOrdering(tree, greater: nil, lesser: nil)
        XCTAssertTrue(ordering)
    }

    func testRedChildrenRule() {
        let tree = createTree(Array(-30...30).shuffled())
        let check = checkRedChildrenRule(tree)
        XCTAssertTrue(check)
    }

    func testBlackDepthRule() {
        let tree = createTree(Array(-30...30).shuffled())
        let check = checkBlackDepthRule(tree)
        XCTAssertTrue(check.0)

    }


}

class RedBlackTreeRemovalTests: XCTestCase {
    func testRemovesElement() {
        let array = Array(-20...20)
        for ix in -20...20 {
            let tree = createTree(array)
            let removed = tree.remove(ix)
            let array2 = removed.toArray().flatMap({$0}).compactMap({$0}).map({$0.1}).sorted()
            XCTAssertEqual(array2, array.filter({ $0 != ix }))
        }
    }

    func testRemovesElementRetainingOrder() {
        let array = Array(-20...20)
        for ix in -20...20 {
            let tree = createTree(array)
            let removed = tree.remove(ix)
            let ordered = checkOrdering(removed, greater: nil, lesser: nil)
            XCTAssertTrue(ordered)
        }
    }

    func testRemoveRetainsBlackDepthRule() {
        let array = Array(-20...20)
        for ix in -20...20 {
            let tree = createTree(array)
            let removed = tree.remove(ix)
            let blackRule = checkBlackDepthRule(removed)
            XCTAssertTrue(blackRule.0)
        }
    }

    func testRemoveRetainsRedRule() {
        let array = Array(-20...20)
        for ix in -20...20 {
            let tree = createTree(array)
            let removed = tree.remove(ix)
            let redRule = checkRedChildrenRule(removed)
            XCTAssertTrue(redRule)
        }
    }

}

func createTree<A: Comparable>(_ array: [A]) -> RedBlackTree<A> {
    return array.reduce(RedBlackTree<A>.empty) { (tree, a) -> RedBlackTree<A> in
        return tree.insert(a)
    }
}

func checkOrdering<A: Comparable>(_ tree: RedBlackTree<A>, greater: A?, lesser: A?) -> Bool {
    switch tree {
    case .empty, .doubleEmpty:
        return true
    case .tree(_, let lhs, let value, let rhs):
        if let greater = greater, value > greater { return false }
        if let lesser = lesser, value <= lesser { return false }
        return checkOrdering(lhs, greater: value, lesser: nil) && checkOrdering(rhs, greater: nil, lesser: value)
    }
}

func checkBlackDepthRule<A: Comparable>(_ tree: RedBlackTree<A>) -> (Bool, Int) {
    switch tree {
    case .empty:
        return (true, 0)
    case .doubleEmpty:
        return (true, 1)
    case .tree(let c, let lhs, _, let rhs):
        let left = checkBlackDepthRule(lhs)
        guard left.0 else { return left }
        let right = checkBlackDepthRule(rhs)
        guard right.0 else { return right }
        guard left == right else { return (false, -1) }
        switch c {
        case .black:
            return (true, left.1 + 1)
        case .doubleBlack:
            return (true, left.1 + 2)
        case .red:
            return (true, left.1)
        case .negativeBlack:
            return (true, left.1 - 1)
        }
    }
}

func checkRedChildrenRule<A: Comparable>(_ tree: RedBlackTree<A>) -> Bool {
    switch tree {
    case .empty, .doubleEmpty:
        return true
    case .tree(.red, .tree(.red, _, _, _), _, _),
         .tree(.red, _, _, .tree(.red, _, _, _)):
        return false
    case .tree(_, let lhs, _, let rhs):
        return checkRedChildrenRule(lhs) && checkRedChildrenRule(rhs)
    }
}

func equals<A:Equatable>(_ array1: [[(Color, A)?]], _ array2: [[(Color, A)?]]) -> Bool {
    guard array1.count == array2.count else { return false }
    for ix in 0..<array1.count {
        if !equals(array1[ix], array2[ix]) { return false }
    }
    return true
}

func equals<A:Equatable>(_ array1: [(Color, A)?], _ array2: [(Color, A)?]) -> Bool {
    guard array1.count == array2.count else { return false }
    for ix in 0..<array1.count {
        if !equals(array1[ix], array2[ix]) { return false }
    }
    return true
}

func equals<A: Equatable>(_ lhs: (Color, A)?, _ rhs: (Color, A)?) -> Bool {
    if lhs == nil && rhs == nil { return true }
    guard let lhs = lhs, let rhs = rhs else { return false }
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
}
