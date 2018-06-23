//
//  ShapeLayerPathAnimation.swift
//  Leo
//
//  Created by Christian Bator on 6/23/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

final class ShapeLayerPathAnimation: CustomBasicAnimation {
    
    override static var animationKey: String {
        return "path"
    }
    
    override static var animationKeyPath: String {
        return "path"
    }
    
    var pathValue: CGPath {
        return toValue as! CGPath
    }
    
    // animation(forKey:) invokes init() - without overriding it here, Leo will crash
    override init() {
        super.init()
    }
    
    init(fromValue: CGPath? = nil,
         toValue: CGPath,
         duration: TimeInterval,
         timingFunction: CAMediaTimingFunction,
         delegate: CAAnimationDelegate) {
        
        super.init(
            fromValue: fromValue,
            toValue: toValue,
            duration: duration,
            timingFunction: timingFunction,
            delegate: delegate
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
