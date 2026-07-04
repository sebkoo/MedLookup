import Foundation

/// Raw openFDA `drug/label` payload, exactly as the API returns it.
///
/// The data is messy by design: almost every field is an *optional array of
/// strings*, and many rows are missing names entirely. We keep this wire shape
/// honest and do the cleanup in exactly one place — see `Medication.init(from:)`.
public struct DrugLabelResponse: Decodable {
    public let results: [DrugLabel]?
}

/// A single raw label record from openFDA.
public struct DrugLabel: Decodable {
    public let id: String?
    public let openfda: OpenFDA?
    public let purpose: [String]?
    public let warnings: [String]?
    public let indicationsAndUsage: [String]?

    enum CodingKeys: String, CodingKey {
        case id, openfda, purpose, warnings
        case indicationsAndUsage = "indications_and_usage"
    }
}

/// The nested `openfda` block — brand / generic / manufacturer, each a list.
public struct OpenFDA: Decodable {
    public let brandName: [String]?
    public let genericName: [String]?
    public let manufacturerName: [String]?

    enum CodingKeys: String, CodingKey {
        case brandName = "brand_name"
        case genericName = "generic_name"
        case manufacturerName = "manufacturer_name"
    }
}
