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

    @Test func smallestNormalAtQuantumMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,
            coefficient: 1_000_000
        )
        #expect(value.classification == .normal)
    }

    @Test func largestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,
            coefficient: 999_999
        )
        #expect(value.classification == .subnormal)
    }

    @Test func deepestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func subnormalOneExponentStepAboveMinimum() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent + 1,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }
}
