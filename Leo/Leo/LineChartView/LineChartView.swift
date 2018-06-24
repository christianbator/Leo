//
//  LineChartView.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

public class LineChartView: UIView {
    
    // MARK: - Public
    
    let insets: UIEdgeInsets
    let animationDuration: TimeInterval
    let animationTimingFunction: CAMediaTimingFunction
    let deselectedSegmentAlpha: CGFloat
    private(set) var currentViewModel: LineChartViewModel?
    
    // MARK: - Private
    
    private let shapeLayer: CAShapeLayer
    private var selectedShapeLayer: CAShapeLayer?
    private var selectionState: SelectionState = .none
    
    // MARK: - Initialization
    
    public init(insets: UIEdgeInsets = .zero,
                animationDuration: TimeInterval = defaultAnimationDuration,
                animationTimingFunction: CAMediaTimingFunction = defaultAnimationTimingFunction,
                deselectedSegmentAlpha: CGFloat = defaultDeselectedSegmentAlpha) {
        
        self.insets = insets
        self.animationDuration = animationDuration
        self.animationTimingFunction = animationTimingFunction
        self.deselectedSegmentAlpha = deselectedSegmentAlpha
        
        shapeLayer = CAShapeLayer.createLineChartLayer()

        super.init(frame: .zero)
        
        layer.addSublayer(shapeLayer)
        isMultipleTouchEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderColor = Style.white.withAlphaComponent(0.4).cgColor
        layer.borderWidth = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Interface

extension LineChartView {
    
    public func configure(with viewModel: LineChartViewModel?) {
        resetSelection()
        
        guard let viewModel = viewModel else {
            clearLayers()
            currentViewModel = nil
            return
        }
        
        style(shapeLayer, with: viewModel.lineStyle)
        
        if let currentViewModel = currentViewModel {
            animate(from: currentViewModel, to: viewModel)
        } else {
            shapeLayer.path = compoundPath(from: viewModel.dataSet.segments, with: viewModel).cgPath
        }
        
        currentViewModel = viewModel
    }
}

// MARK: - Styling

extension LineChartView {
    
    private func style(_ shapeLayer: CAShapeLayer, with lineStyle: LineStyle) {
        shapeLayer.strokeColor = lineStyle.lineColor.cgColor
        shapeLayer.lineWidth = lineStyle.lineWidth
    }
}

// MARK: - Path Creation

extension LineChartView {
    
    private func compoundPath(from segments: [LineChartDataSegment], with viewModel: LineChartViewModel) -> UIBezierPath {
        let compoundPath = UIBezierPath()
        
        let paths = segments.map { segment in
            path(from: segment.dataPoints, with: viewModel)
        }

        for (index, path) in paths.enumerated() {
            let nextIndex = index.advanced(by: 1)
            
            if let nextSegment = segments[safe: nextIndex],
                let nextPathStart = firstVisualPoint(from: nextSegment, with: viewModel) {
                
                path.addLine(to: nextPathStart)
            }
            
            compoundPath.append(path)
        }
            
        return compoundPath
    }
    
    private func path(from points: [LineChartDataPoint], with viewModel: LineChartViewModel) -> UIBezierPath {
        let path = UIBezierPath()
        
        let visualPoints = points.map { point in
            visualPoint(from: point, with: viewModel)
        }
        
        guard let firstVisualPoint = visualPoints.first else {
            return path
        }

        path.move(to: firstVisualPoint)
        for visualPoint in visualPoints.dropFirst() {
            path.addLine(to: visualPoint)
        }

        return path
    }
    
    private func firstVisualPoint(from segment: LineChartDataSegment, with viewModel: LineChartViewModel) -> CGPoint? {
        guard let firstDataPoint = segment.dataPoints.first else {
            return nil
        }
        
        return visualPoint(from: firstDataPoint, with: viewModel)
    }
}

// MARK: - Point Transformation

extension LineChartView {
    
    private func visualPoint(from dataPoint: LineChartDataPoint, with viewModel: LineChartViewModel) -> CGPoint {
        let scaledX: CGFloat = {
            // If this is the only data point, draw it at the beginning of the chart
            guard viewModel.xRange > 0 else {
                return 0
            }
            
            return CGFloat((dataPoint.x - viewModel.minX) / viewModel.xRange)
        }()
        
        let adjustedX = insetBounds.minX + scaledX * insetBounds.width
        
        let scaledY: CGFloat = {
            // If this is the only data point, draw it in the vertical center
            guard viewModel.yRange > 0 else {
                return 0.5
            }
            
            return CGFloat((dataPoint.y - viewModel.minY) / viewModel.yRange)
        }()
        
        let adjustedY = insetBounds.minY + (insetBounds.height - scaledY * insetBounds.height)
        
        return CGPoint(x: adjustedX, y: adjustedY)
    }
    
    private func dataPoint(from visualPoint: CGPoint, with viewModel: LineChartViewModel) -> LineChartDataPoint {
        let xPercentage = visualPoint.x / insetBounds.width
        let x = viewModel.minX + xPercentage * viewModel.xRange
        
        let yPercentage = (insetBounds.height - visualPoint.y) / insetBounds.height
        let y = viewModel.minY + yPercentage * viewModel.yRange
        
        return LineChartDataPoint(x: x, y: y)
    }
    
    private var insetBounds: CGRect {
        return UIEdgeInsetsInsetRect(bounds, insets)
    }
}

// MARK: - Animation

extension LineChartView {
    
    private func animate(from oldViewModel: LineChartViewModel, to newViewModel: LineChartViewModel) {
        let oldDataPoints = oldViewModel.dataSet.allDataPoints
        let newDataPoints = newViewModel.dataSet.allDataPoints
        
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
        
        shapeLayer.path = compoundPath(from: newViewModel.dataSet.segments, with: newViewModel).cgPath
        
        shapeLayer.add(
            ShapeLayerPathAnimation(
                fromValue: animationStartPath.cgPath,
                toValue: animationEndPath.cgPath,
                duration: Constants.currentAnimationDuration,
                timingFunction: animationTimingFunction,
                delegate: self
            )
        )
    }
    
    private func createAnimationStartPath(oldDataPoints: [LineChartDataPoint],
                                          newDataPoints: [LineChartDataPoint],
                                          oldViewModel: LineChartViewModel) -> UIBezierPath {
        
        let animationStartPoints = createAnimationStartPoints(
            from: existingAnimationPoints(oldViewModel: oldViewModel) ?? oldDataPoints,
            target: newDataPoints
        )
        
        let animationStartPath = path(from: animationStartPoints, with: oldViewModel)
        
        return animationStartPath
    }
    
    private func createAnimationEndPath(oldDataPoints: [LineChartDataPoint],
                                        newDataPoints: [LineChartDataPoint],
                                        oldViewModel: LineChartViewModel,
                                        newViewModel: LineChartViewModel) -> UIBezierPath {
        
        let animationEndPoints = createAnimationEndPoints(
            from: existingAnimationPoints(oldViewModel: oldViewModel) ?? oldDataPoints,
            target: newDataPoints
        )
        
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
        guard let pathAnimation = shapeLayer.existingAnimation(ofType: ShapeLayerPathAnimation.self),
            let visualPathRawValue = shapeLayer.presentation()?.value(forKeyPath: type(of: pathAnimation).animationKeyPath) else {
                return nil
        }
        
        // Force cast since a conditional downcast from Any to CGPath always succeeds
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
}

// MARK: - CAAnimationDelegate

extension LineChartView: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }
        
        guard let animation = anim as? CustomBasicAnimation else {
            return
        }
        
        if let alphaAnimation = animation as? LayerAlphaAnimation, alphaAnimation.alphaValue == 1 {
            selectedShapeLayer?.removeFromSuperlayer()
            selectedShapeLayer = nil
        }
    }
}

