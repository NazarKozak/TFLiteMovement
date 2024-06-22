//
//  CameraManager.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 21.06.2024.
//

import AVFoundation
import CoreImage
import UIKit

class CameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let systemPreferredCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    private var sessionQueue = DispatchQueue(label: "video.preview.session")
    private var addToPreviewStream: ((CGImage, CVPixelBuffer) -> Void)?

    lazy var previewStream: AsyncStream<(CGImage, CVPixelBuffer)> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage, buffer in
                continuation.yield((cgImage, buffer))
            }
        }
    }()

    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }

    override init() {
        super.init()
        initialize()
    }

    func initialize() {
        Task {
            await configureSession()
            await startSession()
        }
    }

    private func configureSession() async {
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else { return }

        captureSession.beginConfiguration()

        defer { self.captureSession.commitConfiguration() }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        videoOutput.alwaysDiscardsLateVideoFrames = true

        guard captureSession.canAddInput(deviceInput),
              captureSession.canAddOutput(videoOutput)
        else { return }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)

        // Update the video orientation
        videoOutput.connection(with: .video)?.videoRotationAngle = 90
    }

    private func startSession() async {
        guard await isAuthorized else { return }

        captureSession.startRunning()
    }

    private func rotate(by angle: CGFloat, from connection: AVCaptureConnection) {
        guard connection.isVideoRotationAngleSupported(angle) else { return }
        connection.videoRotationAngle = angle
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage,
              let cvPixelBuffer = sampleBuffer.cvPixelBuffer else {
            print("Can't translate to CGImage")
            return
        }
        addToPreviewStream?(currentFrame, cvPixelBuffer)
    }
}

extension CMSampleBuffer {
    var cgImage: CGImage? {
        guard let imagePixelBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }

    var cvPixelBuffer: CVPixelBuffer? {
        CMSampleBufferGetImageBuffer(self)
    }
}

extension CIImage {
    var cgImage: CGImage? {
        CIContext().createCGImage(self, from: self.extent)
    }
}
