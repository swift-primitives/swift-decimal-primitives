extension Decimal {
    /// Internal protocol for algorithm sharing across formats
    @usableFromInline
    internal protocol Layout: Sendable, Hashable {
        /// Number of decimal digits of precision
        static var precision: Precision { get }

        /// Maximum exponent
        static var maxExponent: Exponent { get }

        /// Minimum exponent
        static var minExponent: Exponent { get }

        /// Exponent bias
        static var bias: Int { get }
    }
}
