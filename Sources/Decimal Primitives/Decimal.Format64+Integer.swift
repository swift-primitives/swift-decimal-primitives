// MARK: - Decimal.Format64 ← Integer

extension Decimal.Format64 {
    /// Initialize from Int64 (always exact within precision)
    public init(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive
        let magnitude = value < 0 ? UInt64(bitPattern: -value) : UInt64(value)

        self = Self.encode(sign: sign, exponent: 0, coefficient: magnitude)
    }

    /// Initialize from UInt64 (always exact within precision)
    public init(_ value: UInt64) {
        if value == 0 {
            self = .zero()
            return
        }

        // Check if value fits in 16 decimal digits
        if value > 9_999_999_999_999_999 {
            // Value too large - would need to adjust exponent
            fatalError("Value too large for exact representation")
        }

        self = Self.encode(sign: .positive, exponent: 0, coefficient: value)
    }
}

// MARK: - Integer ← Decimal.Format64

extension Int64 {
    /// Initialize from Decimal.Format64 if exactly representable
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
                if integerPart > UInt64(Int64.max) + 1 {
                    return nil
                }
                self = -Int64(integerPart)
            } else {
                if integerPart > UInt64(Int64.max) {
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
                if result > UInt64(Int64.max) + 1 {
                    return nil
                }
                self = -Int64(result)
            } else {
                if result > UInt64(Int64.max) {
                    return nil
                }
                self = Int64(result)
            }
        } else {
            // Int(exponent) == 0
            if value.test.negative {
                if coefficient > UInt64(Int64.max) + 1 {
                    return nil
                }
                self = -Int64(coefficient)
            } else {
                if coefficient > UInt64(Int64.max) {
                    return nil
                }
                self = Int64(coefficient)
            }
        }
    }
}

extension UInt64 {
    /// Initialize from Decimal.Format64 if exactly representable
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
