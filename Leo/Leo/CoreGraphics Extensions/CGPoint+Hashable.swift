//
//  CGPoint+Hashable.swift
//  Leo
//
//  Created by Christian Bator on 5/25/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import CoreGraphics

extension CGPoint: Hashable {
    
    public var hashValue: Int {
        let shiftAmount = MemoryLayout<Int>.size * 8 / 2
        let choppedX = x.hashValue >> shiftAmount
        let choppedY = y.hashValue >> shiftAmount
        return (choppedX << shiftAmount) | choppedY
    }
}
