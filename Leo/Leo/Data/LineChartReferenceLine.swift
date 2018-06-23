//
//  LineChartReferenceLine.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import CoreGraphics

public struct LineChartReferenceLine: Equatable {
    
    public let y: CGFloat
    
    init(y: CGFloat) {
        self.y = y
    }
}
