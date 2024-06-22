//
//  CameraView.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 20.06.2024.
//

import SwiftUI

struct CameraView: View {
    @Binding var image: CGImage?

    var body: some View {
        if let image = image {
            Image(decorative: image, scale: 1)
                .resizable()
                .scaledToFit()
        } else {
            ContentUnavailableView("Camera feed interrupted", systemImage: "xmark.circle.fill")
        }
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
