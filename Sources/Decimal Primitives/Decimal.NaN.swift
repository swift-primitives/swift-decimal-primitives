extension Decimal {
    /// A kind of IEEE 754 not-a-number value.
    public enum NaN: Sendable, Hashable {
        /// A quiet NaN, which propagates through operations without raising an exception.
        case quiet

        /// A signaling NaN, which raises the invalid-operation exception when used as an operand.
        case signaling
    }
}
