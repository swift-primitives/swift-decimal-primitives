extension Decimal {
    public enum NaN: Sendable, Hashable {
        case quiet
        case signaling
    }
}
