//
//  CGPointConvertible.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import CoreGraphics

public protocol CGPointConvertible {
    var cgPointValue: CGPoint { get }
}

extension CGPoint: CGPointConvertible {
    
    public var cgPointValue: CGPoint {
        return self
    }
}
