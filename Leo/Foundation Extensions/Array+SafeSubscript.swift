//
//  Array+SafeSubscript.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import Foundation

extension Array {
    
    public subscript(safe index: Int) -> Element? {
        get {
            guard index >= startIndex && index < endIndex else {
                return nil
            }
            
            return self[index]
        }
    }
}
