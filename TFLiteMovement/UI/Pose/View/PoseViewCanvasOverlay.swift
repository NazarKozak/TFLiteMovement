//
//  PoseViewCanvasOverlay.swift
//  TFLiteMovement
//
//  Created by Nazar Kozak on 22.06.2024.
//

import SwiftUI
import os

struct PoseViewCanvasOverlay: View {
    let person: Person
    let scale: CGPoint

    /// List of lines connecting each part to be visualized.
    private static let lines = [
        (from: BodyPart.leftWrist, to: BodyPart.leftElbow),
        (from: BodyPart.leftElbow, to: BodyPart.leftShoulder),
        (from: BodyPart.leftShoulder, to: BodyPart.rightShoulder),
        (from: BodyPart.rightShoulder, to: BodyPart.rightElbow),
        (from: BodyPart.rightElbow, to: BodyPart.rightWrist),
        (from: BodyPart.leftShoulder, to: BodyPart.leftHip),
        (from: BodyPart.leftHip, to: BodyPart.rightHip),
        (from: BodyPart.rightHip, to: BodyPart.rightShoulder),
        (from: BodyPart.leftHip, to: BodyPart.leftKnee),
        (from: BodyPart.leftKnee, to: BodyPart.leftAnkle),
        (from: BodyPart.rightHip, to: BodyPart.rightKnee),
        (from: BodyPart.rightKnee, to: BodyPart.rightAnkle),
    ]

    /// Visualization configs
    private enum Config {
        static let dot = (radius: CGFloat(10), color: Color.orange)
        static let line = (width: CGFloat(5.0), color: Color.orange)
    }

    var body: some View {
        Canvas { context, size in
            guard let strokes else { return }

            for dot in strokes.dots {
                let dotRect = CGRect(
                    x: dot.x - Config.dot.radius / 2, y: dot.y - Config.dot.radius / 2,
                    width: Config.dot.radius, height: Config.dot.radius)
                let dotPath = Path(CGPath(
                    roundedRect: dotRect, cornerWidth: Config.dot.radius, cornerHeight: Config.dot.radius,
                    transform: nil))
                context.fill(dotPath, with: .color(Config.dot.color))
            }

            let path = Path { path in
                for line in strokes.lines {
                    path.move(to: CGPoint(x: line.from.x, y: line.from.y))
                    path.addLine(to: CGPoint(x: line.to.x, y: line.to.y))
                }
            }
            context.stroke(path, with: .color(Config.line.color), style: StrokeStyle(lineWidth: Config.line.width))
        }
    }

    private var strokes: Strokes? {
        var strokes = Strokes(dots: [], lines: [])
        // MARK: Visualization of detection result
        var bodyPartToDotMap: [BodyPart: CGPoint] = [:]
        for (index, part) in BodyPart.allCases.enumerated() {
            let position = CGPoint(x: person.keyPoints[index].coordinate.x / scale.x,
                                   y: person.keyPoints[index].coordinate.y / scale.y)
            bodyPartToDotMap[part] = position
            strokes.dots.append(position)
        }

        do {
            try strokes.lines = PoseViewCanvasOverlay.lines.map { map throws -> Line in
                guard let from = bodyPartToDotMap[map.from] else {
                    throw VisualizationError.missingBodyPart(of: map.from)
                }
                guard let to = bodyPartToDotMap[map.to] else {
                    throw VisualizationError.missingBodyPart(of: map.to)
                }
                return Line(from: from, to: to)
            }
        } catch VisualizationError.missingBodyPart(let missingPart) {
            os_log("Visualization error: %s is missing.", type: .error, missingPart.rawValue)
            return nil
        } catch {
            os_log("Visualization error: %s", type: .error, error.localizedDescription)
            return nil
        }
        return strokes
    }
}

/// The strokes to be drawn in order to visualize a pose estimation result.
fileprivate struct Strokes {
    var dots: [CGPoint]
    var lines: [Line]
}

/// A straight line.
fileprivate struct Line {
    let from: CGPoint
    let to: CGPoint
}

fileprivate enum VisualizationError: Error {
    case missingBodyPart(of: BodyPart)
}
