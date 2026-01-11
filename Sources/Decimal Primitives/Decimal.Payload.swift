extension Decimal {
    public struct Payload: Sendable, Hashable {
        public let value: UInt64

        public init(_ value: UInt64) {
            self.value = value
        }
    }
}

extension Decimal.Payload {
    public static let none = Self(0)
}
