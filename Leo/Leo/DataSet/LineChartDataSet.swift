//
//  LineChartDataSet.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import Foundation

public struct LineChartDataSet: Equatable {
    
    public let segments: [LineChartDataSegment]
}

// MARK: - Computed Properties

extension LineChartDataSet {
    
    public var isEmpty: Bool {
        return segments.reduce(true) { $0 && $1.isEmpty }
    }
}
