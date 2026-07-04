import XCTest
@testable import MedLookupKit

/// The normalize boundary is the heart of the app, so it gets the tests.
final class NormalizeTests: XCTestCase {
    func testNormalizesAFullLabel() throws {
        let label = try decodeFirst(Self.fullJSON)
        let med = try XCTUnwrap(Medication(from: label))

        XCTAssertEqual(med.id, "abc-1")
        XCTAssertEqual(med.brandName, "Tylenol")
        XCTAssertEqual(med.genericName, "acetaminophen")
        XCTAssertEqual(med.manufacturer, "Johnson & Johnson")
        XCTAssertEqual(med.purpose, "Pain reliever")
        XCTAssertEqual(med.warnings, "Do not exceed the recommended dose.")
    }

    func testFallsBackToGenericWhenBrandIsMissing() throws {
        let label = try decodeFirst(Self.noBrandJSON)
        let med = try XCTUnwrap(Medication(from: label))

        XCTAssertEqual(med.brandName, "ibuprofen") // brand missing -> generic
    }

    func testJoinsMultipleParagraphs() throws {
        let label = try decodeFirst(Self.multiParagraphJSON)
        let med = try XCTUnwrap(Medication(from: label))

        XCTAssertEqual(med.warnings, "First warning.\n\nSecond warning.")
    }

    func testReturnsNilWhenThereIsNoUsableData() throws {
        let label = try decodeFirst(Self.emptyJSON)
        XCTAssertNil(Medication(from: label)) // no id, no names -> dropped
    }

    // MARK: - Helpers

    private func decodeFirst(_ json: String) throws -> DrugLabel {
        let response = try JSONDecoder().decode(DrugLabelResponse.self, from: Data(json.utf8))
        return try XCTUnwrap(response.results?.first)
    }

    // MARK: - Fixtures (small, realistic openFDA shapes)

    static let fullJSON = """
    {"results":[{"id":"abc-1","openfda":{"brand_name":["Tylenol"],"generic_name":["acetaminophen"],"manufacturer_name":["Johnson & Johnson"]},"purpose":["Pain reliever"],"warnings":["Do not exceed the recommended dose."]}]}
    """

    static let noBrandJSON = """
    {"results":[{"id":"abc-2","openfda":{"generic_name":["ibuprofen"]}}]}
    """

    static let multiParagraphJSON = """
    {"results":[{"id":"abc-3","openfda":{"brand_name":["Advil"]},"warnings":["First warning.","Second warning."]}]}
    """

    static let emptyJSON = """
    {"results":[{"openfda":{}}]}
    """
}
