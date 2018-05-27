//
//  LineChartView.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

// TODO: - Support Multiple Lines Per ViewModel, Handle Insets

public class LineChartView: UIView {
    
    private let shapeLayer: CAShapeLayer
    private let animationTimingFunction: CAMediaTimingFunction
    private var currentViewModel: LineChartViewModel?
    
    public init(animationTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                translatesAutoresizingMaskIntoConstraints: Bool = false) {
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.animationTimingFunction = animationTimingFunction
        
        super.init(frame: .zero)
        
        self.layer.addSublayer(shapeLayer)
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configuration

extension LineChartView {
    
    public func configure(with viewModel: LineChartViewModel) {
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = viewModel.dataSets.first!.segments.first!.lineStyle.lineColor.cgColor
        shapeLayer.lineWidth = viewModel.dataSets.first!.segments.first!.lineStyle.lineWidth
        
        if let currentViewModel = currentViewModel {
            animate(from: currentViewModel, to: viewModel)
        } else {
            shapeLayer.path = path(
                from: viewModel.dataSets.first!.segments.first!.dataPoints,
                with: viewModel
            )
        }
        
        currentViewModel = viewModel
    }
}

// MARKL: - Drawing

extension LineChartView {
    
    private func path(from points: [LineChartDataPoint], with viewModel: LineChartViewModel) -> CGPath {
        let path = UIBezierPath()
        
        let visualPoints = points.map { point in
            visualPoint(from: point, with: viewModel)
        }
        
        guard let firstVisualPoint = visualPoints.first else {
            return path.cgPath
        }

        path.move(to: firstVisualPoint)
        for visualPoint in visualPoints.dropFirst() {
            path.addLine(to: visualPoint)
        }

        return path.cgPath
    }
    
    private func visualPoint(from dataPoint: LineChartDataPoint, with viewModel: LineChartViewModel) -> CGPoint {
        let scaledX: CGFloat = {
            // If this is the only data point, draw it at the beginning of the chart
            guard viewModel.xRange > 0 else {
                return 0
            }
            
            return CGFloat((dataPoint.x - viewModel.minX) / viewModel.xRange)
        }()
        
        let adjustedX = scaledX * bounds.width
        
        let scaledY: CGFloat = {
            // If this is the only data point, draw it in the vertical center
            guard viewModel.yRange > 0 else {
                return 0.5
            }
            
            return CGFloat((dataPoint.y - viewModel.minY) / viewModel.yRange)
        }()
        
        let adjustedY = bounds.height - scaledY * bounds.height
        
        return CGPoint(x: adjustedX, y: adjustedY)
    }
}

// MARK: - Animation

extension LineChartView: CAAnimationDelegate {
    
    private func animate(from oldViewModel: LineChartViewModel, to newViewModel: LineChartViewModel) {
        let oldDataPoints = oldViewModel.dataSets.first!.segments.first!.dataPoints
        let newDataPoints = newViewModel.dataSets.first!.segments.first!.dataPoints
        
        let animationStartPath = createAnimationStartPath(
            oldDataPoints: oldDataPoints,
            newDataPoints: newDataPoints,
            oldViewModel: oldViewModel
        )
        
        let animationEndPath = createAnimationEndPath(
            oldDataPoints: oldDataPoints,
            newDataPoints: newDataPoints,
            newViewModel: newViewModel
        )
        
        let animation = CABasicAnimation(keyPath: Constants.animationKeyPath)
        animation.delegate = self
        animation.timingFunction = animationTimingFunction
        animation.duration = Constants.animationDuration
        animation.isRemovedOnCompletion = true
        animation.fromValue = animationStartPath
        animation.toValue = animationEndPath
        
        shapeLayer.removeAnimation(forKey: Constants.animationKey)
        shapeLayer.add(animation, forKey: Constants.animationKey)
        shapeLayer.path = path(from: newDataPoints, with: newViewModel)
    }
    
    private func createAnimationStartPath(oldDataPoints: [LineChartDataPoint],
                                          newDataPoints: [LineChartDataPoint],
                                          oldViewModel: LineChartViewModel) -> CGPath {
        
        if shapeLayer.animation(forKey: Constants.animationKey) != nil,
            let visualPath = shapeLayer.presentation()?.value(forKeyPath: Constants.animationKeyPath) {
                return visualPath as! CGPath
        }
        
        let animationStartPoints = createAnimationStartPoints(
            from: oldDataPoints,
            target: newDataPoints
        )
        
        let animationStartPath = path(from: animationStartPoints, with: oldViewModel)
        
        return animationStartPath
    }
    
    private func createAnimationEndPath(oldDataPoints: [LineChartDataPoint],
                                        newDataPoints: [LineChartDataPoint],
                                        newViewModel: LineChartViewModel) -> CGPath {
        
        let animationEndPoints = createAnimationEndPoints(
            from: oldDataPoints,
            target: newDataPoints
        )
        
        let animationEndPath = path(from: animationEndPoints, with: newViewModel)
        
        return animationEndPath
    }
    
    private func createAnimationStartPoints(from source: [LineChartDataPoint], target: [LineChartDataPoint]) -> [LineChartDataPoint] {
        guard source.count < target.count else {
            return source
        }
        
        let normalizedSourcePoints = source.map { normalize($0, in: source) }
        let normalizedTargetPoints = target.map { normalize($0, in: target) }
        
        return normalizedTargetPoints
            .map {
                point(closestTo: $0, in: normalizedSourcePoints)
            }
            .map {
                denormalize($0, in: source)
            }
    }
    
    private func createAnimationEndPoints(from source: [LineChartDataPoint], target: [LineChartDataPoint]) -> [LineChartDataPoint] {
        guard source.count > target.count else {
            return target
        }
        
        let normalizedSourcePoints = source.map { normalize($0, in: source) }
        let normalizedTargetPoints = target.map { normalize($0, in: target) }
        
        return normalizedSourcePoints
            .map {
                point(closestTo: $0, in: normalizedTargetPoints)
            }
            .map {
                denormalize($0, in: target)
            }
    }
    
    private func normalize(_ point: LineChartDataPoint, in collection: [LineChartDataPoint]) -> LineChartDataPoint {
        let start = collection.first!.x
        let end = collection.last!.x
        let range = end - start
        return LineChartDataPoint(x: (point.x - start) / range, y: point.y)
    }
    
    private func denormalize(_ point: LineChartDataPoint, in collection: [LineChartDataPoint]) -> LineChartDataPoint {
        let start = collection.first!.x
        let end = collection.last!.x
        let range = end - start
        return LineChartDataPoint(x: start + point.x * range, y: point.y)
    }
    
    private func point(closestTo point: LineChartDataPoint, in collection: [LineChartDataPoint]) -> LineChartDataPoint {
        let (left, right) = points(surrounding: point, in: collection)
        return (point.x - left.x) < (right.x - point.x) ? left : right
    }
    
    private func points(surrounding point: LineChartDataPoint, in collection: [LineChartDataPoint]) -> (left: LineChartDataPoint, right: LineChartDataPoint) {
        for i in 0..<collection.count where collection[i].x > point.x {
            return (left: collection[i - 1], right: collection[i])
        }
        
        let left = collection[collection.endIndex - 2]
        let right = collection[collection.endIndex - 1]
        
        return (left: left, right: right)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        shapeLayer.removeAnimation(forKey: Constants.animationKey)
    }
}

// MARK: - Constants

extension LineChartView {
    
    struct Constants {
        static let animationKey: String = "lineChartPath"
        static let animationKeyPath: String = "path"
        static let animationDuration: TimeInterval = 0.3
    }
}
