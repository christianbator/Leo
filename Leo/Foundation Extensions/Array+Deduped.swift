//
//  Array+Deduped.swift
//  Leo
//
//  Created by Christian Bator on 5/25/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    func deduped() -> [Element] {
        var deduped = [Element]()
        var set = Set<Element>()
        
        for item in self where !set.contains(item) {
            deduped.append(item)
            set.insert(item)
        }
        
        return deduped
    }
}
