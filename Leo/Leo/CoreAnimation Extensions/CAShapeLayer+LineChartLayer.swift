//
//  CAShapeLayer+LineChartLayer.swift
//  Leo
//
//  Created by Christian Bator on 6/22/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

extension CAShapeLayer {
    
    static func createLineChartLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineCapRound
        return shapeLayer
    }
}
