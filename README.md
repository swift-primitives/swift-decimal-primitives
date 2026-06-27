# Decimal Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

IEEE 754-2008 decimal floating-point value types for Swift: the 32-, 64-, and 128-bit BID-encoded formats with classification, sign handling, and exact integer conversions.

---

## Quick Start

`Decimal` is a family of IEEE 754-2008 decimal floating-point value types — `Format32`, `Format64`, and `Format128` — together with the vocabulary that describes them. Each format is a thin wrapper over its raw BID (Binary Integer Decimal) bit pattern, so values are bit-exact and trivially `Sendable`, `Hashable`, and copyable. The package supplies the encodings, classification, and integer conversions; it does not impose an arithmetic policy.

```swift
import Decimal_Primitives

// A 64-bit decimal, built exactly from an integer (for example, a price in cents).
let price = Decimal.Format64(1_499 as Int64)
print(price.test.zero)            // false
print(price.sign)                 // positive
print(price.negated.sign)         // negative

// Special values are first-class and classify honestly.
let notANumber = Decimal.Format64.nan()
let negativeInfinity = Decimal.Format64.infinity(sign: .negative)
print(notANumber.test.nan)        // true
print(negativeInfinity.test.infinite)  // true

// Round-trip back to an integer when the value is exact.
let n = Int64(exactly: price)     // Optional(1499)
```

Each format conforms to `Decimal.Layout`, which exposes its precision, exponent range, and bias. You can assemble a finite value from its sign, exponent, and coefficient, then read those parts back without loss.

```swift
import Decimal_Primitives

// Three IEEE 754-2008 interchange formats, each conforming to Decimal.Layout.
print(Int(Decimal.Format32.precision))   // 7
print(Int(Decimal.Format64.precision))   // 16
print(Int(Decimal.Format128.precision))  // 34

// Assemble a finite value (14.99) from its parts, then read them back bit-exactly.
let value = Decimal.Format64.encode(sign: .positive, exponent: -2, coefficient: 1_499)
print(value.extractCoefficient())        // 1499
print(Int(value.extractExponent()))      // -2
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-decimal-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Decimal Primitives", package: "swift-decimal-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products, with no dependencies outside the Swift standard library.

| Product | Target | Purpose |
|---------|--------|---------|
| `Decimal Primitives` | `Sources/Decimal Primitives/` | The `Decimal` namespace: the `Format32`, `Format64`, and `Format128` BID-encoded types; the `Decimal.Layout` protocol; and the supporting value types `Class`, `Sign`, `NaN`, `Compare`, `Order`, `Exponent`, `Precision`, and `Payload`. |
| `Decimal Primitives Test Support` | `Tests/Support/` | Re-exports the main target for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
