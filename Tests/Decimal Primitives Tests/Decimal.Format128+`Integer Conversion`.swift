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
    /// F-004: `Int64.min`'s magnitude fits easily within this format's
    /// 34-digit precision, so the round trip must succeed — the unfixed
    /// forward initializer instead traps while computing `-Int64.min`.
    @Test func roundTripsInt64MinWithoutTrapping() {
        let value = Decimal.Format128(Int64.min)
        #expect(Int64(exactly: value) == Int64.min)
    }

    /// F-004 ("decimal128 -2^63"): the reverse direction (`Int64.init?(exactly:)`)
    /// must not trap on the coefficient/exponent combination that reconstructs
    /// to exactly `Int64.min`'s magnitude, exercised independently of the
    /// forward-direction fix by encoding the coefficient directly.
    @Test func decodesInt64MinFromDirectlyEncodedCoefficientWithoutTrapping() {
        let magnitude = UInt128(UInt64(Int64.max)) + 1  // Int64.min's magnitude
        let encoded = Decimal.Format128.encode(sign: .negative, exponent: 0, coefficient: magnitude)
        #expect(Int64(exactly: encoded) == Int64.min)
    }
}
