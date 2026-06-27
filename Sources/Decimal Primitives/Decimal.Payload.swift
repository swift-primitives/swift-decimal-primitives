extension Decimal {
    /// The diagnostic payload carried in the trailing significand of a NaN.
    public struct Payload: Sendable, Hashable {
        /// The raw payload bits held in the NaN's trailing significand.
        public let value: UInt64

        /// Creates a payload from its raw trailing-significand bits.
        public init(_ value: UInt64) {
            self.value = value
        }
    }
}

extension Decimal.Payload {
    /// The empty payload, with all diagnostic bits cleared.
    public static let none = Self(0)
}
