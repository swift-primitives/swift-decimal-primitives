extension Decimal {

    public protocol Layout: Sendable, Hashable {

        static var precision: Precision { get }

        static var maxExponent: Exponent { get }

        static var minExponent: Exponent { get }

        static var bias: Int { get }

        var classification: Class { get }

        var sign: Sign { get }
    }
}
