import Testing

@testable import Decimal_Primitives

extension Decimal.Format128 {
    @Suite struct `Integer Conversion` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format128.`Integer Conversion`.`Edge Case` {

    @Test func roundTripsInt64MinWithoutTrapping() {
        let value = Decimal.Format128(Int64.min)
        #expect(Int64(exactly: value) == Int64.min)
    }

    @Test func decodesInt64MinFromDirectlyEncodedCoefficientWithoutTrapping() {
        let magnitude = UInt128(UInt64(Int64.max)) + 1
        let encoded = Decimal.Format128.encode(sign: .negative, exponent: 0, coefficient: magnitude)
        #expect(Int64(exactly: encoded) == Int64.min)
    }
}
