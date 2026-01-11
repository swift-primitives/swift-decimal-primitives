extension Decimal.Operation where Value == Decimal.Format64 {
    /// Fused multiply-add: (self * a) + b with single rounding
    public func fuse(
        _ a: Value,
        _ b: Value,
        context: Decimal.Context = .format64
    ) -> Decimal.Outcome<Value> {
        // TODO: Implement IEEE 754 fused multiply-add
        // - Compute (self * a) with full precision (no intermediate rounding)
        // - Add b to the full-precision product
        // - Round once at the end
        fatalError("Implementation required")
    }

    public func fuse(
        _ a: Value,
        _ b: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try fuse(a, b, context: context).trapped(by: context.traps)
    }
}
