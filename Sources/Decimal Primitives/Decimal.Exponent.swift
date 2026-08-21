extension Decimal {

    public struct Exponent: Sendable, Hashable {

        public var rawValue: Int

        @inlinable
        public init(_ value: Int) {
            self.rawValue = value
        }

        @inlinable
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension Decimal.Exponent: ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

extension Decimal.Exponent: Comparable {

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Decimal.Exponent {

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue + rhs.rawValue)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue - rhs.rawValue)
    }

    @inlinable
    public static func + (lhs: Self, rhs: Int) -> Self {
        Self(lhs.rawValue + rhs)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Int) -> Self {
        Self(lhs.rawValue - rhs)
    }

    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    @inlinable
    public static func += (lhs: inout Self, rhs: Int) {
        lhs = lhs + rhs
    }

    @inlinable
    public static prefix func - (value: Self) -> Self {
        Self(-value.rawValue)
    }
}

extension Int {

    @inlinable
    public init(_ exponent: Decimal.Exponent) {
        self = exponent.rawValue
    }
}

extension Decimal.Exponent {

    public enum Format32 {

        public static let max: Decimal.Exponent = 90

        public static let min: Decimal.Exponent = -101

        public static let bias: Int = 101

        public static let scientificMax: Decimal.Exponent = 96

        public static let scientificMin: Decimal.Exponent = -95
    }

    public enum Format64 {

        public static let max: Decimal.Exponent = 369

        public static let min: Decimal.Exponent = -398

        public static let bias: Int = 398

        public static let scientificMax: Decimal.Exponent = 384

        public static let scientificMin: Decimal.Exponent = -383
    }

    public enum Format128 {

        public static let max: Decimal.Exponent = 6111

        public static let min: Decimal.Exponent = -6176

        public static let bias: Int = 6176

        public static let scientificMax: Decimal.Exponent = 6144

        public static let scientificMin: Decimal.Exponent = -6143
    }
}
