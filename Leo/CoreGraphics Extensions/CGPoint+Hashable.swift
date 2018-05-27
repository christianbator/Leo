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
        return (x.hashValue << MemoryLayout<CGFloat>.size) ^ y.hashValue
    }
}
