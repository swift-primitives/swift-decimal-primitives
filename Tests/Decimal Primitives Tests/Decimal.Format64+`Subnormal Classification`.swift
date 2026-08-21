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

    @Test func smallestNormalAtQuantumMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
        #expect(!value.test.subnormal)
    }

    @Test func largestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,
            coefficient: 999_999_999_999_999
        )
        #expect(value.classification == .subnormal)
        #expect(value.test.subnormal)
    }

    @Test func deepestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func normalOneExponentStepAboveMinimum() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent + 1,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
    }
}
