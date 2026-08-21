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

    @Test func smallestNormalAtQuantumMinimum() {
        let coefficient = UInt128(1_000_000_000_000_000_000) * UInt128(1_000_000_000_000_000)

        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,
            coefficient: coefficient
        )
        #expect(value.classification == .normal)
    }

    @Test func largestSubnormalAtQuantumMinimum() {
        let coefficient = UInt128(1_000_000_000_000_000_000) * UInt128(100_000_000_000_000)

        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,
            coefficient: coefficient
        )
        #expect(value.classification == .subnormal)
    }

    @Test func deepestSubnormalAtQuantumMinimum() {
        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func zeroClassifiesAsZeroNotNormalOrSubnormal() {
        let value = Decimal.Format128.zero()
        #expect(value.classification == .zero)
        #expect(!value.test.subnormal)
    }
}
