extension Decimal {
    /// 32-bit decimal floating-point (IEEE 754-2008, BID encoding)
    /// - 7 decimal digits of precision
    /// - Exponent range: -95 to +96
    public struct Format32: Sendable, Hashable {
        @usableFromInline
        internal var bits: UInt32

        public init(bits: UInt32) {
            self.bits = bits
        }
    }
}

// MARK: - Layout Conformance

extension Decimal.Format32: Decimal.Layout {
    @usableFromInline
    internal static var precision: Decimal.Precision { .format32 }

    @usableFromInline
    internal static var maxExponent: Decimal.Exponent { .Format32.max }

    @usableFromInline
    internal static var minExponent: Decimal.Exponent { .Format32.min }

    @usableFromInline
    internal static var bias: Int { Decimal.Exponent.Format32.bias }
}

// MARK: - Canonical Factories

extension Decimal.Format32 {
    public static func zero(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        return Self(bits: signBit | 0x3200_0000)
    }

    public static func infinity(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        return Self(bits: signBit | 0x7800_0000)
    }

    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        let base: UInt32 = kind == .signaling ? 0x7E00_0000 : 0x7C00_0000
        let payloadMask: UInt32 = 0x000F_FFFF
        return Self(bits: base | UInt32(truncatingIfNeeded: payload.value) & payloadMask)
    }
}

// MARK: - Classification and Properties

extension Decimal.Format32 {
    public var classification: Decimal.Class {
        let combination = (bits >> 26) & 0x1F

        if combination >= 0x18 {
            if combination == 0x1E {
                return .infinite
            }
            if combination >= 0x1F {
                let isSignaling = (bits & 0x0200_0000) != 0
                return isSignaling ? .signaling : .quiet
            }
        }

        let coefficient = bits & 0x001F_FFFF
        if coefficient == 0 {
            return .zero
        }

        return .normal
    }

    public var sign: Decimal.Sign {
        (bits & 0x8000_0000) != 0 ? .negative : .positive
    }

    public var negated: Self {
        Self(bits: bits ^ 0x8000_0000)
    }
}

// MARK: - Test Accessor

extension Decimal.Format32 {
    public var test: Decimal.Test<Self> {
        Decimal.Test(self)
    }
}

extension Decimal.Test where Value == Decimal.Format32 {
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
