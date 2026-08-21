extension Decimal {

    public enum Compare: Sendable, Hashable {

        case less

        case equal

        case greater

        case unordered
    }
}
