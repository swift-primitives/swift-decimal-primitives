extension Decimal {
    /// Namespace for text operations
    public enum Text { }
}

// MARK: - Text Accessor

extension Decimal.Text {
    public struct Accessor<Value> {
        @usableFromInline
        let base: Value

        @usableFromInline
        internal init(_ base: Value) {
            self.base = base
        }
    }
}

extension Decimal.Text.Accessor: Sendable where Value: Sendable { }

// MARK: - Parse Type

extension Decimal.Text {
    public struct Parse<Value> {
        @usableFromInline
        internal init() { }
    }
}

extension Decimal.Text.Parse: Sendable where Value: Sendable { }

// MARK: - Format64 Text Accessor

extension Decimal.Format64 {
    public var text: Decimal.Text.Accessor<Self> {
        Decimal.Text.Accessor(self)
    }

    public static var text: Decimal.Text.Parse<Self> {
        Decimal.Text.Parse()
    }
}

// MARK: - Format32 Text Accessor

extension Decimal.Format32 {
    public var text: Decimal.Text.Accessor<Self> {
        Decimal.Text.Accessor(self)
    }

    public static var text: Decimal.Text.Parse<Self> {
        Decimal.Text.Parse()
    }
}

// MARK: - Format128 Text Accessor

extension Decimal.Format128 {
    public var text: Decimal.Text.Accessor<Self> {
        Decimal.Text.Accessor(self)
    }

    public static var text: Decimal.Text.Parse<Self> {
        Decimal.Text.Parse()
    }
}
