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

    @Test func initializesFromInt64MinByReturningNilRatherThanTrapping() {
        #expect(Decimal.Format64(Int64.min) == nil)
    }

    @Test func initializesFromUInt64MaxByReturningNilRatherThanFatalError() {
        #expect(Decimal.Format64(UInt64.max) == nil)
    }

    @Test func initializesFromLargeInt64ByReturningNilRatherThanCorrupting() {
        #expect(Decimal.Format64(Int64.max) == nil)
    }

    @Test func initializesFromLargeMultipleOfTenByNormalizingTrailingZeros() {
        let original: Int64 = 1_000_000_000_000_000_000
        let value = Decimal.Format64(original)
        #expect(value != nil)
        #expect(value.flatMap { Int64(exactly: $0) } == original)
    }
}
