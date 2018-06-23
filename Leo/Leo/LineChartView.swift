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
    
    // MARK: - Public
    
    let insets: UIEdgeInsets
    let animationDuration: TimeInterval
    let animationTimingFunction: CAMediaTimingFunction
    private(set) var currentViewModel: LineChartViewModel?
    
    // MARK: - Private
    
    private let shapeLayer: CAShapeLayer
    
    // MARK: - Initialization
    
    public init(insets: UIEdgeInsets = .zero,
                animationDuration: TimeInterval = defaultAnimationDuration,
                animationTimingFunction: CAMediaTimingFunction = defaultAnimationTimingFunction) {
        
        self.insets = insets
        self.animationDuration = animationDuration
        self.animationTimingFunction = animationTimingFunction
        
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineCapRound

        super.init(frame: .zero)
        
        layer.addSublayer(shapeLayer)
        translatesAutoresizingMaskIntoConstraints = false
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Interaction

extension LineChartView {
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began,
             .changed:
//            let locationInSelf = gestureRecognizer.location(in: self)
            shapeLayer.strokeColor = currentViewModel?.dataSet.segments.first!.lineStyle.lineColor.withAlphaComponent(0.3).cgColor
        case .ended,
             .cancelled:
            shapeLayer.strokeColor = currentViewModel?.dataSet.segments.first!.lineStyle.lineColor.cgColor
        case .possible,
             .failed:
            break
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shapeLayer.strokeColor = currentViewModel?.dataSet.segments.first!.lineStyle.lineColor.withAlphaComponent(0.3).cgColor
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        shapeLayer.strokeColor = currentViewModel?.dataSet.segments.first!.lineStyle.lineColor.cgColor
    }
}

// MARK: - Public Interface

extension LineChartView {
    
    public func configure(with viewModel: LineChartViewModel) {
        shapeLayer.strokeColor = viewModel.dataSet.segments.first!.lineStyle.lineColor.cgColor
        shapeLayer.lineWidth = viewModel.dataSet.segments.first!.lineStyle.lineWidth
        
        if let currentViewModel = currentViewModel {
            animate(from: currentViewModel, to: viewModel)
        } else {
            shapeLayer.path = path(
                from: viewModel.dataSet.segments.first!.dataPoints,
                with: viewModel
            )
        }
        
        currentViewModel = viewModel
    }
}

// MARK: - Animation

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
    
    private func dataPoint(from visualPoint: CGPoint, with viewModel: LineChartViewModel) -> LineChartDataPoint {
        let xPercentage = visualPoint.x / bounds.width
        let x = viewModel.minX + xPercentage * viewModel.xRange
        
        let yPercentage = (bounds.height - visualPoint.y) / bounds.height
        let y = viewModel.minY + yPercentage * viewModel.yRange
        
        return LineChartDataPoint(x: x, y: y)
    }
}

// MARK: - Animation

extension LineChartView: CAAnimationDelegate {
    
    private func animate(from oldViewModel: LineChartViewModel, to newViewModel: LineChartViewModel) {
        let oldDataPoints = oldViewModel.dataSet.segments.flatMap { $0.dataPoints }
        let newDataPoints = newViewModel.dataSet.segments.flatMap { $0.dataPoints }
        
        let animationStartPath = createAnimationStartPath(
            oldDataPoints: oldDataPoints,
            newDataPoints: newDataPoints,
            oldViewModel: oldViewModel
        )
        
        let animationEndPath = createAnimationEndPath(
            oldDataPoints: oldDataPoints,
            newDataPoints: newDataPoints,
            oldViewModel: oldViewModel,
            newViewModel: newViewModel
        )
        
        let animation = CABasicAnimation(keyPath: Constants.animationKeyPath)
        animation.delegate = self
        animation.timingFunction = animationTimingFunction
        animation.duration = Constants.currentAnimationDuration
        animation.isRemovedOnCompletion = true
        animation.fromValue = animationStartPath
        animation.toValue = animationEndPath
        
        shapeLayer.path = path(from: newDataPoints, with: newViewModel)
        shapeLayer.removeAnimation(forKey: Constants.animationKey)
        shapeLayer.add(animation, forKey: Constants.animationKey)
    }
    
    private func createAnimationStartPath(oldDataPoints: [LineChartDataPoint],
                                          newDataPoints: [LineChartDataPoint],
                                          oldViewModel: LineChartViewModel) -> CGPath {
        
        let animationStartPoints = createAnimationStartPoints(
            from: existingAnimationPoints(oldViewModel: oldViewModel) ?? oldDataPoints,
            target: newDataPoints
        )
        
        print("From: \(animationStartPoints.count)")
        
        let animationStartPath = path(from: animationStartPoints, with: oldViewModel)
        
        return animationStartPath
    }
    
    private func createAnimationEndPath(oldDataPoints: [LineChartDataPoint],
                                        newDataPoints: [LineChartDataPoint],
                                        oldViewModel: LineChartViewModel,
                                        newViewModel: LineChartViewModel) -> CGPath {
        
        let animationEndPoints = createAnimationEndPoints(
            from: existingAnimationPoints(oldViewModel: oldViewModel) ?? oldDataPoints,
            target: newDataPoints
        )
        
        print("To: \(animationEndPoints.count)")
        
        let animationEndPath = path(from: animationEndPoints, with: newViewModel)
        
        return animationEndPath
    }
    
