extension Decimal {
    /// A 32-bit decimal floating-point value (IEEE 754-2008, BID encoding).
    ///
    /// - 7 decimal digits of precision.
    /// - Exponent range: -95 to +96.
    public struct Format32: Sendable, Hashable {
        /// The raw 32-bit BID encoding.
        public var bits: UInt32

        /// Creates a value from its raw 32-bit BID encoding.
        public init(bits: UInt32) {
            self.bits = bits
        }
    }
}

// MARK: - Layout Conformance

extension Decimal.Format32: Decimal.Layout {
    /// The number of significant decimal digits, which is 7.
    public static var precision: Decimal.Precision { .format32 }

    /// The maximum encodable exponent.
    public static var maxExponent: Decimal.Exponent { .Format32.max }

    /// The minimum encodable exponent.
    public static var minExponent: Decimal.Exponent { .Format32.min }

    /// The bias added to the exponent when encoding.
    public static var bias: Int { Decimal.Exponent.Format32.bias }
}

// MARK: - Canonical Factories

extension Decimal.Format32 {
    /// Returns the signed zero of this format.
    public static func zero(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        return Self(bits: signBit | 0x3200_0000)
    }

    /// Returns the signed infinity of this format.
    public static func infinity(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        return Self(bits: signBit | 0x7800_0000)
    }

    /// Returns a NaN of this format with the given kind and diagnostic payload.
    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        let base: UInt32 = kind == .signaling ? 0x7E00_0000 : 0x7C00_0000
        let payloadMask: UInt32 = 0x000F_FFFF
        return Self(bits: base | UInt32(truncatingIfNeeded: payload.value) & payloadMask)
    }
}

// MARK: - Classification and Properties

extension Decimal.Format32 {
    /// The IEEE 754 class of this value.
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

        let coefficient = extractCoefficient()
        if coefficient == 0 {
            return .zero
        }

        let exponent = extractExponent()
        if exponent == Self.minExponent, coefficient < Self.coefficientMax() / 10 {
            return .subnormal
        }

        return .normal
    }

    /// The sign of this value.
    public var sign: Decimal.Sign {
        (bits & 0x8000_0000) != 0 ? .negative : .positive
    }

    /// This value with its sign bit flipped.
    public var negated: Self {
        Self(bits: bits ^ 0x8000_0000)
    }

    /// Returns the unbiased decimal exponent of this value.
    @inlinable
    public func extractExponent() -> Decimal.Exponent {
        // Check for special values (combination field starts with 11)
        let g0g1 = (bits >> 29) & 0x3
        if g0g1 == 0x3 {
            // Could be Form 2 or special value
            let g2 = (bits >> 28) & 0x1
            if g2 == 1 {
                // Infinity or NaN - exponent not meaningful
                return Decimal.Exponent(0)
            }
            // Form 2: exponent in bits 27-20
            let biasedExponent = Int((bits >> 20) & 0xFF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        // Form 1: exponent in bits 30-23
        let biasedExponent = Int((bits >> 23) & 0xFF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    /// Returns the integer coefficient (significand) of this value.
    @inlinable
    public func extractCoefficient() -> UInt32 {
        let g0g1 = (bits >> 29) & 0x3
        if g0g1 == 0x3 {
            // Could be Form 2 or special value
            let g2 = (bits >> 28) & 0x1
            if g2 == 1 {
                // Infinity or NaN - coefficient is payload
                return bits & 0x000F_FFFF
            }
            // Form 2: coefficient has implied 100 prefix
            // Lower 21 bits + implied 8 (100 binary) as high bits
            let lowBits = bits & 0x001F_FFFF  // 21 bits
            return (8 << 20) | lowBits
        }

        // Form 1: coefficient in lower 23 bits
        return bits & 0x007F_FFFF
    }

    /// Returns the largest coefficient this format can hold (10^7 - 1).
    @inlinable
    public static func coefficientMax() -> UInt32 {
        // 10^7 - 1 = 9999999
        9_999_999
    }

    /// Encodes a finite value from its sign, exponent, and coefficient.
    ///
    /// - Precondition: `coefficient <= coefficientMax()`.
    @inlinable
    public static func encode(
        sign: Decimal.Sign,
        exponent: Decimal.Exponent,
        coefficient: UInt32
    ) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        let biasedExponent = UInt32(Int(exponent) + bias)

        guard coefficient < (1 << 23) else {
            // Form 2: coefficient needs implied prefix
            // bits 31: sign
            // bits 30-29: 11 (Form 2 marker)
            // bits 28-21: 8-bit biased exponent
            // bits 20-0: 21-bit coefficient (low bits)
            let form2Marker: UInt32 = 0x6000_0000  // 11 in bits 30-29
            let lowCoeff = coefficient & 0x001F_FFFF  // 21 bits
            return Self(bits: signBit | form2Marker | (biasedExponent << 21) | lowCoeff)
        }
        // Form 1: coefficient fits in 23 bits
        // bits 31: sign
        // bits 30-23: 8-bit biased exponent
        // bits 22-0: 23-bit coefficient
        return Self(bits: signBit | (biasedExponent << 23) | coefficient)
    }

}
