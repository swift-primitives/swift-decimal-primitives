extension Decimal.Operation where Value == Decimal.Format64 {
    /// Quantize: adjust exponent to match `other`, rounding coefficient
    public func quantize(
        to other: Value,
        context: Decimal.Context = .format64
    ) -> Decimal.Outcome<Value> {
        // TODO: Implement IEEE 754 quantize
        // - Extract target exponent from `other`
        // - Adjust coefficient to achieve that exponent
        // - Round if necessary
        // - Handle overflow/underflow
        fatalError("Implementation required")
    }

    /// Rescale to specific exponent
    public func rescale(
        exponent: Decimal.Exponent,
        context: Decimal.Context = .format64
    ) -> Decimal.Outcome<Value> {
        // TODO: Implement rescale
        // - Adjust coefficient to achieve target exponent
        // - Round if necessary
        // - Handle overflow/underflow
        fatalError("Implementation required")
    }
}
