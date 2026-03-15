extension Decimal {
    /// Protocol for IEEE 754 decimal floating-point formats.
    ///
    /// Conformers: ``Format32``, ``Format64``, ``Format128``.
    public protocol Layout: Sendable, Hashable {
        /// Number of decimal digits of precision.
        static var precision: Precision { get }

        /// Maximum exponent.
        static var maxExponent: Exponent { get }

        /// Minimum exponent.
        static var minExponent: Exponent { get }

        /// Exponent bias.
        static var bias: Int { get }

        /// The IEEE 754 classification of this value.
        var classification: Class { get }

        /// The sign of this value.
        var sign: Sign { get }
    }
}
