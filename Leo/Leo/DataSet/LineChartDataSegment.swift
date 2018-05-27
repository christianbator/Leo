//
//  LineChartDataSegment.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import Foundation

public struct LineChartDataSegment: Equatable {
    
    public let dataPoints: [LineChartDataPoint]
    public let lineStyle: LineStyle
    
    public init(dataPoints: [LineChartDataPoint], lineStyle: LineStyle) {
        self.dataPoints = dataPoints
        self.lineStyle = lineStyle
    }
}

// MARK: - Computed Properties

extension LineChartDataSegment {
    
    public var isEmpty: Bool {
        return dataPoints.isEmpty
    }
}
