//
//  CALayer+CustomBasicAnimation.swift
//  Leo
//
//  Created by Christian Bator on 6/23/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

extension CALayer {
    
    func add(_ animation: CustomBasicAnimation) {
        let animationKey = type(of: animation).animationKey
        removeAnimation(forKey: animationKey)
        setValue(animation.toValue, forKeyPath: type(of: animation).animationKeyPath)
        add(animation, forKey: animationKey)
    }
    
    func existingAnimation<T: CustomBasicAnimation>(ofType type: T.Type) -> T? {
        return animation(forKey: type.animationKey) as? T
    }
}
