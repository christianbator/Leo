# Leo
Smooth line animations in Swift for iOS.

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)

## Background
Animations between line charts are often unsatisfying. Generally you'll see an opacity transition or none at all.

To do specific point-to-point animations between line chart data sets, you need to move each existing data point to a new location consistent with the new data set. This is simple enough with data sets containing the same number of data points - just move each existing data point to its new position.

But how do you do this when the data sets have a different number of data points? A trivial solution might end up making the line appear as if it's expanding or contracting on one end to accommodate new points, but we can do better. 

## Idea
The goal is get interruptible, point-to-point animations between line chart data sets regardless of the difference in number of data points.

To do this, I think we should imagine a line that we can grow, shrink, and bend into as many segments as we want at any given time.

A simple way to think about it is given the two interesting cases, either:
1. The target has more data points
2. The source has more data points

First we normalize all the data points as a percentage of their respective domain. So each `x` data point gets transformed into a point in the range `[0,1]`.

Take the first case: the target we're animating _to_ contains more data points than we currently have. So we can map each existing point to its closest normalized point in the target, but we're left with target points along the line that have to appear from somewhere.

So all we do is find the surrounding points in the source data set, "bend" the line by inserting a new data point between them, and repeat for all the target data points that don't have a matching source point.

```swift
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
```

We're then left with two data sets that have the same number of points, each target point mapped to its closest x-value relative in the source data set. Now during animation, no points will "cross" each other or appear out of nowhere.

The resulting API looks like this, and the interesting part of the implementation is in `LineChartView.swift`: 

```swift
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

```

## Demo
You can see here the example app running in a simulator. It loads up various data points (1D, 3M, All Time) and animates between them. The slider controls the animation length to allow one to inspect the transitioning points.

![alt tag](/Resources/Animation.gif)
