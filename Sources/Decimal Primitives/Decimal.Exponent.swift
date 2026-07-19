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
    ///
    /// `max`/`min` are the **quantum** exponent limits — the range of the
    /// exponent actually stored in and extracted from the encoding (`value
    /// = coefficient × 10^exponent`), and the values that gate `encode`,
    /// `extractExponent`, and `normalize`. `scientificMax`/`scientificMin`
    /// are the IEEE 754-2008 Emax/Emin — the exponent of the *normalized*
    /// (one-digit-before-the-point) form, used only for subnormal/overflow
    /// classification. `quantum = scientific - (precision - 1)`.
    public enum Format32 {
        /// The maximum encodable (quantum) exponent of the 32-bit format.
        public static let max: Decimal.Exponent = 90

        /// The minimum encodable (quantum) exponent of the 32-bit format.
        public static let min: Decimal.Exponent = -101

        /// The bias added to the exponent when encoding the 32-bit format.
        public static let bias: Int = 101

        /// The maximum exponent of the scientific (normalized) range, Emax.
        public static let scientificMax: Decimal.Exponent = 96

        /// The minimum exponent of the scientific (normalized) range, Emin.
        public static let scientificMin: Decimal.Exponent = -95
    }

    /// The exponent range and bias of the 64-bit decimal format.
    ///
    /// See ``Format32`` for the quantum-vs-scientific distinction.
    public enum Format64 {
        /// The maximum encodable (quantum) exponent of the 64-bit format.
        public static let max: Decimal.Exponent = 369

        /// The minimum encodable (quantum) exponent of the 64-bit format.
        public static let min: Decimal.Exponent = -398

        /// The bias added to the exponent when encoding the 64-bit format.
        public static let bias: Int = 398

        /// The maximum exponent of the scientific (normalized) range, Emax.
        public static let scientificMax: Decimal.Exponent = 384

        /// The minimum exponent of the scientific (normalized) range, Emin.
        public static let scientificMin: Decimal.Exponent = -383
    }

    /// The exponent range and bias of the 128-bit decimal format.
    ///
    /// See ``Format32`` for the quantum-vs-scientific distinction.
    public enum Format128 {
        /// The maximum encodable (quantum) exponent of the 128-bit format.
        public static let max: Decimal.Exponent = 6111

        /// The minimum encodable (quantum) exponent of the 128-bit format.
        public static let min: Decimal.Exponent = -6176

        /// The bias added to the exponent when encoding the 128-bit format.
        public static let bias: Int = 6176

        /// The maximum exponent of the scientific (normalized) range, Emax.
        public static let scientificMax: Decimal.Exponent = 6144

        /// The minimum exponent of the scientific (normalized) range, Emin.
        public static let scientificMin: Decimal.Exponent = -6143
    }
}
