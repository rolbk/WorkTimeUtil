// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "WorkTimeUtil",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WorkTimeUtil", targets: ["WorkTimeUtil"]),
    ],
    targets: [
        .executableTarget(
            name: "WorkTimeUtil",
            path: "WorkTimeUtil"
        ),
        .testTarget(
            name: "WorkTimeUtilTests",
            dependencies: ["WorkTimeUtil"],
            path: "WorkTimeUtilTests"
        ),
    ]
)
