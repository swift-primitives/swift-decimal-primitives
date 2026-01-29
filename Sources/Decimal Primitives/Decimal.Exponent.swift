extension Decimal {
    /// Decimal exponent value (power of 10)
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

// MARK: - Literals

extension Decimal.Exponent: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

// MARK: - Comparison

extension Decimal.Exponent: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Arithmetic

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
    public static prefix func - (value: Self) -> Self {
        Self(-value.rawValue)
    }
}

// MARK: - Integer Conversion

extension Int {
    /// Initialize from Decimal.Exponent
    @inlinable
    public init(_ exponent: Decimal.Exponent) {
        self = exponent.rawValue
    }
}

// MARK: - Format Limits

extension Decimal.Exponent {
    /// Exponent limits for Format32
    public enum Format32 {
        public static let max: Decimal.Exponent = 96
        public static let min: Decimal.Exponent = -95
        public static let bias: Int = 101
    }

    /// Exponent limits for Format64
    public enum Format64 {
        public static let max: Decimal.Exponent = 384
        public static let min: Decimal.Exponent = -383
        public static let bias: Int = 398
    }

    /// Exponent limits for Format128
    public enum Format128 {
        public static let max: Decimal.Exponent = 6144
        public static let min: Decimal.Exponent = -6143
        public static let bias: Int = 6176
    }
}
