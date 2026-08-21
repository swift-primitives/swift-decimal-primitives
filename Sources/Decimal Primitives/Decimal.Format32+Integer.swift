extension Decimal.Format32 {

    public init?(_ value: Int32) {
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

    public init?(_ value: UInt32) {
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

extension Int32 {

    public init?(exactly value: Decimal.Format32) {

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

            var divisor: UInt32 = 1
            for _ in 0..<(-Int(exponent)) {
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
                if integerPart > UInt32(Self.max) + 1 {
                    return nil
                }
                self = -Int32(integerPart)
            } else {
                if integerPart > UInt32(Self.max) {
                    return nil
                }
                self = Int32(integerPart)
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
                if result > UInt32(Self.max) + 1 {
                    return nil
                }
                self = -Int32(result)
            } else {
                if result > UInt32(Self.max) {
                    return nil
                }
                self = Int32(result)
            }
        } else {

            if value.test.negative {
                if coefficient > UInt32(Self.max) + 1 {
                    return nil
                }
                self = -Int32(coefficient)
            } else {
                if coefficient > UInt32(Self.max) {
                    return nil
                }
                self = Int32(coefficient)
            }
        }
    }
}

extension UInt32 {

    public init?(exactly value: Decimal.Format32) {

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
            var divisor: UInt32 = 1
            for _ in 0..<(-Int(exponent)) {
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
