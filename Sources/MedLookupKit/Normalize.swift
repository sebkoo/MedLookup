import Foundation

public extension Medication {
    /// The single boundary where messy openFDA data is made well-formed.
    ///
    /// - Arrays are flattened into readable text.
    /// - A missing brand name falls back to the generic name, then to "Unknown",
    ///   so the UI never renders an empty title.
    /// - Returns `nil` only when a row has no usable identifier at all, so the
    ///   caller can simply drop it (`compactMap`).
    init?(from label: DrugLabel) {
        let brand = label.openfda?.brandName?.first
        let generic = label.openfda?.genericName?.first

        guard let id = label.id ?? brand ?? generic else { return nil }

        self.init(
            id: id,
            brandName: brand ?? generic ?? "Unknown",
            genericName: generic,
            manufacturer: label.openfda?.manufacturerName?.first,
            purpose: Self.joined(label.purpose),
            warnings: Self.joined(label.warnings),
            indications: Self.joined(label.indicationsAndUsage)
        )
    }

    /// Join an optional list of paragraphs into a single block, or `nil` if empty.
    private static func joined(_ parts: [String]?) -> String? {
        guard let parts, !parts.isEmpty else { return nil }
        return parts.joined(separator: "\n\n")
    }
}
