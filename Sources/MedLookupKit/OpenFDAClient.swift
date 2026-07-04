import Foundation

/// Abstraction so screens and tests can depend on a protocol, not a concrete
/// network client (easy to mock).
public protocol MedicationSearching {
    func search(query: String, limit: Int) async throws -> [Medication]
}

/// Talks to the free, key-less openFDA `drug/label` endpoint and returns clean
/// `Medication` values — normalized at the boundary.
///
/// API: https://open.fda.gov/apis/drug/label/  (no API key required)
public struct OpenFDAClient: MedicationSearching {
    public enum ClientError: Error, Equatable {
        case emptyQuery
        case badResponse(status: Int)
    }

    private let session: URLSession
    private let baseURL = URL(string: "https://api.fda.gov/drug/label.json")!

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func search(query: String, limit: Int = 25) async throws -> [Medication] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ClientError.emptyQuery }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "search", value: "openfda.brand_name:\"\(trimmed)\""),
            URLQueryItem(name: "limit", value: String(limit)),
        ]

        let (data, response) = try await session.data(from: components.url!)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ClientError.badResponse(status: http.statusCode)
        }

        let payload = try JSONDecoder().decode(DrugLabelResponse.self, from: data)
        // Normalize at the boundary; silently drop rows with no usable data.
        return (payload.results ?? []).compactMap(Medication.init(from:))
    }
}
