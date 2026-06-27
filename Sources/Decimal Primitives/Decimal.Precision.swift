extension Decimal {
    /// A count of significant decimal digits.
    public struct Precision: Sendable, Hashable {
        /// The number of significant decimal digits.
        public var rawValue: Int

        /// Creates a precision from a count of significant decimal digits.
        @inlinable
        public init(_ value: Int) {
            self.rawValue = value
        }

        /// Creates a precision from its underlying digit count.
        @inlinable
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Literals

extension Decimal.Precision: ExpressibleByIntegerLiteral {
    /// Creates a precision from an integer literal digit count.
    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

// MARK: - Comparison

extension Decimal.Precision: Comparable {
    /// Orders two precisions by their digit count.
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Arithmetic

extension Decimal.Precision {
    /// Returns the sum of two precisions.
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue + rhs.rawValue)
    }

    /// Returns the difference of two precisions.
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue - rhs.rawValue)
    }

    /// Returns the precision increased by an integer number of digits.
    @inlinable
    public static func + (lhs: Self, rhs: Int) -> Self {
        Self(lhs.rawValue + rhs)
    }

    /// Returns the precision decreased by an integer number of digits.
    @inlinable
    public static func - (lhs: Self, rhs: Int) -> Self {
        Self(lhs.rawValue - rhs)
    }
}

// MARK: - Integer Conversion

extension Int {
    /// Creates an integer from a decimal precision's digit count.
    @inlinable
    public init(_ precision: Decimal.Precision) {
        self = precision.rawValue
    }
}

// MARK: - Format Constants

extension Decimal.Precision {
    /// The precision of the 32-bit decimal format, which is 7 digits.
    public static let format32: Self = 7

    /// The precision of the 64-bit decimal format, which is 16 digits.
    public static let format64: Self = 16

    /// The precision of the 128-bit decimal format, which is 34 digits.
    public static let format128: Self = 34
}
