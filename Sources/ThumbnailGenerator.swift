//
//  ThumbnailGenerator.swift
//
//  Copyright (c) 2019 Todd Kramer (http://www.tekramer.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import AVFoundation
import CoreImage

public protocol ThumbnailGeneratorDelegate: class {

    func thumbnailGenerator(_ thumbnailGenerator: ThumbnailGenerator, didGenerateThumbnail thumbnail: Image, atTime time: Double)
    func thumbnailGenerator(_ thumbnailGenerator: ThumbnailGenerator, thumbnailGenerationDidFailWithError error: ThumbnailGenerationError,
                            atTime time: Double)

}

public final class ThumbnailGenerator {

    private enum PlayerState {
        case loading
        case ready
    }

    public let asset: AVAsset
    public weak var delegate: ThumbnailGeneratorDelegate?
    private(set) var times: [Double] = []

    var player: AVPlayer!
    private var observer: NSKeyValueObservation?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var playerState: PlayerState = .loading {
        didSet {
            guard playerState == .ready, !times.isEmpty else { return }
            generateNextThumbnail()
            
        }
    }

    private let mainQueue: Dispatching
    private let backgroundQueue: Dispatching

    init(asset: AVAsset, mainQueue: Dispatching, backgroundQueue: Dispatching) {
        self.asset = asset
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        setup()
    }

    public convenience init(asset: AVAsset) {
        let defaultBackgroundQueue = DispatchQueue(label: "com.thumbnail-generator.background")
        self.init(asset: asset, mainQueue: DispatchQueue.main, backgroundQueue: defaultBackgroundQueue)
    }

    // MARK: - Setup

    private func setup() {
        setupPlayer()
        setupObserver()
        setupVideoOutput()
    }

    private func setupPlayer() {
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [])
        player = AVPlayer(playerItem: playerItem)
        player.rate = 0
    }

    private func setupObserver() {
        self.observer = player.currentItem?.observe(\.status, options:  [.new, .old]) { [weak self] (playerItem, change) in
            guard let self = self, case .readyToPlay = playerItem.status, self.playerState == .loading else  { return }
            self.playerState = .ready
        }
    }

    private func setupVideoOutput() {
        let settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: settings)
        guard let videoOutput = videoOutput else { return }
        player.currentItem?.add(videoOutput)
    }

    // MARK: - Thumbnail Generation

    public func generateThumbnails(atTimesInSeconds times: [Double]) {
        self.times += times
        guard playerState == .ready else { return }
        backgroundQueue.async(generateNextThumbnail)
    }

    private func generateNextThumbnail() {
        guard !times.isEmpty else { return }
        let time = times.removeFirst()
        generateThumbnail(atTimeInSeconds: time)
    }

    private func generateThumbnail(atTimeInSeconds time: Double) {
        let time = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] isFinished in
            guard let self = self else { return }
            guard isFinished else {
                self.mainQueue.async {
                    self.delegate?.thumbnailGenerator(self, thumbnailGenerationDidFailWithError: .seekInterrupted, atTime: time.seconds)
                }
                self.generateNextThumbnail()
                return
            }
            self.backgroundQueue.delay(0.3) {
                self.didFinishSeeking(toTime: time)
            }
        }
    }

    private func didFinishSeeking(toTime time: CMTime) {
        guard let buffer = videoOutput?.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            mainQueue.async {
                self.delegate?.thumbnailGenerator(self, thumbnailGenerationDidFailWithError: .copyPixelBufferFailed, atTime: time.seconds)
            }
            generateNextThumbnail()
            return
        }
        processPixelBuffer(buffer, atTime: time.seconds)
    }

    private func processPixelBuffer(_ buffer: CVPixelBuffer, atTime time: Double) {
        defer {
            generateNextThumbnail()
        }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        guard let videoImage = CIContext().createCGImage(ciImage, from: imageRect) else {
            mainQueue.async {
                self.delegate?.thumbnailGenerator(self, thumbnailGenerationDidFailWithError: .imageCreationFailed, atTime: time)
            }
            return
        }
        #if os(iOS) || os(tvOS) || os(watchOS)
        let image = Image(cgImage: videoImage)
        #elseif os(OSX)
        let image = Image(cgImage: videoImage, size: imageRect.size)
        #endif
        mainQueue.async {
            self.delegate?.thumbnailGenerator(self, didGenerateThumbnail: image, atTime: time)
        }
    }

}
