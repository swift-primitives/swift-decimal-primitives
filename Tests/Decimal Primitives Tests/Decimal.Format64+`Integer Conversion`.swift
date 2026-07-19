import Testing

@testable import Decimal_Primitives

extension Decimal.Format64 {
    @Suite struct `Integer Conversion` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Decimal.Format64.`Integer Conversion`.`Edge Case` {
    /// F-004: `Int64.min`'s magnitude (2^63) has 19 significant digits and no
    /// factor of five, so no power-of-ten normalization can bring it into this
    /// format's 16-digit precision. The correct outcome is `nil` — the
    /// unfixed initializer instead traps while computing `-Int64.min`.
    @Test func initializesFromInt64MinByReturningNilRatherThanTrapping() {
        #expect(Decimal.Format64(Int64.min) == nil)
    }

    /// F-004: `UInt64.max` (20 digits) is not representable and not a
    /// multiple of a power of ten small enough to fit in 16 digits; the
    /// unfixed initializer `fatalError`s instead of returning `nil`.
    @Test func initializesFromUInt64MaxByReturningNilRatherThanFatalError() {
        #expect(Decimal.Format64(UInt64.max) == nil)
    }

    /// F-004: `Int64.max` has 19 significant digits, exceeding this format's
    /// 16-digit precision, and is not a multiple of a large enough power of
    /// ten to fit. The unfixed initializer had no magnitude check at all and
    /// silently truncated it into a wrong value instead of returning `nil`.
    @Test func initializesFromLargeInt64ByReturningNilRatherThanCorrupting() {
        #expect(Decimal.Format64(Int64.max) == nil)
    }

    /// F-004: a value that exceeds 16 significant digits but is an exact
    /// multiple of a small enough power of ten IS exactly representable
    /// after normalization, and must round-trip exactly (not corrupt).
    @Test func initializesFromLargeMultipleOfTenByNormalizingTrailingZeros() {
        let original: Int64 = 1_000_000_000_000_000_000  // 10^18: 1 digit once normalized
        let value = Decimal.Format64(original)
        #expect(value != nil)
        #expect(value.flatMap { Int64(exactly: $0) } == original)
    }
}
