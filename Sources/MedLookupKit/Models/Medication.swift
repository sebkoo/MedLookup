import Foundation

/// The clean, app-facing medication.
///
/// Every field the UI needs is guaranteed and non-array. It is built once at the
/// normalize boundary (`Medication.init(from:)`) so screens never touch the raw,
/// optional-array openFDA shape.
public struct Medication: Identifiable, Equatable {
    public let id: String
    public let brandName: String
    public let genericName: String?
    public let manufacturer: String?
    public let purpose: String?
    public let warnings: String?
    public let indications: String?

    public init(
        id: String,
        brandName: String,
        genericName: String? = nil,
        manufacturer: String? = nil,
        purpose: String? = nil,
        warnings: String? = nil,
        indications: String? = nil
    ) {
        self.id = id
        self.brandName = brandName
        self.genericName = genericName
        self.manufacturer = manufacturer
        self.purpose = purpose
        self.warnings = warnings
        self.indications = indications
    }
}
