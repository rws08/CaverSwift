// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CaverSwift",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v12)
    ],
    products: [
        .library(
            name: "CaverSwift",
            targets: ["CaverSwift"]),
    ],
    dependencies: [
        .package(name: "ASN1", url: "https://github.com/leif-ibsen/ASN1", from: "2.0.0"),
        .package(name: "BigInt", url: "https://github.com/leif-ibsen/BigInt", from: "1.2.5"),
        .package(name: "GenericJSON", url: "https://github.com/zoul/generic-json-swift", from: "2.0.1"),
        .package(name: "secp256k1", url: "https://github.com/Boilertalk/secp256k1.swift", from: "0.1.4"),
    ],
    targets: [
        .target(
            name: "CaverSwift",
            dependencies: [.target(name: "aes"),
                           .target(name: "keccaktiny"),
                           .target(name: "libscrypt"),
                           "ASN1",
                           "BigInt",
                           "GenericJSON",
                           "secp256k1"],
	        path:"CaverSwift",
            exclude: ["Info.plist", "./lib/aes", "./lib/keccak-tiny", "./lib/libscrypt", "Pods"],
            resources: [
                .process("./kct/kip7/KIP7ConstantData.json"),
                .process("./kct/kip13/KIP13ConstantData.json"),
                .process("./kct/kip17/KIP17ConstantData.json"),
                .process("./kct/kip37/KIP37ConstantData.json")]
        ),
        .target(
            name: "aes",
            dependencies: [],
            path: "CaverSwift/lib/aes",
            exclude: ["module.map"],
            publicHeadersPath: "include"
        ),
        .target(
            name: "keccaktiny",
            dependencies: [],
            path: "CaverSwift/lib/keccak-tiny",
            exclude: ["module.map"],
            publicHeadersPath: "include"
        ),
        .target(
            name: "libscrypt",
            dependencies: [],
            path: "CaverSwift/lib/libscrypt",
            exclude: ["module.map", "./LICENSE", "./Makefile", "./README.md", "libscrypt.version", "main.c"]
        ),
        .testTarget(
            name: "CaverSwiftTests",
            dependencies: ["CaverSwift"],
            path:"Test",
            exclude: ["./Common/Info.plist", "./Transaction/Info.plist"],
            resources: [
                .copy("./Common/ContractImproveFuncTestData.json"),
                .copy("./Common/ContractOverloadFunctionsTestData.json"),
                .copy("./Common/ContractTestData.json"),
                .copy("./Common/DelegationContract.json"),
                .copy("./Common/KIP7TestData.json"),
                .copy("./Common/KIP17TestData.json"),
                .copy("./Common/KIP37TestData.json"),
                .copy("./Common/StructContractTestData.json"),
                .copy("./Common/testFunction.json")
            ]
        ),
    ]
)
