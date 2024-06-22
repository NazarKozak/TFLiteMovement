//
//  PoseDataModel.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 21.06.2024.
//

import Foundation
import CoreImage

@Observable
class PoseDataModel {
    var currentFrame: CGImage?
    var data: PoseViewData?

    var modelType: ModelType = .movenetThunder { didSet { updateModel() } }
    var threadCount: Int = 4 { didSet { updateModel() } }
    var delegate: Delegates = .gpu { didSet { updateModel() } }

    private let cameraManager = CameraManager()
    @ObservationIgnored
    private var poseNet = PoseNetProcessor(modelType: .movenetThunder, threadCount: 4, delegate: .gpu)

    init() {
        handleCameraPreviews()
    }

    func handleCameraPreviews() {
        Task {
            for await (image, buffer) in cameraManager.previewStream {
                await MainActor.run {
                    currentFrame = image
                }
                data = poseNet.runModel(buffer)
            }
        }
    }

    func updateModel() {
        Task {
            await MainActor.run {
                poseNet = PoseNetProcessor(modelType: modelType, threadCount: threadCount, delegate: delegate)
            }
        }
    }
}
