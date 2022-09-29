//
//  Complex.swift
//  Mocha
//
//  Created by Daniel Heath on 9/19/22.
//

import Foundation

struct ComplexNumber {
    var real: Double
    var imaginary: Double
    public init(_ real: Double, _ imaginary: Double) {
        self.real = real
        self.imaginary = imaginary
    }
    public init(_ real: Double) {
        self.real = real
        self.imaginary = 0
    }
    var isReal: Bool { imaginary == 0 }
}

extension ComplexNumber {
    static func zero() -> Self {
        return ComplexNumber(0, 0)
    }
}

//extension ComplexNumber: CustomStringConvertible {
//    var description: String {
//        return "(Real: \(real), Imaginary: \(imaginary))"
//    }
//}

func linearSolve(a: Double, b: Double) -> [ComplexNumber] {
    if a == 0 { return [] }
    return [ComplexNumber(-b/a)]
}

func quadraticSolve(a: Double, b: Double, c: Double, threshold: Double = 0.0001) -> [ComplexNumber] {
    if a == 0 { return linearSolve(a: b, b: c) }
    var roots = [ComplexNumber]()
    var d = pow(b, 2) - 4*a*c // discriminant
    // Check if discriminate is within the 0 threshold
    if -threshold < d && d < threshold { d = 0 }
    if d > 0 {
        let x_1 = ComplexNumber((-b + sqrt(d))/(2*a))
        let x_2 = ComplexNumber((-b - sqrt(d))/(2*a))
        roots = [x_1, x_2]
    } else if d == 0 {
        let x = ComplexNumber(-b/(2*a))
        roots = [x, x]
    } else if d < 0 {
        let x_1 = ComplexNumber(-b/(2*a), sqrt(-d)/(2*a))
        let x_2 = ComplexNumber(-b/(2*a), -sqrt(-d)/(2*a))
        roots = [x_1, x_2]
    }

    return roots
}

func cubicSolve(a: Double, b: Double, c: Double, d: Double, threshold: Double = 0.0001) -> [ComplexNumber] {
    // if not a cubic fall back to quadratic
    if a == 0 { return quadraticSolve(a: b, b: c, c: d) }
    var roots = [ComplexNumber]()

    let a_1 = b/a
    let a_2 = c/a
    let a_3 = d/a

    let q = (3*a_2 - pow(a_1, 2))/9
    let r = (9*a_1*a_2 - 27*a_3 - 2*pow(a_1, 3))/54

    let s = cbrt(r + sqrt(pow(q, 3)+pow(r, 2)))
    let t = cbrt(r - sqrt(pow(q, 3)+pow(r, 2)))

    var d = pow(q, 3) + pow(r, 2) // discriminant

    // Check if d is within the zero threshold
    if -threshold < d && d < threshold { d = 0 }
    if d > 0 {
        let x_1 = ComplexNumber(s + t - (1/3)*a_1)
        let x_2 = ComplexNumber(-(1/2)*(s+t) - (1/3)*a_1,  (1/2)*sqrt(3)*(s - t))
        let x_3 = ComplexNumber(-(1/2)*(s+t) - (1/3)*a_1,  -(1/2)*sqrt(3)*(s - t))
        roots = [x_1, x_2, x_3]
    } else if d <= 0 {
        let theta = acos(r/sqrt(-pow(q, 3)))
        let x_1 = ComplexNumber(2*sqrt(-q)*cos((1/3)*theta) - (1/3)*a_1)
        let x_2 = ComplexNumber(2*sqrt(-q)*cos((1/3)*theta + 2*Double.pi/3) - (1/3)*a_1)
        let x_3 = ComplexNumber(2*sqrt(-q)*cos((1/3)*theta + 4*Double.pi/3) - (1/3)*a_1)
        roots = [x_1, x_2, x_3]
    }
    return roots
}
