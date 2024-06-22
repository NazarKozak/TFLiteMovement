//
//  PoseViewHUD.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 22.06.2024.
//

import SwiftUI

struct PoseViewHUD: View {
    let data: PoseViewData

    @Binding var modelType: ModelType
    @Binding var threadCount: Int
    @Binding var delegate: Delegates

    var body: some View {
        VStack {
            dataScoreView
            Spacer()
            controlsView
        }
    }

    private var dataScoreView: some View {
        HStack {
            Text("Score: \(data.score)")
            Spacer()
            Text("Time: \(data.time)")
                .frame(width: 150)
        }
        .padding(8)
        .background(.black)
    }

    private var controlsView: some View {
        VStack {
            Stepper(value: $threadCount, in: 1...8) {
                HStack {
                    Text("Thread Count")
                    Spacer()
                    Text("\(threadCount)")
                        .padding(.trailing, 8)
                }
            }

            Picker(selection: $delegate) {
                ForEach(Delegates.allCases, id: \.self) { delegate in
                    Text(delegate.rawValue)
                        .id(delegate)
                }
            } label: {
                Text("Delegate")
            }
            .pickerStyle(SegmentedPickerStyle())

            Picker(selection: $modelType) {
                ForEach(ModelType.allCases, id: \.self) { model in
                    Text(model.rawValue)
                        .id(model)
                }
            } label: {
                Text("Model")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(8)
        .background(.black)
    }
}
