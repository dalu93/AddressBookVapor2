import PackageDescription

let package = Package(
    name: "AddressBook",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor-community/postgresql-provider.git", majorVersion: 2, minor: 0),
        .Package(url: "https://github.com/kylef/JSONWebToken.swift", majorVersion: 2),
        .Package(url: "https://github.com/vapor/validation.git", majorVersion: 1),
        .Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

