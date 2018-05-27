//
//  CGFloatConvertible.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import CoreGraphics

public protocol CGFloatConvertible {
    var cgFloatValue: CGFloat { get }
}

extension CGFloat: CGFloatConvertible {
    
    public var cgFloatValue: CGFloat {
        return self
    }
}
