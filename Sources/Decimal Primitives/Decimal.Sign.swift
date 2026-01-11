extension Decimal {
    public enum Sign: Sendable, Hashable, CaseIterable {
        case positive
        case negative
    }
}

extension Decimal.Sign {
    public static func opposite(of sign: Self) -> Self {
        switch sign {
        case .positive: .negative
        case .negative: .positive
        }
    }

    public var opposite: Self {
        Self.opposite(of: self)
    }

    public static func multiplying(_ lhs: Self, _ rhs: Self) -> Self {
        lhs == rhs ? .positive : .negative
    }
}
