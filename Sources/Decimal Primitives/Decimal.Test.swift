extension Decimal {
    public struct Test<Value> {
        @usableFromInline
        let base: Value

        @usableFromInline
        internal init(_ base: Value) {
            self.base = base
        }
    }
}

extension Decimal.Test: Sendable where Value: Sendable { }

extension Decimal.Format64 {
    public var test: Decimal.Test<Self> {
        Decimal.Test(self)
    }
}

extension Decimal.Test where Value == Decimal.Format64 {
    /// True if quiet or signaling NaN
    public var nan: Bool {
        let c = base.classification
        return c == .quiet || c == .signaling
    }

    /// True if signaling NaN
    public var signaling: Bool {
        base.classification == .signaling
    }

    /// True if infinite
    public var infinite: Bool {
        base.classification == .infinite
    }

    /// True if finite (not NaN, not infinite)
    public var finite: Bool {
        !nan && !infinite
    }

    /// True if zero
    public var zero: Bool {
        base.classification == .zero
    }

    /// True if negative
    public var negative: Bool {
        base.sign == .negative
    }

    /// True if normal
    public var normal: Bool {
        base.classification == .normal
    }

    /// True if subnormal
    public var subnormal: Bool {
        base.classification == .subnormal
    }
}
