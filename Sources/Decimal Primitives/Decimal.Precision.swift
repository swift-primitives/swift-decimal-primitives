extension Decimal {
    /// Number of significant decimal digits
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

// MARK: - Literals

extension Decimal.Precision: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

// MARK: - Comparison

extension Decimal.Precision: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Arithmetic

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

// MARK: - Integer Conversion

extension Int {
    /// Initialize from Decimal.Precision
    @inlinable
    public init(_ precision: Decimal.Precision) {
        self = precision.rawValue
    }
}

// MARK: - Format Constants

extension Decimal.Precision {
    /// Precision for Format32 (7 digits)
    public static let format32: Self = 7

    /// Precision for Format64 (16 digits)
    public static let format64: Self = 16

    /// Precision for Format128 (34 digits)
    public static let format128: Self = 34
}
