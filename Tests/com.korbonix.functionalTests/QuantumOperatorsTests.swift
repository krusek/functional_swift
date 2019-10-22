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
        print(QuantumOperator.X)
        print("")
        print(QuantumOperator.Z)
        print("")
        print(QuantumOperator.I)
        print("")
        print(QuantumOperator.X * QuantumOperator.Z)
        print("")
        print(QuantumOperator.X * QuantumOperator.Z * QuantumOperator.X)
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
