extension Decimal {
    /// 128-bit decimal floating-point (IEEE 754-2008, BID encoding)
    /// - 34 decimal digits of precision
    /// - Exponent range: -6143 to +6144
    public struct Format128: Sendable, Hashable {
        @usableFromInline
        internal var high: UInt64

        @usableFromInline
        internal var low: UInt64

        public init(high: UInt64, low: UInt64) {
            self.high = high
            self.low = low
        }
    }
}

// MARK: - Layout Conformance

extension Decimal.Format128: Decimal.Layout {
    @usableFromInline
    internal static var precision: Decimal.Precision { .format128 }

    @usableFromInline
    internal static var maxExponent: Decimal.Exponent { .Format128.max }

    @usableFromInline
    internal static var minExponent: Decimal.Exponent { .Format128.min }

    @usableFromInline
    internal static var bias: Int { Decimal.Exponent.Format128.bias }
}

// MARK: - Canonical Factories

extension Decimal.Format128 {
    public static func zero(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        return Self(high: signBit | 0x3040_0000_0000_0000, low: 0)
    }

    public static func infinity(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        return Self(high: signBit | 0x7800_0000_0000_0000, low: 0)
    }

    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        let base: UInt64 = kind == .signaling ? 0x7E00_0000_0000_0000 : 0x7C00_0000_0000_0000
        return Self(high: base, low: payload.value)
    }
}

// MARK: - Classification and Properties

extension Decimal.Format128 {
    public var classification: Decimal.Class {
        let combination = (high >> 58) & 0x1F

        if combination >= 0x18 {
            if combination == 0x1E {
                return .infinite
            }
            if combination >= 0x1F {
                let isSignaling = (high & 0x0200_0000_0000_0000) != 0
                return isSignaling ? .signaling : .quiet
            }
        }

        // Check if coefficient is zero
        if (high & 0x0001_FFFF_FFFF_FFFF) == 0 && low == 0 {
            return .zero
        }

        return .normal
    }

    public var sign: Decimal.Sign {
        (high & 0x8000_0000_0000_0000) != 0 ? .negative : .positive
    }

    public var negated: Self {
        Self(high: high ^ 0x8000_0000_0000_0000, low: low)
    }
}

// MARK: - Test Accessor

extension Decimal.Format128 {
    public var test: Decimal.Test<Self> {
        Decimal.Test(self)
    }
}

extension Decimal.Test where Value == Decimal.Format128 {
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
