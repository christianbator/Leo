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
                        lineStyle: LineStyle =  LineStyle(lineWidth: 2, lineColor: UIColor.red)) -> LineChartDataSet {
        
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
        let absoluteDelta = abs(end.y - start.y)
        let average = start.y + absoluteDelta / 2
        let amplitude = 1.5 * absoluteDelta
        let interval = (end.x - start.x) / CGFloat(numberOfPoints)
        
        var points = [LineChartDataPoint(x: start.x, y: end.x)]
        for i in 0..<numberOfPoints {
            let x = start.x + (CGFloat(i) * interval)
            let y = average + ((2 * CGFloat(drand48()) - 1) * amplitude)
            points.append(LineChartDataPoint(x: x, y: y))
        }
        
        return points
    }
}
