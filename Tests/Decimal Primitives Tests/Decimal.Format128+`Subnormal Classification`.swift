import Testing

@testable import Decimal_Primitives

extension Decimal.Format128 {
    @Suite struct `Subnormal Classification` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format128.`Subnormal Classification`.`Edge Case` {
    /// F-003: at the quantum minimum, a coefficient carrying the format's
    /// full 34 digits of precision has adjusted (scientific) exponent
    /// exactly `scientificMin` and is normal — not subnormal.
    @Test func smallestNormalAtQuantumMinimum() {
        let coefficient = UInt128(1_000_000_000_000_000_000) * UInt128(1_000_000_000_000_000)
        // 10^33: 34 digits
        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,  // qmin
            coefficient: coefficient
        )
        #expect(value.classification == .normal)
    }

    /// F-003: this format's original classification never returned
    /// `.subnormal` at all — any coefficient with fewer than 34 digits at
    /// the quantum minimum must be subnormal.
    @Test func largestSubnormalAtQuantumMinimum() {
        let coefficient = UInt128(1_000_000_000_000_000_000) * UInt128(100_000_000_000_000)
        // 10^32: 33 digits, one short of full precision
        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,  // qmin
            coefficient: coefficient
        )
        #expect(value.classification == .subnormal)
    }

    /// F-003: a single significant digit at the quantum minimum is the
    /// deepest possible subnormal.
    @Test func deepestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,  // qmin
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    /// F-003 sanity check: the shared classifier (now driving zero, normal,
    /// and subnormal alike through `extractCoefficient()`) must still
    /// recognize an ordinary Form-1 zero correctly.
    @Test func zeroClassifiesAsZeroNotNormalOrSubnormal() {
        let value = Decimal.Format128.zero()
        #expect(value.classification == .zero)
        #expect(!value.test.subnormal)
    }
}
