extension Decimal.Class {
    /// Classifies a finite (non-special) decimal value from its coefficient,
    /// quantum exponent, and the format's scientific minimum exponent (Emin).
    ///
    /// A value is subnormal per IEEE 754-2008 when it is nonzero and its
    /// *scientific* (adjusted) exponent — `exponent + digitCount(coefficient)
    /// - 1` — falls below `scientificMin`: it carries fewer significant
    /// digits than the format's precision because the quantum exponent has
    /// bottomed out. Implemented once and shared by ``Decimal/Format32``,
    /// ``Decimal/Format64``, and ``Decimal/Format128``, so all three formats
    /// agree on the boundary.
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
