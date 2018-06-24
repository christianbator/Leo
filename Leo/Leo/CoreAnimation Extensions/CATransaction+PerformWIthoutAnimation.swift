//
//  CATransaction+PerformWIthoutAnimation.swift
//  Leo
//
//  Created by Christian Bator on 6/24/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

extension CATransaction {
    
    static func performWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }
}
