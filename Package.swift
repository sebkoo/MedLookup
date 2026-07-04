// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MedLookupKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "MedLookupKit", targets: ["MedLookupKit"]),
    ],
    targets: [
        .target(name: "MedLookupKit"),
    ]
)
