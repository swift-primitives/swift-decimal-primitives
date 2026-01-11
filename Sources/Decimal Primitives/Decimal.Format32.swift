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

    @usableFromInline
    internal func extractExponent() -> Decimal.Exponent {
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

    @usableFromInline
    internal func extractCoefficient() -> UInt32 {
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

    @usableFromInline
    internal static func coefficientMax() -> UInt32 {
        // 10^7 - 1 = 9999999
        9_999_999
    }

    /// Encode a finite value from sign, exponent, and coefficient
    /// - Precondition: coefficient <= coefficientMax()
    @usableFromInline
    internal static func encode(
        sign: Decimal.Sign,
        exponent: Decimal.Exponent,
        coefficient: UInt32
    ) -> Self {
        let signBit: UInt32 = sign == .negative ? 0x8000_0000 : 0
        let biasedExponent = UInt32(exponent.rawValue + bias)

        if coefficient < (1 << 23) {
            // Form 1: coefficient fits in 23 bits
            // bits 31: sign
            // bits 30-23: 8-bit biased exponent
            // bits 22-0: 23-bit coefficient
            return Self(bits: signBit | (biasedExponent << 23) | coefficient)
        } else {
            // Form 2: coefficient needs implied prefix
            // bits 31: sign
            // bits 30-29: 11 (Form 2 marker)
            // bits 28-21: 8-bit biased exponent
            // bits 20-0: 21-bit coefficient (low bits)
            let form2Marker: UInt32 = 0x6000_0000  // 11 in bits 30-29
            let lowCoeff = coefficient & 0x001F_FFFF  // 21 bits
            return Self(bits: signBit | form2Marker | (biasedExponent << 21) | lowCoeff)
        }
    }

    /// Round coefficient to fit in precision digits
    @usableFromInline
    internal static func round(
        coefficient: UInt64,
        exponent: Decimal.Exponent,
        sign: Decimal.Sign,
        rounding: Decimal.Rounding,
        precision: Decimal.Precision
    ) -> (coefficient: UInt32, exponent: Decimal.Exponent, status: Decimal.Status) {
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
            return (UInt32(truncatingIfNeeded: c), e, status)
        }

        // Need to round off (digits - precision) digits
        let roundDigits = digits - precision.rawValue

        // Calculate divisor
        var divisor: UInt64 = 1
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
        if result > UInt64(coefficientMax()) {
            result /= 10
            e = e + 1
        }

        return (UInt32(truncatingIfNeeded: result), e, status)
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
