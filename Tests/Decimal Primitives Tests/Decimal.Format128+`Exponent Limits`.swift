import Testing

@testable import Decimal_Primitives

extension Decimal.Format128 {
    @Suite struct `Exponent Limits` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format128.`Exponent Limits`.`Edge Case` {
    /// F-002: `maxExponent`/`minExponent` (which gate `encode` and
    /// `extractExponent`) must be the quantum limits (6111/-6176), not the
    /// published scientific range (6144/-6143) that this format's own doc
    /// comment describes.
    @Test func publishesQuantumLimitsAsTheEncodingBounds() {
        #expect(Decimal.Format128.maxExponent == Decimal.Exponent(6111))
        #expect(Decimal.Format128.minExponent == Decimal.Exponent(-6176))
        #expect(Decimal.Exponent.Format128.scientificMax == Decimal.Exponent(6144))
        #expect(Decimal.Exponent.Format128.scientificMin == Decimal.Exponent(-6143))
    }

    /// F-002: an exponent between the quantum maximum and the scientific
    /// maximum must be reported as out of the encodable range.
    @Test func quantumMaximumIsStricterThanScientificMaximum() {
        #expect(Decimal.Exponent(6111) <= Decimal.Format128.maxExponent)
        #expect(Decimal.Exponent(6120) > Decimal.Format128.maxExponent)
    }
}
