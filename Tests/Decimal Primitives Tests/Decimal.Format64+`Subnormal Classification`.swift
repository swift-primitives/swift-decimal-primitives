import Testing

@testable import Decimal_Primitives

extension Decimal.Format64 {
    @Suite struct `Subnormal Classification` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format64.`Subnormal Classification`.`Edge Case` {
    /// F-003: at the quantum minimum, a coefficient carrying the format's
    /// full 16 digits of precision has adjusted (scientific) exponent
    /// exactly `scientificMin` and is normal — not subnormal.
    @Test func smallestNormalAtQuantumMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,  // qmin
            coefficient: 1_000_000_000_000_000  // 16 digits
        )
        #expect(value.classification == .normal)
        #expect(!value.test.subnormal)
    }

    /// F-003: the old check (`exponent == minExponent && coefficient <
    /// coefficientMax() / 10`) misclassified by a fixed coefficient-magnitude
    /// threshold rather than by digit count; one digit short of full
    /// precision at the quantum minimum must be subnormal.
    @Test func largestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,  // qmin
            coefficient: 999_999_999_999_999  // 15 digits, one short of full precision
        )
        #expect(value.classification == .subnormal)
        #expect(value.test.subnormal)
    }

    /// F-003: a single significant digit at the quantum minimum is the
    /// deepest possible subnormal.
    @Test func deepestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,  // qmin
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    /// F-003: subnormal classification is about magnitude (digit count vs.
    /// exponent), not merely "is the exponent at its minimum" — a
    /// full-precision coefficient one exponent step above the minimum must
    /// still be normal.
    @Test func normalOneExponentStepAboveMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent + 1,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
    }
}
