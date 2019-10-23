//
//  QuantumOperatorsTests.swift
//  com.korbonix.functionalTests
//
//  Created by Korben Rusek on 10/18/19.
//

import XCTest
import com_korbonix_functional

class QuantumOperatorsTests: XCTestCase {

    func testExample() {
        let X = """
        |0.0 1.0|
        |1.0 0.0|
        """
        assertEquivalent(QuantumOperator.X, X)

        let Z = """
        | 1.0  0.0|
        | 0.0 -1.0|
        """
        assertEquivalent(QuantumOperator.Z, Z)

        let I = """
        |1.0 0.0|
        |0.0 1.0|
        """
        assertEquivalent(QuantumOperator.I, I)

        let XZ = """
        | 0.0  0.0  1.0  0.0|
        | 0.0  0.0  0.0 -1.0|
        | 1.0  0.0  0.0  0.0|
        | 0.0 -1.0  0.0  0.0|
        """
        assertEquivalent(QuantumOperator.X * QuantumOperator.Z, XZ)

        let XZX = """
        | 0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0|
        | 0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0|
        | 0.0  0.0  0.0  0.0  0.0  0.0  0.0 -1.0|
        | 0.0  0.0  0.0  0.0  0.0  0.0 -1.0  0.0|
        | 0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0|
        | 1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0|
        | 0.0  0.0  0.0 -1.0  0.0  0.0  0.0  0.0|
        | 0.0  0.0 -1.0  0.0  0.0  0.0  0.0  0.0|
        """
        assertEquivalent(QuantumOperator.X * QuantumOperator.Z * QuantumOperator.X, XZX)

        let IIX = """
        |0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0|
        |1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0|
        |0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0|
        |0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0|
        |0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0|
        |0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0|
        |0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0|
        |0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0|
        """
        assertEquivalent((QuantumOperator.I * QuantumOperator.I * QuantumOperator.X), IIX)
    }

    func assertEquivalent(_ quantum: QuantumOperator, _ expected: String, _ message: String = "") {
        XCTAssertEqual(quantum.description, expected, message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }

    func testExample2() {
        let v = QuantumVector.from([1, 2, 3, 4])
        let ox = QuantumOperator.X * QuantumOperator.I
        let xo = QuantumOperator.I * QuantumOperator.X
        let ii = QuantumOperator.I * QuantumOperator.I

        print(v)
        print(ox * v)
        print(xo * v)
        print(ii * v)
    }
}
