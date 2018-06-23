//
//  CustomBasicAnimation.swift
//  Leo
//
//  Created by Christian Bator on 6/22/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class CustomBasicAnimation: CABasicAnimation {
    
    class var animationKey: String {
        fatalError("CustomBasicAnimations must override `animationKey`")
    }
    
    class var animationKeyPath: String {
        fatalError("CustomBasicAnimations must override `animationKeyPath`")
    }
    
    // animation(forKey:) invokes init() - without overriding it here, Leo will crash
    override init() {
        super.init()
    }
    
    init(fromValue: Any?,
         toValue: Any,
         duration: TimeInterval,
         timingFunction: CAMediaTimingFunction,
         delegate: CAAnimationDelegate) {
        
        super.init()
        self.keyPath = type(of: self).animationKeyPath
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = timingFunction
        self.isRemovedOnCompletion = true
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
