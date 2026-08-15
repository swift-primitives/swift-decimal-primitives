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
    /// F-001: a Form-2 finite value whose combination field is `11100`
    /// (G0=G1=1, G2=1, G3=0) must decode as finite.
    ///
    /// A decoder that treats G2 alone as the special-value marker misreads
    /// it as infinity/NaN.
    @Test func formTwoFiniteValueIsNotMisreadAsSpecial() {
        // biased exponent 150 = 0b1001_0110 -> top two bits (G2, G3) = (1, 0)
        let exponent = Decimal.Exponent(49)
        let coefficient = Decimal.Format32.coefficientMax()  // forces Form 2 (> 2^23 - 1)
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

    /// F-001: decode must read the same exponent bit window that encode
    /// writes, across the Form-1/Form-2 coefficient boundary (2^23).
    @Test func roundTripsAcrossFormOneFormTwoCoefficientBoundary() {
        let exponent = Decimal.Exponent(13)
        let coefficients: [UInt32] = [
            (1 << 23) - 1,  // largest Form 1 coefficient
            1 << 23,  // smallest Form 2 coefficient
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
