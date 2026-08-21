extension Decimal {

    public struct Precision: Sendable, Hashable {

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

extension Decimal.Precision: ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

extension Decimal.Precision: Comparable {

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Decimal.Precision {

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
}

extension Int {

    @inlinable
    public init(_ precision: Decimal.Precision) {
        self = precision.rawValue
    }
}

extension Decimal.Precision {

    public static let format32: Self = 7

    public static let format64: Self = 16

    public static let format128: Self = 34
}
