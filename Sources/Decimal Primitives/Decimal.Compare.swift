extension Decimal {
    /// The result of an IEEE 754 arithmetic comparison, where a NaN operand yields `unordered`.
    public enum Compare: Sendable, Hashable {
        /// The left operand compares less than the right operand.
        case less

        /// The two operands compare equal.
        case equal

        /// The left operand compares greater than the right operand.
        case greater

        /// At least one operand is NaN, leaving the operands unordered.
        case unordered
    }
}
