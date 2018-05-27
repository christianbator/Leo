//
//  Path.swift
//  Leo
//
//  Created by Christian Bator on 5/25/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class Path {
    
    
    
    func path(from points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: points.first!)
        
        for point in points {
            path.addLine(to: point)
        }
        
        return path
    }
    
}

func createAnimationStartPoints(from source: [CGPoint], target: [CGPoint]) -> [CGPoint] {
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

func createAnimationFinishPoints(from source: [CGPoint], target: [CGPoint]) -> [CGPoint] {
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

func normalize(_ point: CGPoint, in collection: [CGPoint]) -> CGPoint {
    let start = collection.first!.x
    let end = collection.last!.x
    let range = end - start
    return CGPoint(x: (point.x - start) / range, y: point.y)
}

func denormalize(_ point: CGPoint, in collection: [CGPoint]) -> CGPoint {
    let start = collection.first!.x
    let end = collection.last!.x
    let range = end - start
    return CGPoint(x: start + point.x * range, y: point.y)
}

func point(closestTo point: CGPoint, in collection: [CGPoint]) -> CGPoint {
    let (left, right) = points(surrounding: point, in: collection)
    return (point.x - left.x) < (right.x - point.x) ? left : right
}

func points(surrounding point: CGPoint, in collection: [CGPoint]) -> (left: CGPoint, right: CGPoint) {
    for i in 0..<collection.count where collection[i].x > point.x {
        return (left: collection[i - 1], right: collection[i])
    }
    
    let left = collection[collection.endIndex - 2]
    let right = collection[collection.endIndex - 1]
    
    return (left: left, right: right)
}
