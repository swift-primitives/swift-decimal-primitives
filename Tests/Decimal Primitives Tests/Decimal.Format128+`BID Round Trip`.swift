import Testing

@testable import Decimal_Primitives

extension Decimal.Format128 {
    @Suite struct `BID Round Trip` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format128.`BID Round Trip`.`Edge Case` {
    /// F-001: a Form-2 finite value whose combination field is `11100`
    /// (G0=G1=1, G2=1, G3=0) must decode as finite.
    ///
    /// A decoder that treats G2 alone as the special-value marker misreads
    /// it as infinity/NaN.
    ///
    /// This package's own `encode` never sets G2 (it only ever writes
    /// `110...`), so the bit pattern is built directly — matching a
    /// conforming value from an external BID producer, which is exactly
    /// the "fleet consumer" scenario the finding calls out.
    @Test func formTwoFiniteValueIsNotMisreadAsSpecial() {
        let biasedExponent: UInt64 = 6276  // unbiased 100; bit 13 (G3) is 0 since 6276 < 8192
        let g0g1: UInt64 = 0b11 << 61
        let g2: UInt64 = 0b1 << 60
        let coeffHighMasked: UInt64 = 0x1
        let high = g0g1 | g2 | (biasedExponent << 46) | coeffHighMasked
        let low: UInt64 = 0x1234_5678_9ABC_DEF0

        let value = Decimal.Format128(high: high, low: low)
        let expectedCoefficient =
            (UInt128(coeffHighMasked | (UInt64(8) << 46)) << 64) | UInt128(low)

        #expect(value.classification == .normal)
        #expect(!value.test.infinite)
        #expect(!value.test.nan)
        #expect(value.extractExponent() == Decimal.Exponent(100))
        #expect(value.extractCoefficient() == expectedCoefficient)
    }

    /// F-001: decode must read the same exponent bit window that encode
    /// writes, across the Form-1/Form-2 coefficient boundary.
    @Test func roundTripsAcrossFormOneFormTwoCoefficientBoundary() {
        let exponent = Decimal.Exponent(100)
        let coefficients: [UInt128] = [
            UInt128(123_456),  // Form 1 (coefficient high half is 0)
            Decimal.Format128.coefficientMax(),  // Form 2
        ]

        for coefficient in coefficients {
            let encoded = Decimal.Format128.encode(
                sign: .positive,
                exponent: exponent,
                coefficient: coefficient
            )
            #expect(encoded.extractExponent() == exponent)
            #expect(encoded.extractCoefficient() == coefficient)
        }
    }
}
