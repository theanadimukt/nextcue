// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "SharePayloadKit",
  platforms: [.iOS(.v15)],
  products: [.library(name: "SharePayloadKit", targets: ["SharePayloadKit"])],
  targets: [
    .target(name: "SharePayloadKit"),
    .testTarget(name: "SharePayloadKitTests", dependencies: ["SharePayloadKit"]),
  ]
)