    private func createAnimationStartPoints(from source: [LineChartDataPoint], target: [LineChartDataPoint]) -> [LineChartDataPoint] {
        guard source.count < target.count else {
            return source
        }
        
        let normalizedSourcePoints = source.map { sourcePoint in
            normalize(sourcePoint, in: source)
        }
        
        let normalizedTargetPoints = target.map { targetPoint in
            normalize(targetPoint, in: target)
        }
        
        // Map each source point to a target point
        // For all left over target points, interpolate between two closest source points
        
        var result = [LineChartDataPoint]()
        var unmappedTargetPoints = Set(normalizedTargetPoints)
        
        for normalizedSourcePoint in normalizedSourcePoints {
            let mappedTargetPoint = point(closestTo: normalizedSourcePoint, in: normalizedTargetPoints)
            unmappedTargetPoints.remove(mappedTargetPoint)
            result.append(normalizedSourcePoint)
        }
        
        for unmappedTargetPoint in unmappedTargetPoints {
            let surroundingPoints = points(surrounding: unmappedTargetPoint, in: normalizedSourcePoints)
            let interpolatedSourcePoint = interpolate(normalized: unmappedTargetPoint, between: surroundingPoints.left, and: surroundingPoints.right)
            result.append(interpolatedSourcePoint)
        }
        
        return result
            .sorted { $0.x < $1.x }
            .map { normalizedSourcePoint in
                denormalize(normalizedSourcePoint, in: source)
            }
    }
    
    private func createAnimationEndPoints(from source: [LineChartDataPoint], target: [LineChartDataPoint]) -> [LineChartDataPoint] {
        guard source.count > target.count else {
            return target
        }
        
        let normalizedSourcePoints = source.map { sourcePoint in
            normalize(sourcePoint, in: source)
        }
        
        let normalizedTargetPoints = target.map { targetPoint in
            normalize(targetPoint, in: target)
        }
        
        // For each target point, find closest in source to map
        // For unmapped source points, map to closest target point
        
        var result = normalizedTargetPoints
        var unmappedSourcePoints = Set(normalizedSourcePoints)
        
        for normalizedTargetPoint in normalizedTargetPoints {
            let mappedSourcePoint = point(closestTo: normalizedTargetPoint, in: normalizedSourcePoints)
            unmappedSourcePoints.remove(mappedSourcePoint)
        }
        
        for unmappedSourcePoint in unmappedSourcePoints {
            let closestTargetPoint = point(closestTo: unmappedSourcePoint, in: normalizedTargetPoints)
            result.append(closestTargetPoint)
        }
        
        return result
            .sorted { $0.x < $1.x }
            .map { normalizedTargetPoint in
                denormalize(normalizedTargetPoint, in: target)
            }
    }
    
    private func existingAnimationPoints(oldViewModel: LineChartViewModel) -> [LineChartDataPoint]? {
        guard shapeLayer.animation(forKey: Constants.animationKey) != nil,
            let visualPathRawValue = shapeLayer.presentation()?.value(forKeyPath: Constants.animationKeyPath) else {
                return nil
        }
        
        // Force unwrap since a conditional downcast from Any to CGPath always succeeds
        let visualPath = visualPathRawValue as! CGPath
        
        let dataPoints = visualPath.allPoints.map { visualPoint in
            dataPoint(from: visualPoint, with: oldViewModel)
        }
        
        return dataPoints
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
    
    private func interpolate(normalized point: LineChartDataPoint, between left: LineChartDataPoint, and right: LineChartDataPoint) -> LineChartDataPoint {
        let xRange = right.x - left.x
        let yRange = right.y - left.y
        let percentage = (point.x - left.x) / xRange
        
        let interpolatedX = left.x + percentage * xRange
        let interpolatedY = left.y + percentage * yRange
        
        return LineChartDataPoint(x: interpolatedX, y: interpolatedY)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }
        
        shapeLayer.removeAnimation(forKey: Constants.animationKey)
    }
}

// MARK: - Defaults

extension LineChartView {
    public static let defaultAnimationDuration: TimeInterval = 0.3
    public static let defaultAnimationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
}

extension LineChartView {
    
    struct Constants {
        static let animationKey = "lineChartPath"
        static let animationKeyPath = "path"
        
        // MARK: - Test
        
        static let minAnimationDuration: TimeInterval = 0.3
        static let maxAnimationDuration: TimeInterval = 5
        static var currentAnimationDuration: TimeInterval = 3
        
        static var animationDurationPercentage: Float {
            return Float((currentAnimationDuration - minAnimationDuration) / (maxAnimationDuration - minAnimationDuration))
        }
        
        static func animationDuration(withPercentage percentage: Float) -> TimeInterval {
            return minAnimationDuration + TimeInterval(percentage) * (maxAnimationDuration - minAnimationDuration)
        }
    }
}
