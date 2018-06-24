//
//  Style.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class Style {
    
    static let white: UIColor = .white
    static let gray: UIColor = .lightGray
    static let backgroundColor: UIColor = UIColor(hue: 0.57, saturation: 0.8, brightness: 0.08, alpha: 1)
    static let textColor: UIColor = backgroundColor
    static let secondaryTextColor: UIColor = textColor.withAlphaComponent(0.6)
    static let brandColor: UIColor = UIColor(hue: 0.45, saturation: 0.84, brightness: 0.81, alpha: 1)
    static let negativeColor: UIColor = UIColor(hue: 0.03, saturation: 0.8, brightness: 0.96, alpha: 1)
    static let nonNegativeColor: UIColor = UIColor(hue: 0.45, saturation: 0.84, brightness: 0.81, alpha: 1)
}