// MARK: - Selection State

extension LineChartView {
    
    enum SelectionState {
        case none
        case single(touch: UITouch)
        case range(left: UITouch, right: UITouch)
    }
}

// MARK: - Touch Handling

extension LineChartView {
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard !touches.isEmpty else {
            return
        }
        
        let sortedTouches = touches.sorted(by: touchSorter)
        
        switch selectionState {
        case .none:
            if sortedTouches.count == 1 {
                selectionState = .single(touch: sortedTouches.first!)
            } else {
                selectionState = .range(left: sortedTouches.first!, right: sortedTouches[1])
            }
        case .single(let touch):
            let rangeTouches = ([touch, sortedTouches.first!]).sorted(by: touchSorter)
            selectionState = .range(left: rangeTouches.first!, right: rangeTouches[1])
        case .range:
            break
        }
        
        selectSegments(for: selectionState)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        switch selectionState {
        case .none:
            break
        case .single(let touch):
            if touches.contains(touch) {
                selectSegments(for: selectionState)
            }
        case .range(let left, let right):
            if touches.contains(left) || touches.contains(right) {
                let rangeTouches = [left, right].sorted(by: touchSorter)
                selectionState = .range(left: rangeTouches.first!, right: rangeTouches[1])
                selectSegments(for: selectionState)
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        handleFinishedTouches(touches)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        handleFinishedTouches(touches)
    }
    
    private func handleFinishedTouches(_ touches: Set<UITouch>) {
        switch selectionState {
        case .none:
            break
        case .single(let touch):
            if touches.contains(touch) {
                selectionState = .none
                selectSegments(for: selectionState)
            }
        case .range(let left, let right):
            switch (touches.contains(left), touches.contains(right)) {
            case (true, true):
                selectionState = .none
                selectSegments(for: selectionState)
            case (true, false):
                selectionState = .single(touch: right)
                selectSegments(for: selectionState)
            case (false, true):
                selectionState = .single(touch: left)
                selectSegments(for: selectionState)
            case (false, false):
                break
            }
        }
    }
}

// MARK: - Segment Selection

extension LineChartView {
    
