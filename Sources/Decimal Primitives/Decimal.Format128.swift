extension Decimal {
    /// A 128-bit decimal floating-point value (IEEE 754-2008, BID encoding).
    ///
    /// - 34 decimal digits of precision.
    /// - Exponent range: -6143 to +6144.
    public struct Format128: Sendable, Hashable {
        /// The high 64 bits of the raw 128-bit BID encoding.
        public var high: UInt64

        /// The low 64 bits of the raw 128-bit BID encoding.
        public var low: UInt64

        /// Creates a value from the high and low halves of its raw 128-bit BID encoding.
        public init(high: UInt64, low: UInt64) {
            self.high = high
            self.low = low
        }
    }
}

// MARK: - Layout Conformance

extension Decimal.Format128: Decimal.Layout {
    /// The number of significant decimal digits, which is 34.
    public static var precision: Decimal.Precision { .format128 }

    /// The maximum encodable exponent.
    public static var maxExponent: Decimal.Exponent { .Format128.max }

    /// The minimum encodable exponent.
    public static var minExponent: Decimal.Exponent { .Format128.min }

    /// The bias added to the exponent when encoding.
    public static var bias: Int { Decimal.Exponent.Format128.bias }
}

// MARK: - Canonical Factories

extension Decimal.Format128 {
    /// Returns the signed zero of this format.
    public static func zero(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        return Self(high: signBit | 0x3040_0000_0000_0000, low: 0)
    }

    /// Returns the signed infinity of this format.
    public static func infinity(sign: Decimal.Sign = .positive) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        return Self(high: signBit | 0x7800_0000_0000_0000, low: 0)
    }

    /// Returns a NaN of this format with the given kind and diagnostic payload.
    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        let base: UInt64 = kind == .signaling ? 0x7E00_0000_0000_0000 : 0x7C00_0000_0000_0000
        return Self(high: base, low: payload.value)
    }
}

// MARK: - Classification and Properties

extension Decimal.Format128 {
    /// The IEEE 754 class of this value.
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

    /// The sign of this value.
    public var sign: Decimal.Sign {
        (high & 0x8000_0000_0000_0000) != 0 ? .negative : .positive
    }

    /// This value with its sign bit flipped.
    public var negated: Self {
        Self(high: high ^ 0x8000_0000_0000_0000, low: low)
    }

    /// Returns the unbiased decimal exponent of this value.
    @inlinable
    public func extractExponent() -> Decimal.Exponent {
        // Check for special values (combination field starts with 11)
        let g0g1 = (high >> 61) & 0x3
        if g0g1 == 0x3 {
            let g2 = (high >> 60) & 0x1
            if g2 == 1 {
                // Infinity or NaN
                return Decimal.Exponent(0)
            }
            // Form 2: exponent in bits 59-46 of high
            let biasedExponent = Int((high >> 46) & 0x3FFF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        // Form 1: exponent in bits 62-49 of high
        let biasedExponent = Int((high >> 49) & 0x3FFF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    /// Returns the integer coefficient (significand) of this value.
    @inlinable
    public func extractCoefficient() -> UInt128 {
        let g0g1 = (high >> 61) & 0x3
        if g0g1 == 0x3 {
            let g2 = (high >> 60) & 0x1
            if g2 == 1 {
                // Infinity or NaN - coefficient is payload
                let highPart = high & 0x0000_FFFF_FFFF_FFFF
                return (UInt128(highPart) << 64) | UInt128(low)
            }
            // Form 2: coefficient has implied 100 prefix
            // Lower 46 bits of high + all of low
            let highPart = (high & 0x0000_3FFF_FFFF_FFFF) | (UInt64(8) << 46)
            return (UInt128(highPart) << 64) | UInt128(low)
        }

        // Form 1: coefficient in lower 49 bits of high + all of low
        let highPart = high & 0x0001_FFFF_FFFF_FFFF
        return (UInt128(highPart) << 64) | UInt128(low)
    }

    /// Returns the largest coefficient this format can hold (10^34 - 1).
    @inlinable
    public static func coefficientMax() -> UInt128 {
        // 10^34 - 1
        (UInt128(0x0001_ED09_BEAD_87C0) << 64) | UInt128(0x378D_8E63_FFFF_FFFF)
    }

    /// Encodes a finite value from its sign, exponent, and coefficient.
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

        // Check if we need Form 2 (coefficient high bit >= 2^49)
        guard coeffHigh < (1 << 49) else {
            // Form 2: bits 62-61 = 11, exponent in bits 59-46
            let form2Marker: UInt64 = 0x6000_0000_0000_0000
            let coeffHighMasked = coeffHigh & 0x0000_3FFF_FFFF_FFFF  // 46 bits
            let highPart = signBit | form2Marker | (biasedExponent << 46) | coeffHighMasked
            return Self(high: highPart, low: coeffLow)
        }
        // Form 1: exponent in bits 62-49, coefficient in bits 48-0 of high + all of low
        let highPart = signBit | (biasedExponent << 49) | coeffHigh
        return Self(high: highPart, low: coeffLow)
    }

}
