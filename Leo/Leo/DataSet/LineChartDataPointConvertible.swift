//
//  LineChartDataPointConvertible.swift
//  Watch Extension
//
//  Created by Christian Bator on 5/18/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import Foundation

public protocol LineChartDataPointConvertible {
    var lineChartDataPoint: LineChartDataPoint { get }
}

extension LineChartDataPoint: LineChartDataPointConvertible {
    
    public var lineChartDataPoint: LineChartDataPoint {
        return self
    }
}
