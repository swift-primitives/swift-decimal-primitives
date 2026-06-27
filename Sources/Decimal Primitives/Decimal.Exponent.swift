extension Decimal {
    /// A decimal exponent expressed as a signed power of ten.
    public struct Exponent: Sendable, Hashable {
        /// The exponent value as a signed power of ten.
        public var rawValue: Int

        /// Creates an exponent from a signed power of ten.
        @inlinable
        public init(_ value: Int) {
            self.rawValue = value
        }

        /// Creates an exponent from its underlying power-of-ten value.
        @inlinable
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Literals

extension Decimal.Exponent: ExpressibleByIntegerLiteral {
    /// Creates an exponent from an integer literal power of ten.
    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

// MARK: - Comparison

extension Decimal.Exponent: Comparable {
    /// Orders two exponents by their power-of-ten value.
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Arithmetic

extension Decimal.Exponent {
    /// Returns the sum of two exponents.
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue + rhs.rawValue)
    }

    /// Returns the difference of two exponents.
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.rawValue - rhs.rawValue)
    }

    /// Returns the exponent shifted up by an integer number of powers of ten.
    @inlinable
    public static func + (lhs: Self, rhs: Int) -> Self {
        Self(lhs.rawValue + rhs)
    }

    /// Returns the exponent shifted down by an integer number of powers of ten.
    @inlinable
    public static func - (lhs: Self, rhs: Int) -> Self {
        Self(lhs.rawValue - rhs)
    }

    /// Adds another exponent into this one in place.
    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Shifts this exponent up in place by an integer number of powers of ten.
    @inlinable
    public static func += (lhs: inout Self, rhs: Int) {
        lhs = lhs + rhs
    }

    /// Returns the additive inverse of the exponent.
    @inlinable
    public static prefix func - (value: Self) -> Self {
        Self(-value.rawValue)
    }
}

// MARK: - Integer Conversion

extension Int {
    /// Creates an integer from a decimal exponent's power-of-ten value.
    @inlinable
    public init(_ exponent: Decimal.Exponent) {
        self = exponent.rawValue
    }
}

// MARK: - Format Limits

extension Decimal.Exponent {
    /// The exponent range and bias of the 32-bit decimal format.
    public enum Format32 {
        /// The maximum encodable exponent of the 32-bit format.
        public static let max: Decimal.Exponent = 96

        /// The minimum encodable exponent of the 32-bit format.
        public static let min: Decimal.Exponent = -95

        /// The bias added to the exponent when encoding the 32-bit format.
        public static let bias: Int = 101
    }

    /// The exponent range and bias of the 64-bit decimal format.
    public enum Format64 {
        /// The maximum encodable exponent of the 64-bit format.
        public static let max: Decimal.Exponent = 384

        /// The minimum encodable exponent of the 64-bit format.
        public static let min: Decimal.Exponent = -383

        /// The bias added to the exponent when encoding the 64-bit format.
        public static let bias: Int = 398
    }

    /// The exponent range and bias of the 128-bit decimal format.
    public enum Format128 {
        /// The maximum encodable exponent of the 128-bit format.
        public static let max: Decimal.Exponent = 6144

        /// The minimum encodable exponent of the 128-bit format.
        public static let min: Decimal.Exponent = -6143

        /// The bias added to the exponent when encoding the 128-bit format.
        public static let bias: Int = 6176
    }
}
