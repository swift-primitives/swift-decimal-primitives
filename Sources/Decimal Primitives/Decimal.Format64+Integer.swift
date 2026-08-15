// MARK: - Decimal.Format64 ← Integer

extension Decimal.Format64 {
    /// Initialize from a signed 64-bit integer, if exactly representable.
    ///
    /// Returns `nil` when the value has more significant digits than
    /// this format's precision (16 decimal digits) even after removing
    /// trailing zeros (e.g. magnitudes above `10^16 - 1` that are not a
    /// multiple of a power of ten small enough to bring them into range).
    public init?(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive
        // `.magnitude` is exact for every `Int64`, including `Int64.min`
        // (never traps, unlike negating the bit pattern of `-Int64.min`).
        var coefficient = value.magnitude
        var exponent = 0

        while coefficient > Self.coefficientMax() {
            guard coefficient % 10 == 0 else { return nil }
            coefficient /= 10
            exponent += 1
        }

        self = Self.encode(
            sign: sign,
            exponent: Decimal.Exponent(exponent),
            coefficient: coefficient
        )
    }

    /// Initialize from an unsigned 64-bit integer, if exactly representable.
    ///
    /// Returns `nil` when the value has more significant digits than
    /// this format's precision (16 decimal digits) even after removing
    /// trailing zeros.
    public init?(_ value: UInt64) {
        if value == 0 {
            self = .zero()
            return
        }

        var coefficient = value
        var exponent = 0

        while coefficient > Self.coefficientMax() {
            guard coefficient % 10 == 0 else { return nil }
            coefficient /= 10
            exponent += 1
        }

        self = Self.encode(
            sign: .positive,
            exponent: Decimal.Exponent(exponent),
            coefficient: coefficient
        )
    }
}

// MARK: - Integer ← Decimal.Format64

extension Int64 {
    /// Initialize from a 64-bit decimal value, if exactly representable.
    public init?(exactly value: Decimal.Format64) {
        // Check for special values
        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        // If exponent is positive, we need to multiply
        // If exponent is negative, we need to check for fractional part
        if Int(exponent) < 0 {
            // Check if there would be a fractional part
            var divisor: UInt64 = 1
            for _ in 0..<(-Int(exponent)) {
                divisor *= 10
                if divisor > coefficient {
                    // Would have fractional part
                    return nil
                }
            }
            if coefficient % divisor != 0 {
                return nil
            }
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > UInt64(Self.max) + 1 {
                    return nil
                }
                // Negate via the bit pattern: `integerPart` may equal
                // `UInt64(Self.max) + 1` (`Int64.min`'s magnitude), which
                // `-Int64(integerPart)` would trap on constructing.
                self = Int64(bitPattern: 0 &- integerPart)
            } else {
                if integerPart > UInt64(Self.max) {
                    return nil
                }
                self = Int64(integerPart)
            }
        } else if Int(exponent) > 0 {
            // Multiply by 10^exponent
            var result = coefficient
            for _ in 0..<Int(exponent) {
                let (newResult, overflow) = result.multipliedReportingOverflow(by: 10)
                if overflow {
                    return nil
                }
                result = newResult
            }
            if value.test.negative {
                if result > UInt64(Self.max) + 1 {
                    return nil
                }
                // See the exponent < 0 branch above: avoid trapping when
                // `result` is exactly `Int64.min`'s magnitude.
                self = Int64(bitPattern: 0 &- result)
            } else {
                if result > UInt64(Self.max) {
                    return nil
                }
                self = Int64(result)
            }
        } else {
            // Int(exponent) == 0
            if value.test.negative {
                if coefficient > UInt64(Self.max) + 1 {
                    return nil
                }
                // See the exponent < 0 branch above: avoid trapping when
                // `coefficient` is exactly `Int64.min`'s magnitude.
                self = Int64(bitPattern: 0 &- coefficient)
            } else {
                if coefficient > UInt64(Self.max) {
                    return nil
                }
                self = Int64(coefficient)
            }
        }
    }
}

extension UInt64 {
    /// Initialize from a 64-bit decimal value, if exactly representable.
    public init?(exactly value: Decimal.Format64) {
        // Check for special values
        if value.test.nan || value.test.infinite {
            return nil
        }

        // Negative values cannot be represented as UInt64
        if value.test.negative && !value.test.zero {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        if Int(exponent) < 0 {
            // Check if there would be a fractional part
            var divisor: UInt64 = 1
            for _ in 0..<(-Int(exponent)) {
                divisor *= 10
                if divisor > coefficient {
                    return nil
                }
            }
            if coefficient % divisor != 0 {
                return nil
            }
            self = coefficient / divisor
        } else if Int(exponent) > 0 {
            // Multiply by 10^exponent
            var result = coefficient
            for _ in 0..<Int(exponent) {
                let (newResult, overflow) = result.multipliedReportingOverflow(by: 10)
                if overflow {
                    return nil
                }
                result = newResult
            }
            self = result
        } else {
            self = coefficient
        }
    }
}
