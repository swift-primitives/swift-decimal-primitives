extension Decimal {
    /// Result of IEEE 754 total ordering (always defined)
    public enum Order: Sendable, Hashable {
        case less
        case equal
        case greater
    }
}
