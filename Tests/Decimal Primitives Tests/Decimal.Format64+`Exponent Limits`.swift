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
    /// F-002: `maxExponent`/`minExponent` (which gate `encode`, `extractExponent`,
    /// and `normalize`) must be the quantum limits (369/-398), not the published
    /// scientific range (384/-383) that this format's own doc comment describes.
    @Test func publishesQuantumLimitsAsTheEncodingBounds() {
        #expect(Decimal.Format64.maxExponent == Decimal.Exponent(369))
        #expect(Decimal.Format64.minExponent == Decimal.Exponent(-398))
        #expect(Decimal.Exponent.Format64.scientificMax == Decimal.Exponent(384))
        #expect(Decimal.Exponent.Format64.scientificMin == Decimal.Exponent(-383))
    }

    /// F-002: `normalize` must stop stripping trailing zeros at the quantum
    /// maximum (369), not the scientific maximum (384) — a coefficient with
    /// enough trailing zeros to reach the old, wrong bound must instead stop
    /// 15 exponent-steps earlier, at the correct bound.
    @Test func normalizeStopsAtQuantumMaximumNotScientificMaximum() {
        let coefficient: UInt64 = 10_000_000_000_000_000_000  // 10^19: 19 trailing zeros
        let exponent = Decimal.Exponent(365)

        let (normalizedCoefficient, normalizedExponent) = Decimal.Format64.normalize(
            coefficient: coefficient,
            exponent: exponent
        )

        #expect(normalizedExponent == Decimal.Exponent(369))
        #expect(normalizedCoefficient == 1_000_000_000_000_000)
    }
}
