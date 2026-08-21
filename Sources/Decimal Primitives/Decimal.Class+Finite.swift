extension Decimal.Class {

    @inlinable
    public static func classifyFinite<Coefficient: BinaryInteger>(
        coefficient: Coefficient,
        exponent: Decimal.Exponent,
        scientificMin: Decimal.Exponent
    ) -> Self {
        guard coefficient != 0 else { return .zero }

        var digits = 1
        var remaining = coefficient
        while remaining >= 10 {
            remaining /= 10
            digits += 1
        }

        let adjustedExponent = Int(exponent) + digits - 1
        return adjustedExponent < Int(scientificMin) ? .subnormal : .normal
    }
}
