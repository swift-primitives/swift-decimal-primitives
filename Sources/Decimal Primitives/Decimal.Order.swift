extension Decimal {
    /// The result of the IEEE 754 total ordering, which is defined for every pair of values.
    public enum Order: Sendable, Hashable {
        /// The left operand orders before the right operand.
        case less

        /// The two operands share the same position in the total order.
        case equal

        /// The left operand orders after the right operand.
        case greater
    }
}
