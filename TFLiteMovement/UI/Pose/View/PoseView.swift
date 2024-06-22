//
//  PoseView.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 21.06.2024.
//

import SwiftUI

struct PoseView: View {
    @State private var dataModel = PoseDataModel()

    var body: some View {
        ZStack {
            CameraView(image: $dataModel.currentFrame)
                .ignoresSafeArea()
                .overlay {
                    GeometryReader { proxy in
                        if let person = dataModel.data?.person, let image = dataModel.currentFrame {
                            let scale = CGPoint(x: proxy.size.width / CGFloat(image.width),
                                                y: proxy.size.height / CGFloat(image.height))
                            PoseViewCanvasOverlay(person: person,
                                                  scale: scale)
                        }
                    }
                }

            if let data = dataModel.data {
                PoseViewHUD(data: data,
                            modelType: $dataModel.modelType,
                            threadCount: $dataModel.threadCount,
                            delegate: $dataModel.delegate)
            }
        }
        .preferredColorScheme(.dark)
    }
}
