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

extension Decimal.Layout {
    public var test: Decimal.Test<Self> {
        Decimal.Test(self)
    }
}

extension Decimal.Test where Value: Decimal.Layout {
    public var nan: Bool {
        let c = base.classification
        return c == .quiet || c == .signaling
    }

    public var signaling: Bool {
        base.classification == .signaling
    }

    public var infinite: Bool {
        base.classification == .infinite
    }

    public var finite: Bool {
        !nan && !infinite
    }

    public var zero: Bool {
        base.classification == .zero
    }

    public var negative: Bool {
        base.sign == .negative
    }

    public var normal: Bool {
        base.classification == .normal
    }

    public var subnormal: Bool {
        base.classification == .subnormal
    }
}
