//
//  LineChartDataPoint.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import CoreGraphics

public struct LineChartDataPoint: Equatable {
    
    public let x: CGFloat
    public let y: CGFloat
    
    public init(x: CGFloatConvertible, y: CGFloatConvertible) {
        self.x = x.cgFloatValue
        self.y = y.cgFloatValue
    }
}

extension LineChartDataPoint: CGPointConvertible {
    
    public var cgPointValue: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

extension LineChartDataPoint: Hashable {
    
    public var hashValue: Int {
        return cgPointValue.hashValue
    }
}
