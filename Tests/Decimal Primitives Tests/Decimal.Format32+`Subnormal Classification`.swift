import Testing

@testable import Decimal_Primitives

extension Decimal.Format32 {
    @Suite struct `Subnormal Classification` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format32.`Subnormal Classification`.`Edge Case` {
    /// F-003: at the quantum minimum, a coefficient carrying the format's
    /// full 7 digits of precision has adjusted (scientific) exponent
    /// exactly `scientificMin` and is normal — not subnormal.
    @Test func smallestNormalAtQuantumMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,  // qmin
            coefficient: 1_000_000  // 7 digits
        )
        #expect(value.classification == .normal)
    }

    /// F-003: the old check (`exponent == minExponent && coefficient <
    /// coefficientMax() / 10`) excluded its own threshold value from the
    /// subnormal range via a strict `<` comparison — the largest coefficient
    /// one digit short of full precision at the quantum minimum must be
    /// subnormal, not normal.
    @Test func largestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,  // qmin
            coefficient: 999_999  // 6 digits, one short of full precision
        )
        #expect(value.classification == .subnormal)
    }

    /// F-003: a single significant digit at the quantum minimum is the
    /// deepest possible subnormal.
    @Test func deepestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,  // qmin
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    /// F-003: subnormal classification is about magnitude (digit count vs.
    /// exponent), not merely "is the exponent at its minimum" — a
    /// low-digit-count coefficient one exponent step above the minimum is
    /// still deeply subnormal, which the old exact-equality exponent check
    /// could never detect.
    @Test func subnormalOneExponentStepAboveMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent + 1,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }
}
