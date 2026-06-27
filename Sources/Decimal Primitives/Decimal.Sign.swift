extension Decimal {
    /// The sign of a decimal floating-point value.
    public enum Sign: Sendable, Hashable, CaseIterable {
        /// The positive sign.
        case positive

        /// The negative sign.
        case negative
    }
}

extension Decimal.Sign {
    /// Returns the sign with the opposite polarity.
    public static func opposite(of sign: Self) -> Self {
        switch sign {
        case .positive: .negative
        case .negative: .positive
        }
    }

    /// The sign with the opposite polarity.
    public var opposite: Self {
        Self.opposite(of: self)
    }

    /// Returns the sign of a product, following the rule of signs.
    public static func multiplying(_ lhs: Self, _ rhs: Self) -> Self {
        lhs == rhs ? .positive : .negative
    }
}
