//
//  LineChartViewModel.swift
//  Watch Extension
//
//  Created by Christian Bator on 5/17/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

public struct LineChartViewModel: Equatable {
    
    public let minX: CGFloat
    public let maxX: CGFloat
    
    public let minY: CGFloat
    public let maxY: CGFloat
    
    public let styledDataSet: StyledLineChartDataSet
    public let styledReferenceLine: StyledLineChartReferenceLine?
    
    public init(minX: CGFloat? = nil,
                maxX: CGFloat? = nil,
                minY: CGFloat? = nil,
                maxY: CGFloat? = nil,
                styledDataSet: StyledLineChartDataSet,
                styledReferenceLine: StyledLineChartReferenceLine? = nil) {
     
        let allDataPoints = styledDataSet.dataSet.segments.flatMap { $0.dataPoints }
        
        let sortedByXDataPoints = allDataPoints.sorted { $0.x < $1.x }
        let sortedByYDataPoints = allDataPoints.sorted { $0.y < $1.y }
        
        self.minX = minX ?? sortedByXDataPoints.first?.x ?? 0
        self.maxX = maxX ?? sortedByXDataPoints.last?.x ?? 0
        
        self.minY = minY ?? sortedByYDataPoints.first?.y ?? 0
        self.maxY = maxY ?? sortedByYDataPoints.last?.y ?? 0
        
        self.styledDataSet = styledDataSet
        self.styledReferenceLine = styledReferenceLine
    }
}

// MARK: - Computed Properties

extension LineChartViewModel {
    
    public var xRange: CGFloat {
        return maxX - minX
    }
    
    public var yRange: CGFloat {
        return maxY - minY
    }
    
    public var segments: [LineChartDataSegment] {
        return styledDataSet.dataSet.segments
    }
    
    public var allDataPoints: [LineChartDataPoint] {
        return segments.flatMap { $0.dataPoints }
    }
}
