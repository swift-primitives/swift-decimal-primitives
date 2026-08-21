import Testing

@testable import Decimal_Primitives

extension Decimal.Format64 {
    @Suite struct `BID Round Trip` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format64.`BID Round Trip`.`Edge Case` {

    @Test func formTwoFiniteValueIsNotMisreadAsSpecial() {

        let exponent = Decimal.Exponent(202)
        let coefficient = Decimal.Format64.coefficientMax()
        let encoded = Decimal.Format64.encode(
            sign: .positive,
            exponent: exponent,
            coefficient: coefficient
        )

        #expect(encoded.classification == .normal)
        #expect(!encoded.test.infinite)
        #expect(!encoded.test.nan)
        #expect(encoded.extractExponent() == exponent)
        #expect(encoded.extractCoefficient() == coefficient)
    }

    @Test func roundTripsAcrossFormOneFormTwoCoefficientBoundary() {
        let exponent = Decimal.Exponent(17)
        let coefficients: [UInt64] = [
            (1 << 53) - 1,
            1 << 53,
            Decimal.Format64.coefficientMax(),
        ]

        for coefficient in coefficients {
            let encoded = Decimal.Format64.encode(
                sign: .positive,
                exponent: exponent,
                coefficient: coefficient
            )
            #expect(encoded.extractExponent() == exponent)
            #expect(encoded.extractCoefficient() == coefficient)
        }
    }
}
