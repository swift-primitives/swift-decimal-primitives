extension Decimal.Operation where Value == Decimal.Format32 {
    /// Numerical comparison (NaN is unordered)
    public func compare(_ other: Value) -> Decimal.Compare {
        // Handle NaN cases first
        if base.test.nan || other.test.nan {
            return .unordered
        }

        // Handle infinities
        let baseInf = base.test.infinite
        let otherInf = other.test.infinite

        if baseInf && otherInf {
            let baseNeg = base.test.negative
            let otherNeg = other.test.negative
            if baseNeg == otherNeg {
                return .equal
            }
            return baseNeg ? .less : .greater
        }

        if baseInf {
            return base.test.negative ? .less : .greater
        }

        if otherInf {
            return other.test.negative ? .greater : .less
        }

        // Handle zeros
        if base.test.zero && other.test.zero {
            return .equal
        }

        // TODO: Implement proper magnitude comparison
        fatalError("Implementation required")
    }
}

extension Decimal.Operation where Value == Decimal.Format64 {
    /// Numerical comparison (NaN is unordered)
    public func compare(_ other: Value) -> Decimal.Compare {
        // Handle NaN cases first
        if base.test.nan || other.test.nan {
            return .unordered
        }

        // Handle infinities
        let baseInf = base.test.infinite
        let otherInf = other.test.infinite

        if baseInf && otherInf {
            // Both infinite
            let baseNeg = base.test.negative
            let otherNeg = other.test.negative
            if baseNeg == otherNeg {
                return .equal
            }
            return baseNeg ? .less : .greater
        }

        if baseInf {
            return base.test.negative ? .less : .greater
        }

        if otherInf {
            return other.test.negative ? .greater : .less
        }

        // Handle zeros
        if base.test.zero && other.test.zero {
            return .equal
        }

        // Compare finite values
        let baseNeg = base.test.negative
        let otherNeg = other.test.negative

        if baseNeg != otherNeg {
            return baseNeg ? .less : .greater
        }

        // Same sign - compare magnitudes
        let baseExp = base.extractExponent()
        let otherExp = other.extractExponent()
        let baseCoef = base.extractCoefficient()
        let otherCoef = other.extractCoefficient()

        // TODO: Proper magnitude comparison with exponent alignment
        // For now, simplified comparison
        if baseExp != otherExp {
            let expOrder: Decimal.Compare = baseExp < otherExp ? .less : .greater
            return baseNeg ? (expOrder == .less ? .greater : .less) : expOrder
        }

        if baseCoef == otherCoef {
            return .equal
        }

        let coefOrder: Decimal.Compare = baseCoef < otherCoef ? .less : .greater
        return baseNeg ? (coefOrder == .less ? .greater : .less) : coefOrder
    }
}

extension Decimal.Operation where Value == Decimal.Format128 {
    /// Numerical comparison (NaN is unordered)
    public func compare(_ other: Value) -> Decimal.Compare {
        // Handle NaN cases first
        if base.test.nan || other.test.nan {
            return .unordered
        }

        // Handle infinities
        let baseInf = base.test.infinite
        let otherInf = other.test.infinite

        if baseInf && otherInf {
            let baseNeg = base.test.negative
            let otherNeg = other.test.negative
            if baseNeg == otherNeg {
                return .equal
            }
            return baseNeg ? .less : .greater
        }

        if baseInf {
            return base.test.negative ? .less : .greater
        }

        if otherInf {
            return other.test.negative ? .greater : .less
        }

        // Handle zeros
        if base.test.zero && other.test.zero {
            return .equal
        }

        // TODO: Implement proper magnitude comparison
        fatalError("Implementation required")
    }
}
