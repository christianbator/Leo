//
//  CustomAnimations.swift
//  Leo
//
//  Created by Christian Bator on 6/22/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

// MARK: - CustomBasicAnimation

class CustomBasicAnimation: CABasicAnimation {
    
    class var animationKey: String {
        fatalError("CustomBasicAnimations must override `animationKey`")
    }
    
    class var animationKeyPath: String {
        fatalError("CustomBasicAnimations must override `animationKeyPath`")
    }
    
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

// MARK: - ShapeLayerPathAnimation

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

// MARK: - LayerAlphaAnimation

final class LayerAlphaAnimation: CustomBasicAnimation {
    
    override static var animationKey: String {
        return "fade"
    }
    
    override static var animationKeyPath: String {
        return "opacity"
    }
    
    var alphaValue: CGFloat {
        return toValue as! CGFloat
    }
    
    override init() {
        super.init()
    }
    
    init(fromValue: CGFloat? = nil,
         toValue: CGFloat,
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

// MARK: - CALayer+CustomBasicAnimation

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
