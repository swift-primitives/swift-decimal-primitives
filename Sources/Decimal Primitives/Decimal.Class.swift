extension Decimal {
    /// The IEEE 754 class of a decimal floating-point value.
    public enum Class: Sendable, Hashable, CaseIterable {
        /// A quiet NaN.
        case quiet

        /// A signaling NaN.
        case signaling

        /// A signed infinity.
        case infinite

        /// A signed zero.
        case zero

        /// A subnormal finite value.
        case subnormal

        /// A normal finite value.
        case normal
    }
}
