extension Decimal {
    /// A 64-bit decimal floating-point value (IEEE 754-2008, BID encoding).
    ///
    /// - 16 decimal digits of precision.
    /// - Exponent range: -383 to +384.
    public struct Format64: Sendable, Hashable {
        /// The raw 64-bit BID encoding.
        public var bits: UInt64

        /// Creates a value from its raw 64-bit BID encoding.
        public init(bits: UInt64) {
            self.bits = bits
        }
    }
}

// MARK: - Layout Conformance

extension Decimal.Format64: Decimal.Layout {
    /// The number of significant decimal digits, which is 16.
    public static var precision: Decimal.Precision { .format64 }

    /// The maximum encodable exponent.
    public static var maxExponent: Decimal.Exponent { .Format64.max }

    /// The minimum encodable exponent.
    public static var minExponent: Decimal.Exponent { .Format64.min }

    /// The bias added to the exponent when encoding.
    public static var bias: Int { Decimal.Exponent.Format64.bias }
}

// MARK: - Canonical Factories

extension Decimal.Format64 {
    @usableFromInline
    internal static func canonical(zero sign: Decimal.Sign) -> Self {
        // BID encoding for zero: combination field indicates zero, coefficient is 0
        // Sign bit is bit 63, combination field bits 62-58
        // For zero with exponent 0 (biased = 398): 0x31C0_0000_0000_0000 (positive)
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        return Self(bits: signBit | 0x31C0_0000_0000_0000)
    }

    @usableFromInline
    internal static func canonical(infinity sign: Decimal.Sign) -> Self {
        // BID encoding for infinity: combination field = 11110
        // 0x7800_0000_0000_0000 (positive infinity)
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        return Self(bits: signBit | 0x7800_0000_0000_0000)
    }

    @usableFromInline
    internal static func canonical(nan kind: Decimal.NaN, payload: Decimal.Payload) -> Self {
        // BID encoding for NaN: combination field = 11111 (quiet) or 11110 + signaling bit
        // Quiet NaN: 0x7C00_0000_0000_0000
        // Signaling NaN: 0x7E00_0000_0000_0000
        let base: UInt64 = kind == .signaling ? 0x7E00_0000_0000_0000 : 0x7C00_0000_0000_0000
        let payloadMask: UInt64 = 0x0000_FFFF_FFFF_FFFF
        return Self(bits: base | (payload.value & payloadMask))
    }

    /// Returns the signed zero of this format.
    public static func zero(sign: Decimal.Sign = .positive) -> Self {
        canonical(zero: sign)
    }

    /// Returns the signed infinity of this format.
    public static func infinity(sign: Decimal.Sign = .positive) -> Self {
        canonical(infinity: sign)
    }

    /// Returns a NaN of this format with the given kind and diagnostic payload.
    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        canonical(nan: kind, payload: payload)
    }
}

// MARK: - Classification and Properties

extension Decimal.Format64 {
    /// The IEEE 754 class of this value.
    public var classification: Decimal.Class {
        // Extract combination field (bits 62-58)
        let combination = (bits >> 58) & 0x1F

        // Check for special values (combination field starts with 11)
        if combination >= 0x18 {
            // 11110 = infinity, 11111x = NaN
            if combination == 0x1E {
                return .infinite
            }
            if combination >= 0x1F {
                // Check signaling bit
                let isSignaling = (bits & 0x0200_0000_0000_0000) != 0
                return isSignaling ? .signaling : .quiet
            }
        }

        // For finite numbers, check if coefficient is zero
        let coefficient = extractCoefficient()
        if coefficient == 0 {
            return .zero
        }

        // Check for subnormal (exponent at minimum)
        let exponent = extractExponent()
        if exponent == Self.minExponent, coefficient < Self.coefficientMax() / 10 {
            return .subnormal
        }

        return .normal
    }

    /// The sign of this value.
    public var sign: Decimal.Sign {
        (bits & 0x8000_0000_0000_0000) != 0 ? .negative : .positive
    }

    /// This value with its sign bit flipped.
    public var negated: Self {
        Self(bits: bits ^ 0x8000_0000_0000_0000)
    }

    /// Returns the unbiased decimal exponent of this value.
    @inlinable
    public func extractExponent() -> Decimal.Exponent {
        // Check for special values (combination field starts with 11)
        let g0g1 = (bits >> 61) & 0x3
        if g0g1 == 0x3 {
            // Could be Form 2 or special value
            let g2 = (bits >> 60) & 0x1
            if g2 == 1 {
                // Infinity or NaN - exponent not meaningful
                return Decimal.Exponent(0)
            }
            // Form 2: exponent in bits 59-50
            let biasedExponent = Int((bits >> 50) & 0x3FF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        // Form 1: exponent in bits 62-53
        let biasedExponent = Int((bits >> 53) & 0x3FF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    /// Returns the integer coefficient (significand) of this value.
    @inlinable
    public func extractCoefficient() -> UInt64 {
        let g0g1 = (bits >> 61) & 0x3
        if g0g1 == 0x3 {
            // Could be Form 2 or special value
            let g2 = (bits >> 60) & 0x1
            if g2 == 1 {
                // Infinity or NaN - coefficient is payload
                return bits & 0x0003_FFFF_FFFF_FFFF
            }
            // Form 2: coefficient has implied 100 prefix
            // Lower 51 bits + implied 8 (100 binary) as high bits
            let lowBits = bits & 0x0007_FFFF_FFFF_FFFF  // 51 bits
            return (8 << 50) | lowBits
        }

        // Form 1: coefficient in lower 53 bits
        return bits & 0x001F_FFFF_FFFF_FFFF
    }

    /// Returns the largest coefficient this format can hold (10^16 - 1).
    @inlinable
    public static func coefficientMax() -> UInt64 {
        // 10^16 - 1 = 9999999999999999
        9_999_999_999_999_999
    }

    /// Encodes a finite value from its sign, exponent, and coefficient.
    ///
    /// - Precondition: `coefficient <= coefficientMax()`.
    @inlinable
    public static func encode(
        sign: Decimal.Sign,
        exponent: Decimal.Exponent,
        coefficient: UInt64
    ) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        let biasedExponent = UInt64(Int(exponent) + bias)

        guard coefficient < (1 << 53) else {
            // Form 2: coefficient needs implied prefix
            // bits 63: sign
            // bits 62-61: 11 (Form 2 marker)
            // bits 60-51: 10-bit biased exponent
            // bits 50-0: 51-bit coefficient (low bits)
            let form2Marker: UInt64 = 0x6000_0000_0000_0000  // 11 in bits 62-61
            let lowCoeff = coefficient & 0x0007_FFFF_FFFF_FFFF  // 51 bits
            return Self(bits: signBit | form2Marker | (biasedExponent << 51) | lowCoeff)
        }
        // Form 1: coefficient fits in 53 bits
        // bits 63: sign
        // bits 62-53: 10-bit biased exponent
        // bits 52-0: 53-bit coefficient
        return Self(bits: signBit | (biasedExponent << 53) | coefficient)
    }

    /// Normalizes a coefficient and exponent by removing trailing zeros where the exponent allows.
    @inlinable
    public static func normalize(
        coefficient: UInt64,
        exponent: Decimal.Exponent
    ) -> (coefficient: UInt64, exponent: Decimal.Exponent) {
        guard coefficient != 0 else {
            return (0, exponent)
        }

        var c = coefficient
        var e = exponent

        // Remove trailing zeros while we can increase exponent
        while c % 10 == 0, e < maxExponent {
            c /= 10
            e += 1
        }

        return (c, e)
    }

}
