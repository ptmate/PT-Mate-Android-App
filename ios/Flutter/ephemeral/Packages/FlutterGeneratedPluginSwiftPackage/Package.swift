// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus"),
        .package(name: "intercom_flutter", path: "../.packages/intercom_flutter"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios"),
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications"),
        .package(name: "firebase_storage", path: "../.packages/firebase_storage"),
        .package(name: "firebase_core", path: "../.packages/firebase_core"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging"),
        .package(name: "firebase_database", path: "../.packages/firebase_database"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth"),
        .package(name: "cloud_functions", path: "../.packages/cloud_functions"),
        .package(name: "cloud_firestore", path: "../.packages/cloud_firestore"),
        .package(name: "audioplayers_darwin", path: "../.packages/audioplayers_darwin")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "intercom-flutter", package: "intercom_flutter"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "firebase-storage", package: "firebase_storage"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "firebase-database", package: "firebase_database"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "cloud-functions", package: "cloud_functions"),
                .product(name: "cloud-firestore", package: "cloud_firestore"),
                .product(name: "audioplayers-darwin", package: "audioplayers_darwin")
            ]
        )
    ]
)
