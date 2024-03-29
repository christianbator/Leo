//
//  LineStyle.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

public struct LineStyle: Equatable {
    
    public let lineWidth: CGFloat
    public let lineColor: UIColor
    public let lineDashPattern: [CGFloat]?
    
    public init(lineWidth: CGFloat, lineColor: UIColor, lineDashPattern: [CGFloat]? = nil) {
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.lineDashPattern = lineDashPattern
    }
}
