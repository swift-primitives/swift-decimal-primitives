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

    @Test func formTwoFiniteValueIsNotMisreadAsSpecial() {
        let biasedExponent: UInt64 = 6276
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

    @Test func roundTripsAcrossFormOneFormTwoCoefficientBoundary() {
        let exponent = Decimal.Exponent(100)
        let coefficients: [UInt128] = [
            UInt128(123_456),
            Decimal.Format128.coefficientMax(),
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
