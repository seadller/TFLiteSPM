
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
    targets: [
        .target(
            name: "MyTFLiteWrapper",
            dependencies: [],
            path: "Sources/MyTFLiteWrapper",
            resources: [],
            linkerSettings: [
                .linkedFramework("TensorFlowLiteSwift")
            ]
        ),
        .binaryTarget(
            name: "TensorFlowLiteSwift",
            path: "./TensorFlowLiteSwift.xcframework"
        )
    ]
)
