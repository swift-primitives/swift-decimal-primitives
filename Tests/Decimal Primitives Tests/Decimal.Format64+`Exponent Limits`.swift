import Testing

@testable import Decimal_Primitives

extension Decimal.Format64 {
    @Suite struct `Exponent Limits` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format64.`Exponent Limits`.`Edge Case` {

    @Test func publishesQuantumLimitsAsTheEncodingBounds() {
        #expect(Decimal.Format64.maxExponent == Decimal.Exponent(369))
        #expect(Decimal.Format64.minExponent == Decimal.Exponent(-398))
        #expect(Decimal.Exponent.Format64.scientificMax == Decimal.Exponent(384))
        #expect(Decimal.Exponent.Format64.scientificMin == Decimal.Exponent(-383))
    }

    @Test func normalizeStopsAtQuantumMaximumNotScientificMaximum() {
        let coefficient: UInt64 = 10_000_000_000_000_000_000
        let exponent = Decimal.Exponent(365)

        let (normalizedCoefficient, normalizedExponent) = Decimal.Format64.normalize(
            coefficient: coefficient,
            exponent: exponent
        )

        #expect(normalizedExponent == Decimal.Exponent(369))
        #expect(normalizedCoefficient == 1_000_000_000_000_000)
    }
}
