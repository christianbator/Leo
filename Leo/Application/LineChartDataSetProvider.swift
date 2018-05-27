//
//  LineChartDataSetProvider.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class LineChartDataSetProvider {
    
    static func dataSet(startingAt start: CGPoint,
                        endingAt end: CGPoint,
                        numberOfPoints: Int,
                        lineColor: UIColor = Style.nonNegativeColor) -> LineChartDataSet {
        
        let lineStyle = LineStyle(lineWidth: 2, lineColor: lineColor)
        
        let dataPoints = createPoints(
            startingAt: start,
            endingAt: end,
            numberOfPoints: numberOfPoints
        )
        
        let segment = LineChartDataSegment(
            dataPoints: dataPoints,
            lineStyle: lineStyle
        )
        
        let dataSet = LineChartDataSet(
            segments: [segment]
        )
        
        return dataSet
    }
}

// MARK: - Creating Data Points

extension LineChartDataSetProvider {
    
    private static func createPoints(startingAt start: CGPoint, endingAt end: CGPoint, numberOfPoints: Int) -> [LineChartDataPoint] {
        let delta = end.y - start.y
        let interval = (end.x - start.x) / CGFloat(numberOfPoints)
        
        var points = [LineChartDataPoint(x: start.x, y: start.y)]
        for i in 1..<numberOfPoints {
            let x = start.x + (CGFloat(i) * interval)
            let linearY = start.y + CGFloat(i) / CGFloat(numberOfPoints) * delta
            let y = linearY + ((2 * CGFloat(drand48()) - 1) * delta / 2)
            points.append(LineChartDataPoint(x: x, y: y))
        }
        
        return points
    }
}
