extension Decimal {
    public enum Class: Sendable, Hashable, CaseIterable {
        case quiet
        case signaling
        case infinite
        case zero
        case subnormal
        case normal
    }
}
