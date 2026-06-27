import Testing

@testable import Decimal_Primitives

@Suite struct Format64BitsTests {
    @Test func zero() {
        let zero = Decimal.Format64.zero()
        #expect(zero.test.zero)
        #expect(!zero.test.negative)
    }

    @Test func negativeZero() {
        let negZero = Decimal.Format64.zero(sign: .negative)
        #expect(negZero.test.zero)
        #expect(negZero.test.negative)
    }

    @Test func infinity() {
        let inf = Decimal.Format64.infinity()
        #expect(inf.test.infinite)
        #expect(!inf.test.negative)
    }

    @Test func negativeInfinity() {
        let negInf = Decimal.Format64.infinity(sign: .negative)
        #expect(negInf.test.infinite)
        #expect(negInf.test.negative)
    }

    @Test func quietNaN() {
        let qnan = Decimal.Format64.nan()
        #expect(qnan.test.nan)
        #expect(!qnan.test.signaling)
    }

    @Test func signalingNaN() {
        let snan = Decimal.Format64.nan(kind: .signaling)
        #expect(snan.test.nan)
        #expect(snan.test.signaling)
    }

    @Test func negation() {
        let pos = Decimal.Format64.zero()
        let neg = pos.negated
        #expect(neg.test.negative)
        #expect(neg.negated.test.zero)
        #expect(!neg.negated.test.negative)
    }
}
