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
    /// F-001: a Form-2 finite value whose combination field is `11100`
    /// (G0=G1=1, G2=1, G3=0) must decode as finite.
    ///
    /// A decoder that treats G2 alone as the special-value marker misreads
    /// it as infinity/NaN.
    @Test func formTwoFiniteValueIsNotMisreadAsSpecial() {
        // biased exponent 600 = 0b10_0101_1000 -> top two bits (G2, G3) = (1, 0)
        let exponent = Decimal.Exponent(202)
        let coefficient = Decimal.Format64.coefficientMax()  // forces Form 2 (> 2^53 - 1)
        let encoded = Decimal.Format64.encode(sign: .positive, exponent: exponent, coefficient: coefficient)

        #expect(encoded.classification == .normal)
        #expect(!encoded.test.infinite)
        #expect(!encoded.test.nan)
        #expect(encoded.extractExponent() == exponent)
        #expect(encoded.extractCoefficient() == coefficient)
    }

    /// F-001: decode must read the same exponent bit window that encode
    /// writes, across the Form-1/Form-2 coefficient boundary (2^53).
    @Test func roundTripsAcrossFormOneFormTwoCoefficientBoundary() {
        let exponent = Decimal.Exponent(17)
        let coefficients: [UInt64] = [
            (1 << 53) - 1,  // largest Form 1 coefficient
            1 << 53,  // smallest Form 2 coefficient
            Decimal.Format64.coefficientMax(),
        ]

        for coefficient in coefficients {
            let encoded = Decimal.Format64.encode(sign: .positive, exponent: exponent, coefficient: coefficient)
            #expect(encoded.extractExponent() == exponent)
            #expect(encoded.extractCoefficient() == coefficient)
        }
    }
}
