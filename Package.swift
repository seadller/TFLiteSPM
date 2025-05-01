
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyTFLiteWrapper",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MyTFLiteWrapper",
            targets: ["MyTFLiteWrapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kewlbear/TensorFlowLiteSwift.git", branch: "master")
    ],
    targets: [
        .target(
            name: "MyTFLiteWrapper",
            dependencies: ["TensorFlowLiteSwift"],
            path: "Sources/MyTFLiteWrapper",
            resources: []
        )
    ]
)
