// MARK: - Decimal.Format32 ← Integer

extension Decimal.Format32 {
    /// Initialize from Int32 (always exact within precision)
    public init(_ value: Int32) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive
        let magnitude = value < 0 ? UInt32(bitPattern: -value) : UInt32(value)

        self = Self.encode(sign: sign, exponent: 0, coefficient: magnitude)
    }

    /// Initialize from UInt32 (always exact within precision)
    public init(_ value: UInt32) {
        if value == 0 {
            self = .zero()
            return
        }

        // Check if value fits in 7 decimal digits
        if value > 9_999_999 {
            // Value too large - would need to adjust exponent
            fatalError("Value too large for exact representation")
        }

        self = Self.encode(sign: .positive, exponent: 0, coefficient: value)
    }
}

// MARK: - Integer ← Decimal.Format32

extension Int32 {
    /// Initialize from Decimal.Format32 if exactly representable
    public init?(exactly value: Decimal.Format32) {
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

        if exponent.rawValue < 0 {
            // Check if there would be a fractional part
            var divisor: UInt32 = 1
            for _ in 0..<(-exponent.rawValue) {
                let (newDivisor, overflow) = divisor.multipliedReportingOverflow(by: 10)
                if overflow || newDivisor > coefficient {
                    return nil
                }
                divisor = newDivisor
            }
            if coefficient % divisor != 0 {
                return nil
            }
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > UInt32(Int32.max) + 1 {
                    return nil
                }
                self = -Int32(integerPart)
            } else {
                if integerPart > UInt32(Int32.max) {
                    return nil
                }
                self = Int32(integerPart)
            }
        } else if exponent.rawValue > 0 {
            // Multiply by 10^exponent
            var result = coefficient
            for _ in 0..<exponent.rawValue {
                let (newResult, overflow) = result.multipliedReportingOverflow(by: 10)
                if overflow {
                    return nil
                }
                result = newResult
            }
            if value.test.negative {
                if result > UInt32(Int32.max) + 1 {
                    return nil
                }
                self = -Int32(result)
            } else {
                if result > UInt32(Int32.max) {
                    return nil
                }
                self = Int32(result)
            }
        } else {
            // exponent.rawValue == 0
            if value.test.negative {
                if coefficient > UInt32(Int32.max) + 1 {
                    return nil
                }
                self = -Int32(coefficient)
            } else {
                if coefficient > UInt32(Int32.max) {
                    return nil
                }
                self = Int32(coefficient)
            }
        }
    }
}

extension UInt32 {
    /// Initialize from Decimal.Format32 if exactly representable
    public init?(exactly value: Decimal.Format32) {
        // Check for special values
        if value.test.nan || value.test.infinite {
            return nil
        }

        // Negative values cannot be represented as UInt32
        if value.test.negative && !value.test.zero {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        if exponent.rawValue < 0 {
            var divisor: UInt32 = 1
            for _ in 0..<(-exponent.rawValue) {
                let (newDivisor, overflow) = divisor.multipliedReportingOverflow(by: 10)
                if overflow || newDivisor > coefficient {
                    return nil
                }
                divisor = newDivisor
            }
            if coefficient % divisor != 0 {
                return nil
            }
            self = coefficient / divisor
        } else if exponent.rawValue > 0 {
            var result = coefficient
            for _ in 0..<exponent.rawValue {
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
