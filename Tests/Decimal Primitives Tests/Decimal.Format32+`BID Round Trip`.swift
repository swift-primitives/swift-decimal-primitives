import Testing

@testable import Decimal_Primitives

extension Decimal.Format32 {
    @Suite struct `BID Round Trip` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format32.`BID Round Trip`.`Edge Case` {

    @Test func formTwoFiniteValueIsNotMisreadAsSpecial() {

        let exponent = Decimal.Exponent(49)
        let coefficient = Decimal.Format32.coefficientMax()
        let encoded = Decimal.Format32.encode(
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
        let exponent = Decimal.Exponent(13)
        let coefficients: [UInt32] = [
            (1 << 23) - 1,
            1 << 23,
            Decimal.Format32.coefficientMax(),
        ]

        for coefficient in coefficients {
            let encoded = Decimal.Format32.encode(
                sign: .positive,
                exponent: exponent,
                coefficient: coefficient
            )
            #expect(encoded.extractExponent() == exponent)
            #expect(encoded.extractCoefficient() == coefficient)
        }
    }
}
