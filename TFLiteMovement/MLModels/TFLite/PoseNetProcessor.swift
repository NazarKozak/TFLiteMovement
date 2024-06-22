//
//  PoseNetProcessor.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 22.06.2024.
//

import Foundation

import AVFoundation
import UIKit
import os

class PoseNetProcessor {
    private var modelType: ModelType
    private var threadCount: Int
    private var delegate: Delegates
    private let minimumScore: Float32 = 0.2
    private var poseEstimator: PoseEstimator?
    private var isRunning = false

    init(modelType: ModelType, threadCount: Int, delegate: Delegates) {
        self.modelType = modelType
        self.threadCount = threadCount
        self.delegate = delegate
        self.updateModel()

        os_log("Running model on: \(modelType), delegate: \(delegate), with: \(threadCount) threads")
    }

    /// Call this method when there's change in pose estimation model config, including changing model
    /// or updating runtime config.
    private func updateModel() {
        // Update the model in the same serial queue with the inference logic to avoid race condition
        do {
            switch self.modelType {
            case .posenet:
                self.poseEstimator = try PoseNet(
                    threadCount: self.threadCount,
                    delegate: self.delegate)
            case .movenetLighting, .movenetThunder:
                self.poseEstimator = try MoveNet(
                    threadCount: self.threadCount,
                    delegate: self.delegate,
                    modelType: self.modelType)
            }
        } catch let error {
            os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
    }

    /// Run pose estimation on the input frame from the camera.
    func runModel(_ pixelBuffer: CVPixelBuffer) -> PoseViewData? {
        // Guard to make sure that there's only 1 frame process at each moment.
        // Guard to make sure that the pose estimator is already initialized.
        guard !isRunning, let estimator = poseEstimator else { return nil }

        self.isRunning = true
        defer { isRunning = false }
        // Run pose estimation
        do {
            let (person, times) = try estimator.estimateSinglePose(on: pixelBuffer)
            return PoseViewData(score: person.scoreValue,
                                    time: times.totalTime,
                                    person: person.score > minimumScore ? person : nil)

        } catch {
            os_log("Error running pose estimation.", type: .error)
            return nil
        }
    }
}

extension Person {
    var scoreValue: String {
        String(format: "%.3f", self.score)
    }
}

extension Times {
    var totalTime: String {
        String(format: "%.2fms", self.total * 1000)
    }
}
