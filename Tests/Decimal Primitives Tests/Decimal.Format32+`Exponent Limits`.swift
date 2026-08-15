import Testing

@testable import Decimal_Primitives

extension Decimal.Format32 {
    @Suite struct `Exponent Limits` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format32.`Exponent Limits`.`Edge Case` {
    /// F-002: `maxExponent`/`minExponent` (which gate `encode` and
    /// `extractExponent`) must be the quantum limits (90/-101), not the
    /// published scientific range (96/-95) that this format's own doc
    /// comment describes.
    @Test func publishesQuantumLimitsAsTheEncodingBounds() {
        #expect(Decimal.Format32.maxExponent == Decimal.Exponent(90))
        #expect(Decimal.Format32.minExponent == Decimal.Exponent(-101))
        #expect(Decimal.Exponent.Format32.scientificMax == Decimal.Exponent(96))
        #expect(Decimal.Exponent.Format32.scientificMin == Decimal.Exponent(-95))
    }

    /// F-002: a value encoded at the quantum maximum must round-trip; the
    /// unfixed `maxExponent` (96) would have let `normalize`-adjacent callers
    /// treat exponent 91...96 as valid encodable quantum exponents when they
    /// are not.
    @Test func roundTripsAtQuantumMaximum() {
        let exponent = Decimal.Exponent(90)
        let coefficient: UInt32 = 1234
        let encoded = Decimal.Format32.encode(
            sign: .positive,
            exponent: exponent,
            coefficient: coefficient
        )

        #expect(encoded.extractExponent() == exponent)
        #expect(exponent <= Decimal.Format32.maxExponent)
        #expect(Decimal.Exponent(91) > Decimal.Format32.maxExponent)
    }
}
