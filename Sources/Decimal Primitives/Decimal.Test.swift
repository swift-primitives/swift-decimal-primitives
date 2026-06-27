extension Decimal {
    /// A namespace of Boolean classification queries on a decimal value.
    public struct Test<Value> {
        @usableFromInline
        let base: Value

        @usableFromInline
        internal init(_ base: Value) {
            self.base = base
        }
    }
}

extension Decimal.Test: Sendable where Value: Sendable {}

extension Decimal.Layout {
    /// Boolean classification queries for this value.
    public var test: Decimal.Test<Self> {
        Decimal.Test(self)
    }
}

extension Decimal.Test where Value: Decimal.Layout {
    /// A Boolean value indicating whether the value is a NaN, whether quiet or signaling.
    public var nan: Bool {
        let c = base.classification
        return c == .quiet || c == .signaling
    }

    /// A Boolean value indicating whether the value is a signaling NaN.
    public var signaling: Bool {
        base.classification == .signaling
    }

    /// A Boolean value indicating whether the value is an infinity.
    public var infinite: Bool {
        base.classification == .infinite
    }

    /// A Boolean value indicating whether the value is finite, that is neither NaN nor infinite.
    public var finite: Bool {
        !nan && !infinite
    }

    /// A Boolean value indicating whether the value is a zero.
    public var zero: Bool {
        base.classification == .zero
    }

    /// A Boolean value indicating whether the value is negative.
    public var negative: Bool {
        base.sign == .negative
    }

    /// A Boolean value indicating whether the value is a normal finite value.
    public var normal: Bool {
        base.classification == .normal
    }

    /// A Boolean value indicating whether the value is a subnormal finite value.
    public var subnormal: Bool {
        base.classification == .subnormal
    }
}
