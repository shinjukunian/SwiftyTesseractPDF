// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyTesseractPDF",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftyTesseractPDF",
            targets: ["SwiftyTesseractPDF", "SwiftyTesseractPDFFont"]),
    ],
    dependencies: [
        .package(name: "SwiftyTesseract", url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftyTesseractPDF",
            dependencies: [.byName(name: "SwiftyTesseract")]),
        
        .target(name: "SwiftyTesseractPDFFont",
                dependencies: [.byName(name: "SwiftyTesseract")],
                resources: [.copy("fontdata")]),
        
        .testTarget(name: "SwiftyTesseractPDFTests",
                    dependencies: ["SwiftyTesseractPDF", "SwiftyTesseractPDFFont"],
                    resources:[.copy("jpn.traineddata"),
                               .copy("image1.png"),
                               .copy("image2.png"),
                               .copy("image3.png"),
                               .copy("image1.png"),
                               .copy("jpn_vert.traineddata"),
                               .copy("pdf.ttf")]
        )
    ]
)
