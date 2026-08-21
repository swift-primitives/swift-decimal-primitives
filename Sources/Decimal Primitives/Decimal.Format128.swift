extension Decimal {

    public struct Format128: Sendable, Hashable {

        public var high: UInt64

        public var low: UInt64

        public init(high: UInt64, low: UInt64) {
            self.high = high
            self.low = low
        }
    }
}

extension Decimal.Format128: Decimal.Layout {

    public static var precision: Decimal.Precision { .format128 }

    public static var maxExponent: Decimal.Exponent { .Format128.max }

    public static var minExponent: Decimal.Exponent { .Format128.min }

    public static var bias: Int { Decimal.Exponent.Format128.bias }
}

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

        return Decimal.Class.classifyFinite(
            coefficient: extractCoefficient(),
            exponent: extractExponent(),
            scientificMin: Decimal.Exponent.Format128.scientificMin
        )
    }

    public var sign: Decimal.Sign {
        (high & 0x8000_0000_0000_0000) != 0 ? .negative : .positive
    }

    public var negated: Self {
        Self(high: high ^ 0x8000_0000_0000_0000, low: low)
    }

    @inlinable
    public func extractExponent() -> Decimal.Exponent {

        let g0g1 = (high >> 61) & 0x3
        if g0g1 == 0x3 {
            let g2 = (high >> 60) & 0x1
            let g3 = (high >> 59) & 0x1
            if g2 == 1, g3 == 1 {

                return Decimal.Exponent(0)
            }

            let biasedExponent = Int((high >> 46) & 0x3FFF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        let biasedExponent = Int((high >> 49) & 0x3FFF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    @inlinable
    public func extractCoefficient() -> UInt128 {
        let g0g1 = (high >> 61) & 0x3
        if g0g1 == 0x3 {
            let g2 = (high >> 60) & 0x1
            let g3 = (high >> 59) & 0x1
            if g2 == 1, g3 == 1 {

                let highPart = high & 0x0000_FFFF_FFFF_FFFF
                return (UInt128(highPart) << 64) | UInt128(low)
            }

            let highPart = (high & 0x0000_3FFF_FFFF_FFFF) | (UInt64(8) << 46)
            return (UInt128(highPart) << 64) | UInt128(low)
        }

        let highPart = high & 0x0001_FFFF_FFFF_FFFF
        return (UInt128(highPart) << 64) | UInt128(low)
    }

    @inlinable
    public static func coefficientMax() -> UInt128 {

        (UInt128(0x0001_ED09_BEAD_87C0) << 64) | UInt128(0x378D_8E63_FFFF_FFFF)
    }

    @inlinable
    public static func encode(
        sign: Decimal.Sign,
        exponent: Decimal.Exponent,
        coefficient: UInt128
    ) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        let biasedExponent = UInt64(Int(exponent) + bias)

        let coeffHigh = UInt64(coefficient >> 64)
        let coeffLow = UInt64(truncatingIfNeeded: coefficient)

        guard coeffHigh < (1 << 49) else {

            let form2Marker: UInt64 = 0x6000_0000_0000_0000
            let coeffHighMasked = coeffHigh & 0x0000_3FFF_FFFF_FFFF
            let highPart = signBit | form2Marker | (biasedExponent << 46) | coeffHighMasked
            return Self(high: highPart, low: coeffLow)
        }

        let highPart = signBit | (biasedExponent << 49) | coeffHigh
        return Self(high: highPart, low: coeffLow)
    }

}
