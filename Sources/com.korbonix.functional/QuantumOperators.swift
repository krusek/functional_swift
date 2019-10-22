//
//  QuantumOperators.swift
//  com.korbonix.functional
//
//  Created by Korben Rusek on 10/18/19.
//

import Foundation

public typealias QuantumCoefficient = Double

public indirect enum QuantumOperator {
    case constant(QuantumCoefficient), single(Int, QuantumOperator, QuantumOperator, QuantumOperator, QuantumOperator), diagonal(Int, QuantumCoefficient)

    public static let I = QuantumOperator.diagonal(2, 1.0) // QuantumOperator.single(2, .one, .zero, .zero, .one)
    public static let X = QuantumOperator.single(2, .zero, .one, .one, .zero)
    public static let Z = QuantumOperator.single(2, .one, .zero, .zero, .constant(-1))

    static let zero = QuantumOperator.constant(0)
    static let one = QuantumOperator.constant(1)
}

public indirect enum QuantumVector {
    case constant(QuantumCoefficient), single(Int, QuantumVector, QuantumVector)

    public static func from(_ array: [QuantumCoefficient]) -> QuantumVector {
        return from(array[0..<array.count])
    }

    public static let zero = QuantumVector.constant(0.0)
    public static let one = QuantumVector.constant(1.0)

    private static func from(_ array: ArraySlice<QuantumCoefficient>) -> QuantumVector {
        if array.count == 2, let first = array.first, let last = array.last {
            return .single(2, .constant(first), .constant(last))
        }
        let length = array.count
        let half = length / 2
        let start = array.startIndex
        let end = array.endIndex
        let mid = start + half
        let lhs = self.from(array[start..<mid])
        let rhs = self.from(array[mid..<end])

        assert(lhs.size == rhs.size)
        return .single(2 * lhs.size, lhs, rhs)
    }

    var size: Int {
        switch self {
        case .constant(_):
            return 1
        case .single(let i, _, _):
            return i
        }
    }

    func toArray() -> [QuantumCoefficient] {
        switch self {
        case .constant(let a):
            return [a]
        case .single(_, let a, let b):
            return a.toArray() + b.toArray()
        }
    }
}

extension QuantumVector: CustomStringConvertible {
    public var description: String {
        let length = self.length
        let array = self.toArray()
        return array.enumerated().compactMap { (ix, element) -> String? in
            guard element != 0 else { return nil }
            return "\(element)|\(monomial(ix, length: length))>"
        }.joined(separator: " + ")
    }

    private func monomial(_ ix: Int, length: Int) -> String {
        let s = String(ix, radix: 2)
        if s.count >= length { return s }
        return String(repeating: "0", count: length - s.count) + s
    }

    private var length: Int {
        let length = Int(log2(Double(self.size)))
        return length > 0 ? length : 1
    }
}

extension QuantumOperator: CustomStringConvertible {
    public var description: String {
        let size = self.size()
        let pieces: [[String]] = (0..<size).map({ ix in
            let row = self.row(ix)
            let strings = row.map({String($0 == 0 ? 0 : $0)})
            return strings
        })
        let paddingSize = pieces.flatMap({$0}).map({$0.count}).max() ?? 1
        return pieces.map({ part -> String in
            let line = part.map({ s in
                if s.count == paddingSize { return s }
                else {
                    return String(repeating: " ", count: paddingSize - s.count) + s
                }
            }).joined(separator: " ")
            return "|" + line + "|"
        }).joined(separator: "\n")
    }
}

extension QuantumOperator {
    public func row(_ ix: Int) -> [QuantumCoefficient] {
        switch self {
        case .constant(let coeff):
            assert(ix == 0)
            return [coeff]
        case let .diagonal(i, a):
            return (0..<i).map { $0 == ix ? a : 0.0 }
        case let .single(i, a, b, c, d):
            let half = i / 2
            let subrow = ix % half
            if ix < half {
                return a.row(subrow) + b.row(subrow)
            } else {
                return c.row(subrow) + d.row(subrow)
            }
        }
    }

    func size() -> Int {
        switch self {
        case .constant(_):
            return 1
        case .single(let i, _, _, _, _),
             .diagonal(let i, _):
            return i
        }
    }
}

public func *(lhs: QuantumOperator, rhs: QuantumVector) -> QuantumVector {
    switch (lhs, rhs) {
    case (.single(let i, let a, let b, let c, let d), .single(let j, let e, let f)) where i == j:
        return .single(i, a * e + b * f, c * e + d * f)
    case (.constant(let a), .constant(let b)):
        return .constant(a * b)
    case (.diagonal(let i, let a), .single(let j, let e, let f)) where i == j:
        return .single(i, a * e, a * f)
    default:
        assert(false)
    }
}

public func +(lhs: QuantumVector, rhs: QuantumVector) -> QuantumVector {
    switch (lhs, rhs) {
    case (.constant(let a), .constant(let b)):
        return .constant(a + b)
    case (.single(let i, let a, let b), .single(let j, let c, let d)) where i == j:
        return .single(i, a + c, b + d)
    default:
        assert(false)
    }
}

public func *(lhs: QuantumCoefficient, rhs: QuantumVector) -> QuantumVector {
    switch rhs {
    case .constant(let a):
        return .constant(lhs * a)
    case .single(let i, let a, let b):
        return .single(i, lhs * a, lhs * b)
    }
}

public func *(lhs: QuantumOperator, rhs: QuantumOperator) -> QuantumOperator {
    switch (lhs, rhs) {
    case (.constant(let coeff1), .constant(let coeff2)):
        return .constant(coeff1 * coeff2)
    case (.constant(let coeff), .diagonal(let i, let a)),
         (.diagonal(let i, let a), .constant(let coeff)):
        return .diagonal(i, a * coeff)
    case (.diagonal(let i, let a), .diagonal(_, let b)):
        return .diagonal(2 * i, a * b)
    case let (.constant(coeff), .single(i, a, b, c, d)),
         let (.single(i, a, b, c, d), .constant(coeff)):
        return .single(i, coeff * a, coeff * b, coeff * c, coeff * d)
    case let (.single(i, a, b, c, d), .single(_, _, _, _, _)),
         let (.single(i, a, b, c, d), .diagonal(_, _)):
        return .single(2*i, a * rhs, b * rhs, c * rhs, d * rhs)
    case let (.diagonal(i, a), .single(_, _, _, _, _)):
        return .single(2*i, a * rhs, 0.0 * rhs, 0.0 * rhs, a * rhs)
    }
}

public func *(lhs: QuantumCoefficient, rhs: QuantumOperator) -> QuantumOperator {
    switch rhs {
    case let .constant(coeff):
        return .constant(lhs * coeff)
    case let .diagonal(i, a):
        return .diagonal(i, a * lhs)
    case let .single(i, a, b, c, d):
        return .single(i, lhs * a, lhs * b, lhs * c, lhs * d)
    }
}
