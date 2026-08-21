extension Decimal {

    public struct Format32: Sendable, Hashable {

        public var bits: UInt32

        public init(bits: UInt32) {
            self.bits = bits
        }
    }
}

extension Decimal.Format32: Decimal.Layout {

    public static var precision: Decimal.Precision { .format32 }

    public static var maxExponent: Decimal.Exponent { .Format32.max }

    public static var minExponent: Decimal.Exponent { .Format32.min }

    public static var bias: Int { Decimal.Exponent.Format32.bias }
}

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

        return Decimal.Class.classifyFinite(
            coefficient: extractCoefficient(),
            exponent: extractExponent(),
            scientificMin: Decimal.Exponent.Format32.scientificMin
        )
    }

    public var sign: Decimal.Sign {
        (bits & 0x8000_0000) != 0 ? .negative : .positive
    }

    public var negated: Self {
        Self(bits: bits ^ 0x8000_0000)
    }

    @inlinable
    public func extractExponent() -> Decimal.Exponent {

        let g0g1 = (bits >> 29) & 0x3
        if g0g1 == 0x3 {

            let g2 = (bits >> 28) & 0x1
            let g3 = (bits >> 27) & 0x1
            if g2 == 1, g3 == 1 {

                return Decimal.Exponent(0)
            }

            let biasedExponent = Int((bits >> 21) & 0xFF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        let biasedExponent = Int((bits >> 23) & 0xFF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    @inlinable
    public func extractCoefficient() -> UInt32 {
        let g0g1 = (bits >> 29) & 0x3
        if g0g1 == 0x3 {

            let g2 = (bits >> 28) & 0x1
            let g3 = (bits >> 27) & 0x1
            if g2 == 1, g3 == 1 {

                return bits & 0x000F_FFFF
            }

            let lowBits = bits & 0x001F_FFFF
            return (8 << 20) | lowBits
        }

        return bits & 0x007F_FFFF
    }

    @inlinable
    public static func coefficientMax() -> UInt32 {

        9_999_999
    }

    @inlinable
    public static func encode(
        sign: Decimal.Sign,
        exponent: Decimal.Exponent,
        coefficient: UInt32
    ) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        let biasedExponent = UInt32(Int(exponent) + bias)

        guard coefficient < (1 << 23) else {

            let form2Marker: UInt32 = 0x6000_0000
            let lowCoeff = coefficient & 0x001F_FFFF
            return Self(bits: signBit | form2Marker | (biasedExponent << 21) | lowCoeff)
        }

        return Self(bits: signBit | (biasedExponent << 23) | coefficient)
    }

}
