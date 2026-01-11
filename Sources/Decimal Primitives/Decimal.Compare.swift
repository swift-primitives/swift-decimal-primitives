extension Decimal {
    /// Result of numerical comparison (NaN yields unordered)
    public enum Compare: Sendable, Hashable {
        case less
        case equal
        case greater
        case unordered
    }
}
