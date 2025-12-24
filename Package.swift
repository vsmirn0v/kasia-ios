// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KasiaMessenger",
    platforms: [.iOS(.v16)],
    products: [],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift", from: "1.22.0"),
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.26.0")
    ],
    targets: []
)