    private func selectSegments(for selectionState: SelectionState) {
        guard let currentViewModel = currentViewModel else {
            return
        }
        
        let selectedSegments: [LineChartDataSegment] = {
            switch selectionState {
            case .none:
                return []
            case .single(let touch):
                let touchLocation = touch.location(in: self)
                let selectedSegmentIndex = segmentIndex(forTouchLocation: touchLocation, with: currentViewModel)
                return [currentViewModel.dataSet.segments[selectedSegmentIndex]]
            case .range(let left, let right):
                let leftLocation = left.location(in: self)
                let rightLocation = right.location(in: self)
                
                let leftSegmentIndex = segmentIndex(forTouchLocation: leftLocation, with: currentViewModel)
                let rightSegmentIndex = segmentIndex(forTouchLocation: rightLocation, with: currentViewModel)
                
                return Array(currentViewModel.dataSet.segments[leftSegmentIndex...rightSegmentIndex])
            }
        }()
        
        guard !selectedSegments.isEmpty else {
            deselectAllSegments()
            return
        }
        
        let selectedShapeLayer = self.selectedShapeLayer ?? CAShapeLayer.createLineChartLayer()
        selectedShapeLayer.path = compoundPath(from: selectedSegments, with: currentViewModel).cgPath
        
        shapeLayer.add(
            LayerAlphaAnimation(
                toValue: deselectedSegmentAlpha,
                duration: animationDuration,
                timingFunction: animationTimingFunction,
                delegate: self
            )
        )
        
        if self.selectedShapeLayer == nil {
            style(selectedShapeLayer, with: currentViewModel.lineStyle)
            layer.addSublayer(selectedShapeLayer)
            self.selectedShapeLayer = selectedShapeLayer
        }
    }
    
    private func deselectAllSegments() {
        shapeLayer.add(
            LayerAlphaAnimation(
                toValue: 1,
                duration: animationDuration,
                timingFunction: animationTimingFunction,
                delegate: self
            )
        )
    }
}

// MARK: - Interaction Utilities

extension LineChartView {
    
    private func segmentIndex(forTouchLocation touchLocation: CGPoint, with viewModel: LineChartViewModel) -> Int {
        let selectedDataPoint = self.selectedDataPoint(forTouchLocation: touchLocation, with: viewModel)
        
        let segmentIndex = viewModel.dataSet.segments.reversed().enumerated()
            .first(where: { (_, segment) in
                return selectedDataPoint.x >= segment.dataPoints.first!.x
            })
            .map { (offset, _) in
                return (viewModel.dataSet.segments.count - 1) - offset
        }
        
        return segmentIndex ?? 0
    }
    
    private func selectedDataPoint(forTouchLocation touchLocation: CGPoint, with viewModel: LineChartViewModel) -> LineChartDataPoint {
        let touchLocationDataPoint = dataPoint(from: touchLocation, with: viewModel)
        
        var closestPoint = viewModel.dataSet.allDataPoints.first!
        
        for point in viewModel.dataSet.allDataPoints.dropFirst()
            where abs(touchLocationDataPoint.x - point.x) < abs(touchLocationDataPoint.x - closestPoint.x) {
                closestPoint = point
        }
        
        return closestPoint
    }
    
    private func touchSorter(firstTouch: UITouch, secondTouch: UITouch) -> Bool {
        return firstTouch.location(in: self).x < secondTouch.location(in: self).x
    }
}

// MARK: - Reset

extension LineChartView {
    
    private func resetSelection() {
        selectionState = .none
        selectSegments(for: selectionState)
    }
    
    private func clearLayers() {
        shapeLayer.path = nil
        
        selectedShapeLayer?.removeFromSuperlayer()
        selectedShapeLayer = nil
    }
}

// MARK: - Defaults

extension LineChartView {
    
    public static let defaultAnimationDuration: TimeInterval = 0.3
    public static let defaultAnimationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    public static let defaultDeselectedSegmentAlpha: CGFloat = 0.3
}

extension LineChartView {
    
    struct Constants {
        
        // MARK: - Test
        
        static let minAnimationDuration: TimeInterval = 0.3
        static let maxAnimationDuration: TimeInterval = 5
        static var currentAnimationDuration: TimeInterval = 0.3
        
        static var animationDurationPercentage: Float {
            return Float((currentAnimationDuration - minAnimationDuration) / (maxAnimationDuration - minAnimationDuration))
        }
        
        static func animationDuration(withPercentage percentage: Float) -> TimeInterval {
            return minAnimationDuration + TimeInterval(percentage) * (maxAnimationDuration - minAnimationDuration)
        }
    }
}
