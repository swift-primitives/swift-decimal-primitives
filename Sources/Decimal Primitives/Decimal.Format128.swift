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

    @usableFromInline
    internal func extractExponent() -> Decimal.Exponent {
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

    @usableFromInline
    internal func extractCoefficient() -> UInt128 {
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

    @usableFromInline
    internal static func coefficientMax() -> UInt128 {
        // 10^34 - 1
        (UInt128(0x0001_ED09_BEAD_87C0) << 64) | UInt128(0x378D_8E63_FFFF_FFFF)
    }

    /// Encode a finite value from sign, exponent, and coefficient
    @usableFromInline
    internal static func encode(
        sign: Decimal.Sign,
        exponent: Decimal.Exponent,
        coefficient: UInt128
    ) -> Self {
        let signBit: UInt64 = sign == .negative ? 0x8000_0000_0000_0000 : 0
        let biasedExponent = UInt64(exponent.rawValue + bias)

        let coeffHigh = UInt64(coefficient >> 64)
        let coeffLow = UInt64(truncatingIfNeeded: coefficient)

        // Check if we need Form 2 (coefficient high bit >= 2^49)
        if coeffHigh < (1 << 49) {
            // Form 1: exponent in bits 62-49, coefficient in bits 48-0 of high + all of low
            let highPart = signBit | (biasedExponent << 49) | coeffHigh
            return Self(high: highPart, low: coeffLow)
        } else {
            // Form 2: bits 62-61 = 11, exponent in bits 59-46
            let form2Marker: UInt64 = 0x6000_0000_0000_0000
            let coeffHighMasked = coeffHigh & 0x0000_3FFF_FFFF_FFFF  // 46 bits
            let highPart = signBit | form2Marker | (biasedExponent << 46) | coeffHighMasked
            return Self(high: highPart, low: coeffLow)
        }
    }

    /// Round coefficient to fit in precision digits
    @usableFromInline
    internal static func round(
        coefficient: UInt128,
        exponent: Decimal.Exponent,
        sign: Decimal.Sign,
        rounding: Decimal.Rounding,
        precision: Decimal.Precision
    ) -> (coefficient: UInt128, exponent: Decimal.Exponent, status: Decimal.Status) {
        let c = coefficient
        var e = exponent
        var status: Decimal.Status = .none

        // Calculate number of digits
        var digits = 0
        var temp = c
        while temp > 0 {
            digits += 1
            temp /= 10
        }

        // If coefficient fits in precision, no rounding needed
        if digits <= precision.rawValue {
            return (c, e, status)
        }

        // Need to round off (digits - precision) digits
        let roundDigits = digits - precision.rawValue

        // Calculate divisor
        var divisor: UInt128 = 1
        for _ in 0..<roundDigits {
            divisor *= 10
        }

        let quotient = c / divisor
        let remainder = c % divisor
        let halfDivisor = divisor / 2

        // Determine if we need to round up
        var roundUp = false
        switch rounding {
        case .ceiling:
            roundUp = remainder > 0 && sign == .positive
        case .floor:
            roundUp = remainder > 0 && sign == .negative
        case .down:
            roundUp = false
        case .up:
            roundUp = remainder > 0
        case .even:
            if remainder > halfDivisor {
                roundUp = true
            } else if remainder == halfDivisor {
                roundUp = (quotient % 2) != 0
            }
        case .away:
            roundUp = remainder >= halfDivisor
        case .toward:
            roundUp = remainder > halfDivisor
        }

        var result = quotient
        if roundUp {
            result += 1
        }

        if remainder > 0 {
            status = .inexact
        }

        e = e + roundDigits

        // Check if rounding caused overflow of coefficient
        if result > coefficientMax() {
            result /= 10
            e = e + 1
        }

        return (result, e, status)
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
