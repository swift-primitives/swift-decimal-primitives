extension Decimal.Format64 {

    public init?(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive

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

extension Int64 {

    public init?(exactly value: Decimal.Format64) {

        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        if Int(exponent) < 0 {

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
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > UInt64(Self.max) + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- integerPart)
            } else {
                if integerPart > UInt64(Self.max) {
                    return nil
                }
                self = Int64(integerPart)
            }
        } else if Int(exponent) > 0 {

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

                self = Int64(bitPattern: 0 &- result)
            } else {
                if result > UInt64(Self.max) {
                    return nil
                }
                self = Int64(result)
            }
        } else {

            if value.test.negative {
                if coefficient > UInt64(Self.max) + 1 {
                    return nil
                }

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

    public init?(exactly value: Decimal.Format64) {

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

        if Int(exponent) < 0 {

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
