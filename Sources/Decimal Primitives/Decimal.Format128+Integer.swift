extension Decimal.Format128 {

    public init(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive

        self = Self.encode(sign: sign, exponent: 0, coefficient: UInt128(value.magnitude))
    }

    public init(_ value: UInt64) {
        if value == 0 {
            self = .zero()
            return
        }

        self = Self.encode(sign: .positive, exponent: 0, coefficient: UInt128(value))
    }
}

extension Int64 {

    public init?(exactly value: Decimal.Format128) {

        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        let maxInt64AsUInt128 = UInt128(UInt64(Self.max))

        if Int(exponent) < 0 {

            var divisor: UInt128 = 1
            for _ in 0..<(-Int(exponent)) {
                divisor *= 10
                if divisor > coefficient {
                    return nil
                }
            }
            if coefficient % divisor != 0 {
                return nil
            }
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > maxInt64AsUInt128 + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- UInt64(truncatingIfNeeded: integerPart))
            } else {
                if integerPart > maxInt64AsUInt128 {
                    return nil
                }
                self = Int64(UInt64(truncatingIfNeeded: integerPart))
            }
        } else if Int(exponent) > 0 {

            var result = coefficient
            for _ in 0..<Int(exponent) {
                let newResult = result * 10

                if newResult > maxInt64AsUInt128 + 1 {
                    return nil
                }
                result = newResult
            }
            if value.test.negative {
                if result > maxInt64AsUInt128 + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- UInt64(truncatingIfNeeded: result))
            } else {
                if result > maxInt64AsUInt128 {
                    return nil
                }
                self = Int64(UInt64(truncatingIfNeeded: result))
            }
        } else {

            if value.test.negative {
                if coefficient > maxInt64AsUInt128 + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- UInt64(truncatingIfNeeded: coefficient))
            } else {
                if coefficient > maxInt64AsUInt128 {
                    return nil
                }
                self = Int64(UInt64(truncatingIfNeeded: coefficient))
            }
        }
    }
}

extension UInt64 {

    public init?(exactly value: Decimal.Format128) {

        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.negative && !value.test.zero {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()
        let maxUInt64AsUInt128 = UInt128(Self.max)

        if Int(exponent) < 0 {
            var divisor: UInt128 = 1
            for _ in 0..<(-Int(exponent)) {
                divisor *= 10
                if divisor > coefficient {
                    return nil
                }
            }
            if coefficient % divisor != 0 {
                return nil
            }
            let result = coefficient / divisor
            if result > maxUInt64AsUInt128 {
                return nil
            }
            self = UInt64(truncatingIfNeeded: result)
        } else if Int(exponent) > 0 {
            var result = coefficient
            for _ in 0..<Int(exponent) {
                result *= 10
                if result > maxUInt64AsUInt128 {
                    return nil
                }
            }
            self = UInt64(truncatingIfNeeded: result)
        } else {
            if coefficient > maxUInt64AsUInt128 {
                return nil
            }
            self = UInt64(truncatingIfNeeded: coefficient)
        }
    }
}
