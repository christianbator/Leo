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
    
    public let dataSets: [LineChartDataSet]
    public let referenceLines: [LineChartReferenceLine]
    
    public let insets: UIEdgeInsets
    
    public init(minX: CGFloatConvertible? = nil,
                maxX: CGFloatConvertible? = nil,
                minY: CGFloatConvertible? = nil,
                maxY: CGFloatConvertible? = nil,
                insets: UIEdgeInsets = .zero,
                dataSets: [LineChartDataSet],
                referenceLines: [LineChartReferenceLine] = []) {
     
        let allDataPoints = dataSets.flatMap { $0.segments }.flatMap { $0.dataPoints }
        
        let sortedByXDataPoints = allDataPoints.sorted { $0.x < $1.x }
        let sortedByYDataPoints = allDataPoints.sorted { $0.y < $1.y }
        
        self.minX = minX?.cgFloatValue ?? sortedByXDataPoints.first?.x ?? 0
        self.maxX = maxX?.cgFloatValue ?? sortedByXDataPoints.last?.x ?? 0
        
        self.minY = minY?.cgFloatValue ?? sortedByYDataPoints.first?.y ?? 0
        self.maxY = maxY?.cgFloatValue ?? sortedByYDataPoints.last?.y ?? 0
        
        self.insets = insets
        self.dataSets = dataSets
        self.referenceLines = referenceLines
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
}
