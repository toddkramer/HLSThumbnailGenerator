# HLSThumbnailGenerator

![CocoaPods Version](https://cocoapod-badges.herokuapp.com/v/HLSThumbnailGenerator/badge.png) [![Swift](https://img.shields.io/badge/swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/) ![Platform](https://cocoapod-badges.herokuapp.com/p/HLSThumbnailGenerator/badge.png) [![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Overview

HLSThumbnailGenerator is a substitute for AVAssetImageGenerator when generating thumbnails from streaming video.

## Features

- iOS 9.0+, macOS 10.10+, tvOS 9.0+
- Can pass in an array of times (in seconds) to request thumbnails

## Usage

```swift
let urlString = "<hls-url>"
guard let url = URL(string: urlString) else { return }
let asset = AVAsset(url: url)
generator = ThumbnailGenerator(asset: asset)
generator.delegate = self
generator.generateThumbnails(atTimesInSeconds: [16.1, 33.2, 55.2])
```

## Installation

### CocoaPods

[CocoaPods][] is a centralized dependency manager for Cocoa projects. To install
HLSThumbnailGenerator with CocoaPods:

1. Make sure the latest version of CocoaPods is [installed](https://guides.cocoapods.org/using/getting-started.html#getting-started).


2. Add HLSThumbnailGenerator to your Podfile:

``` ruby
use_frameworks!

pod 'HLSThumbnailGenerator', '~> 0.5.0'
```

3. Run `pod install`.

[CocoaPods]: https://cocoapods.org


### Swift Package Manager

[Swift Package Manager](https://github.com/apple/swift-package-manager) is Apple's
official package manager for Swift frameworks. To install with Swift Package
Manager:

1. Add HLSThumbnailGenerator to your Package.swift file:

```
import PackageDescription

let package = Package(
    name: "MyAppTarget",
    dependencies: [
        .Package(url: "https://github.com/toddkramer/HLSThumbnailGenerator", majorVersion: 0, minor: 5)
    ]
)
```

2. Run `swift build`.

3. Generate Xcode project:

```
swift package generate-xcodeproj
```


### Carthage

[Carthage][] is a decentralized dependency manager for Cocoa projects. To
install HLSThumbnailGenerator with Carthage:

1. Make sure Carthage is [installed][Carthage Installation].

2. Add HLSThumbnailGenerator to your Cartfile:

```
github "toddkramer/HLSThumbnailGenerator" ~> 0.5.0
```

3. Run `carthage update` and [add the appropriate framework][Carthage Usage].


[Carthage]: https://github.com/Carthage/Carthage
[Carthage Installation]: https://github.com/Carthage/Carthage#installing-carthage
[Carthage Usage]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

