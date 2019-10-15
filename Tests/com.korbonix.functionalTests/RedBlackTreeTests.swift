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
        let tree = RedBlackTree<Int>.tree(Color.red, .empty, 5, .empty)
        XCTAssertTrue(equals(tree.toArray(), [[(Color.red, 5)]]))
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
