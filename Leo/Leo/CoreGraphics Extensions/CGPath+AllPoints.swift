//
//  CGPath+AllPoints.swift
//  Leo
//
//  Created by Christian Bator on 6/22/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import CoreGraphics

extension CGPath {
    
    var allPoints: [CGPoint] {
        var points = [CGPoint]()
        
        forEach { pathElement in
            points.append(pathElement.points.pointee)
        }
        
        return points
    }
    
    private func forEach(_ block: @escaping (CGPathElement) -> Void) {
        var info = block
        apply(info: &info) { (infoPointer, elementPointer) in
            let opaqueInfoPointer = OpaquePointer(infoPointer!)
            let body = UnsafeMutablePointer<(CGPathElement) -> Void>(opaqueInfoPointer).pointee
            body(elementPointer.pointee)
        }
    }
}
